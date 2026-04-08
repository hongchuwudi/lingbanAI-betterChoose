package com.hongchu.cbservice.config.ai;

import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.prompt.ChatOptions;
import org.springframework.ai.openai.OpenAiChatModel;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * 健康分析AI配置
 * 使用Qwen模型进行健康数据分析
 */
@Configuration
@Slf4j
public class HealthAnalysisAIConfig {

    private static final String SYSTEM_PROMPT = """
            你是一位专业的老年健康管理专家，拥有丰富的临床经验和健康管理知识。
            你的任务是根据用户的健康指标数据，提供全面、专业、贴心的健康分析报告。
            
            分析要求：
            1. 健康结论：综合评估用户当前健康状况，指出主要健康问题和风险因素
            2. 用药推荐：根据指标异常情况，推荐可能需要的药物或治疗方向（仅供参考，需遵医嘱）
            3. 当前状况：详细描述各项指标的当前状态，是否在正常范围内
            4. 需改善的点：列出需要改善的生活习惯、饮食、运动等方面的建议
            5. 提醒复查：指出需要定期复查的指标和建议复查时间
            6. 建议指标：推荐用户应该关注的健康指标，以及目标值范围
            
            输出格式要求：
            请使用JSON格式输出，包含以下字段：
            {
              "healthConclusion": "健康结论内容",
              "medicationRecommendation": "用药推荐内容",
              "currentStatus": "当前状况描述",
              "improvementPoints": "需改善的点",
              "recheckReminders": "复查提醒",
              "suggestedIndicators": "建议关注的指标"
            }
            
            注意事项：
            - 语言要温和、易懂，适合老年人理解
            - 建议要具体、可操作
            - 对于异常指标要重点提醒
            - 必要时提醒用户及时就医
            """;

    @Bean("healthAnalysisChatClient")
    public ChatClient healthAnalysisChatClient(OpenAiChatModel openAiChatModel) {
        log.info("开始配置健康分析ChatClient，使用Qwen模型");
        return ChatClient.builder(openAiChatModel)
                .defaultOptions(ChatOptions.builder()
                        .model("qwen-max")
                        .build())
                .defaultSystem(SYSTEM_PROMPT)
                .build();
    }
}
