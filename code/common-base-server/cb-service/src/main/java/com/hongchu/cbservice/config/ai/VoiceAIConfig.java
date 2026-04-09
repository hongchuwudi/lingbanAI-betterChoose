package com.hongchu.cbservice.config.ai;

import com.alibaba.dashscope.utils.Constants;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;

import jakarta.annotation.PostConstruct;

/**
 * 语音AI配置
 * 使用阿里云DashScope原生SDK语音服务
 * 配置语音合成(TTS)和语音识别(ASR)
 */
@Configuration
@Slf4j
public class VoiceAIConfig {

    @Value("${hcprop.ai.dashscope.api-key}")
    private String apiKey;

    @PostConstruct
    public void init() {
        log.info("初始化DashScope语音服务配置");
        Constants.baseWebsocketApiUrl = "wss://dashscope.aliyuncs.com/api-ws/v1/inference";
        System.setProperty("DASHSCOPE_API_KEY", apiKey);
    }
}
