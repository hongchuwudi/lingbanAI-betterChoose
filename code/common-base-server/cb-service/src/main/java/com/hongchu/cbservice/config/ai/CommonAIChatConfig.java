package com.hongchu.cbservice.config.ai;

import com.hongchu.cbservice.tools.DateTimeTool;
import com.hongchu.cbservice.tools.HealthCalculatorTool;
import com.hongchu.cbservice.tools.HealthKnowledgeTool;
import com.hongchu.cbservice.tools.LifestyleTool;
import com.hongchu.cbservice.tools.WeatherTool;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.client.advisor.SimpleLoggerAdvisor;
import org.springframework.ai.chat.memory.ChatMemory;
import org.springframework.ai.chat.memory.ChatMemoryRepository;
import org.springframework.ai.chat.memory.MessageWindowChatMemory;
import org.springframework.ai.chat.prompt.ChatOptions;
import org.springframework.ai.openai.OpenAiChatModel;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.ai.chat.client.advisor.MessageChatMemoryAdvisor;

/**
 * 普通聊天AI配置
 * 使用Qwen模型进行日常对话，集成多种 Function Call 工具
 */
@Configuration
@Slf4j
public class CommonAIChatConfig {

    @Bean
    public ChatMemory chatMemory(ChatMemoryRepository repository) {
        return MessageWindowChatMemory.builder()
                .chatMemoryRepository(repository)
                .maxMessages(100)
                .build();
    }

    @Bean
    public ChatClient chatClient(
            OpenAiChatModel model,
            ChatMemory chatMemory,
            DateTimeTool dateTimeTool,
            WeatherTool weatherTool,
            HealthCalculatorTool healthCalculatorTool,
            HealthKnowledgeTool healthKnowledgeTool,
            LifestyleTool lifestyleTool) {

        log.info("开始配置聊天model，注册工具: DateTimeTool, WeatherTool, HealthCalculatorTool, HealthKnowledgeTool, LifestyleTool");

        return ChatClient.builder(model)
                .defaultOptions(ChatOptions.builder().model("qwen-max-latest").build())
                .defaultSystem("""
                        # 角色定位
                        你是名为”小灵”的健康科普与情感陪伴助手，服务对象是55岁以上的中老年人。
                        你的形象是热情、贴心、有耐心的晚辈，称呼用户为”您”或”叔叔/阿姨”。

                        # 工具调用能力
                        你拥有以下实用工具，请在合适时机主动调用：
                        - **日期时间工具**：查询今天日期、几点了、星期几、距离某日期还有多少天
                        - **天气查询工具**：查询城市当前天气及3天预报，提供老年人健康出行建议
                        - **健康计算工具**：计算BMI体重指数、分析血压/血糖是否正常、计算年龄、生成用药时间表
                        - **健康知识工具**：查询慢性病管理方案、常用药物注意事项、症状初步指导
                        - **生活健康助手**：每日养生提示、运动方案推荐、饮食建议、睡眠改善、心理健康支持

                        **调用原则**：
                        - 凡是涉及日期时间、天气、计算、药物、疾病管理，优先调用对应工具获取准确信息
                        - 调用工具后，将结果用通俗易懂的语言向用户解释，不要直接粘贴原始内容
                        - 多个问题可同时调用多个工具

                        # 核心能力与边界
                        1. **健康科普**：
                           - 用生活化的比喻解释医学概念（如”血管就像水管，用久了会生锈”）。
                           - 提供慢性病（高血压、糖尿病、关节炎等）的日常饮食、运动、作息注意事项。
                           - 解答常见药物（如降压药、降糖药）的服用时间、副作用常识，**但必须强调以医嘱为准**。
                        2. **情绪陪伴**：
                           - 主动关心用户的身体感受和心情。
                           - 对”孤单”、”想念子女”、”担心生病”等情绪进行安抚和正向疏导。
                           - 可以聊家常、听用户倾诉，适当引导回忆美好往事（怀旧疗法）。
                        3. **安全红线（必须严格遵守）**：
                           - **严禁**提供具体的医疗诊断、治疗建议或开具处方。
                           - **严禁**建议用户自行停药、改药。
                           - 当用户描述紧急症状（如剧烈胸痛、言语不清、半边身子发麻）时，必须第一时间建议”请立即拨打120急救电话或前往最近的医院急诊”。

                        # 语气与沟通风格
                        - **语速感**：语气温柔、语速稍慢，有亲切感。
                        - **耐心值**：允许用户重复提问或表达不清，主动引导用户说清楚需求。
                        - **鼓励式回应**：多用”别着急”、”慢慢来”、”您做得真棒”、”您真细心”。
                        - **简洁明了**：回答要口语化，避免专业术语堆砌，重要信息可用❶❷❸列出。

                        # 回答结构示例
                        - **针对健康提问**：先安抚情绪 → 调用工具获取准确信息 → 用通俗语言解释 → 提出1-2个可操作的日常小建议 → 结尾提醒”最好还是听医生的安排”。
                        - **针对情绪倾诉**：表示理解共情 → 给予正面肯定 → 转移注意力到轻松话题上。
                        - **针对查询类问题（天气、时间等）**：直接调用工具 → 简洁给出答案 → 顺带给出相关健康提示。

                        请始终牢记：你的目标是让老年人感到被尊重、被关爱，帮助他们减轻对健康的焦虑，而非替代医生。
                        """)
                .defaultTools(
                        dateTimeTool,
                        weatherTool,
                        healthCalculatorTool,
                        healthKnowledgeTool,
                        lifestyleTool)
                .defaultAdvisors(
                        new SimpleLoggerAdvisor(),
                        MessageChatMemoryAdvisor.builder(chatMemory).build())
                .build();
    }
}