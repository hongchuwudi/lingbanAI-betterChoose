package com.hongchu.cbservice.config;

import org.springframework.amqp.core.*;
import org.springframework.amqp.rabbit.config.SimpleRabbitListenerContainerFactory;
import org.springframework.amqp.rabbit.connection.ConnectionFactory;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.amqp.support.converter.Jackson2JsonMessageConverter;
import org.springframework.amqp.support.converter.MessageConverter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * RabbitMQ配置类
 * 配置交换机、队列、绑定关系以及消息转换器
 * 
 * @author hongchu
 * @since 2026-03-25
 */
@Configuration
public class RabbitMQConfig {

    // ==================== 交换机定义 ====================
    
    /**
     * 直连交换机 - 用于精确路由
     */
    @Bean
    public DirectExchange directExchange() {
        return new DirectExchange("hc.direct.exchange", true, false);
    }

    /**
     * 主题交换机 - 用于模式匹配路由
     */
    @Bean
    public TopicExchange topicExchange() {
        return new TopicExchange("hc.topic.exchange", true, false);
    }

    /**
     * 扇形交换机 - 用于广播消息
     */
    @Bean
    public FanoutExchange fanoutExchange() {
        return new FanoutExchange("hc.fanout.exchange", true, false);
    }

    // ==================== 队列定义 ====================

    /**
     * 用户相关队列
     */
    @Bean
    public Queue userQueue() {
        return QueueBuilder.durable("hc.user.queue")
                .withArgument("x-dead-letter-exchange", "hc.dlx.exchange")
                .withArgument("x-dead-letter-routing-key", "hc.user.dlx")
                .build();
    }

    /**
     * 通知相关队列
     */
    @Bean
    public Queue notificationQueue() {
        return QueueBuilder.durable("hc.notification.queue")
                .withArgument("x-dead-letter-exchange", "hc.dlx.exchange")
                .withArgument("x-dead-letter-routing-key", "hc.notification.dlx")
                .build();
    }

    /**
     * 健康数据队列
     */
    @Bean
    public Queue healthDataQueue() {
        return QueueBuilder.durable("hc.health.data.queue")
                .withArgument("x-dead-letter-exchange", "hc.dlx.exchange")
                .withArgument("x-dead-letter-routing-key", "hc.health.data.dlx")
                .build();
    }

    /**
     * 死信队列
     */
    @Bean
    public Queue deadLetterQueue() {
        return new Queue("hc.dead.letter.queue", true);
    }

    /**
     * 死信交换机
     */
    @Bean
    public DirectExchange deadLetterExchange() {
        return new DirectExchange("hc.dlx.exchange", true, false);
    }

    // ==================== 绑定关系 ====================

    /**
     * 用户队列绑定到直连交换机
     */
    @Bean
    public Binding userBinding() {
        return BindingBuilder.bind(userQueue())
                .to(directExchange())
                .with("hc.user.routing");
    }

    /**
     * 通知队列绑定到主题交换机
     */
    @Bean
    public Binding notificationBinding() {
        return BindingBuilder.bind(notificationQueue())
                .to(topicExchange())
                .with("hc.notification.#");
    }

    /**
     * 健康数据队列绑定到主题交换机
     */
    @Bean
    public Binding healthDataBinding() {
        return BindingBuilder.bind(healthDataQueue())
                .to(topicExchange())
                .with("hc.health.data.#");
    }

    /**
     * 死信队列绑定到死信交换机
     */
    @Bean
    public Binding deadLetterBinding() {
        return BindingBuilder.bind(deadLetterQueue())
                .to(deadLetterExchange())
                .with("hc.#");
    }

    // ==================== 消息转换器 ====================

    /**
     * JSON消息转换器
     */
    @Bean
    public MessageConverter jsonMessageConverter() {
        return new Jackson2JsonMessageConverter();
    }

    /**
     * RabbitTemplate配置
     */
    @Bean
    public RabbitTemplate rabbitTemplate(ConnectionFactory connectionFactory) {
        RabbitTemplate template = new RabbitTemplate(connectionFactory);
        template.setMessageConverter(jsonMessageConverter());
        
        // 配置确认回调
        template.setConfirmCallback((correlationData, ack, cause) -> {
            if (ack) {
                System.out.println("消息发送成功: " + correlationData);
            } else {
                System.err.println("消息发送失败: " + cause);
            }
        });
        
        // 配置返回回调
        template.setReturnsCallback(returned -> {
            System.err.println("消息路由失败: " + returned.getMessage() + 
                    "，路由键: " + returned.getRoutingKey() + 
                    "，交换机: " + returned.getExchange());
        });
        
        return template;
    }

    /**
     * 监听器容器工厂配置
     */
    @Bean
    public SimpleRabbitListenerContainerFactory rabbitListenerContainerFactory(ConnectionFactory connectionFactory) {
        SimpleRabbitListenerContainerFactory factory = new SimpleRabbitListenerContainerFactory();
        factory.setConnectionFactory(connectionFactory);
        factory.setMessageConverter(jsonMessageConverter());
        factory.setConcurrentConsumers(3);
        factory.setMaxConcurrentConsumers(10);
        factory.setPrefetchCount(1);
        return factory;
    }
}