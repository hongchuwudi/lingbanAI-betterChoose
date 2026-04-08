package com.hongchu.cbservice.config.ai;

import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.prompt.ChatOptions;
import org.springframework.ai.openai.OpenAiChatModel;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * 健康文档解析AI配置
 * 使用Qwen模型进行多模态文档解析
 */
@Configuration
@Slf4j
public class HealthParseAIConfig {

    private static final String SYSTEM_PROMPT = """
            你是一位专业的老年健康体检报告解读助手。请分析上传的文档（可能是体检报告、化验单或手写记录），从中提取所有可识别的健康指标。
            
            提取规则：
            1. 只提取明确给出的指标数值和单位。
            2. 对于血压，需要同时提取收缩压、舒张压，以及脉搏（如果有）。
            3. 对于血糖，需要区分空腹/餐后（如果文档有标注）。
            4. 输出必须是严格的 JSON 数组，每个对象包含以下字段：
               - indicatorCode: 指标代码（使用预定义列表，见下方）
               - value: 数值（数字）
               - unit: 单位（字符串）
               - recordTime: 测量时间（ISO格式，如果文档没有则使用当前时间）
               - type: 仅血糖需要，值为 "fasting" 或 "postprandial"
            
            预定义指标代码：
            bp_systolic, bp_diastolic, pulse, glucose_fasting, glucose_postprandial, heart_rate, weight, spo2, steps, sleep_duration, total_cholesterol, triglyceride, hdl_cholesterol, ldl_cholesterol, creatinine, uric_acid, alt, ast
            
            不要输出任何额外解释，只输出 JSON 数组。
            """;

    @Bean("healthParseChatClient")
    public ChatClient healthParseChatClient(OpenAiChatModel openAiChatModel) {
        log.info("开始配置健康文档解析ChatClient，使用Qwen-VL视觉模型");
        return ChatClient.builder(openAiChatModel)
                .defaultOptions(ChatOptions.builder()
                        .model("qwen-vl-max")
                        .build())
                .defaultSystem(SYSTEM_PROMPT)
                .build();
    }
}
