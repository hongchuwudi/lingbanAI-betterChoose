package com.hongchu.cbservice.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.socket.config.annotation.EnableWebSocket;
import org.springframework.web.socket.server.standard.ServerEndpointExporter;

/**
 * WebSocket配置类
 * 作用：启用WebSocket支持，自动注册@ServerEndpoint注解的端点
 */
@Configuration
@EnableWebSocket
public class WebSocketConfig {

    /**
     * 这个Bean是必须的！
     * 它会自动扫描所有@ServerEndpoint注解的类并注册为WebSocket端点
     */
    @Bean
    public ServerEndpointExporter serverEndpointExporter() {
        return new ServerEndpointExporter();
    }
}