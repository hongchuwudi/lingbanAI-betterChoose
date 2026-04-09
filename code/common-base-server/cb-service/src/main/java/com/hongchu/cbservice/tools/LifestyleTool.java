package com.hongchu.cbservice.tools;

import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.tool.annotation.Tool;
import org.springframework.ai.tool.annotation.ToolParam;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;

/**
 * 生活健康助手工具
 * 提供每日养生提示、季节健康建议、运动推荐、饮食指导等
 */
@Component
@Slf4j
public class LifestyleTool {

    /**
     * 获取每日养生提示
     */
    @Tool(description = "获取今日的养生健康提示，包括当前时间段适合的活动、饮食和生活注意事项。" +
            "当用户问'今天要注意什么'、'给我一些养生建议'、'现在适合做什么'时调用。")
    public String getDailyHealthTips() {
        LocalDateTime now = LocalDateTime.now();
        int hour = now.getHour();
        int month = now.getMonthValue();
        int dayOfWeek = now.getDayOfWeek().getValue(); // 1=周一, 7=周日

        String season = getSeason(month);
        String timeSegment = getTimeSegment(hour);

        StringBuilder tips = new StringBuilder();
        tips.append(String.format("【今日养生提示 | %s·%s】%n%n", season, timeSegment));

        // 时间段专属建议
        switch (timeSegment) {
            case "清晨（5:00-9:00）" -> {
                tips.append("🌅 **清晨时光**\n");
                tips.append("· 醒来不要立刻起身，先在床上活动四肢1-2分钟\n");
                tips.append("· 起床动作要慢：坐起→放腿→站立，预防体位性低血压\n");
                tips.append("· 早晨空腹喝一杯温水（200-300ml），有助于清洁肠胃\n");
                tips.append("· 7:00-8:00是一天中最佳的服药时间（需遵医嘱）\n");
                tips.append("· 早晨适合做轻柔的伸展运动，如太极拳、广场舞\n");
                tips.append("· 避免在6:00-10:00进行剧烈运动（心血管风险较高）\n");
            }
            case "上午（9:00-12:00）" -> {
                tips.append("☀️ **上午时光**\n");
                tips.append("· 上午9:00-11:00是思维最活跃的时段，适合学习和看书\n");
                tips.append("· 适当晒太阳（20-30分钟），帮助合成维生素D\n");
                tips.append("· 可以进行中等强度的有氧运动：快步走、骑车\n");
                tips.append("· 注意上午饮水，每小时喝一小杯温水\n");
                tips.append("· 如果血压在早上较高，避免情绪激动和用力\n");
            }
            case "中午（12:00-14:00）" -> {
                tips.append("🌤️ **午间时光**\n");
                tips.append("· 午餐七八分饱，避免暴食\n");
                tips.append("· 饭后不要立即躺下，坐着休息15-20分钟\n");
                tips.append("· 午睡时间以20-30分钟为宜，过长影响夜间睡眠\n");
                tips.append("· 午睡不要趴着睡，避免颈椎受压\n");
                tips.append("· 午睡醒来后慢慢起身，不要着急\n");
            }
            case "下午（14:00-17:00）" -> {
                tips.append("🌈 **下午时光**\n");
                tips.append("· 下午是一天中最适合运动的时段（体温高、肌肉灵活）\n");
                tips.append("· 推荐运动：散步、太极、健身操、游泳\n");
                tips.append("· 下午3-4点可以喝一杯茶（绿茶/菊花茶），提神又养生\n");
                tips.append("· 适合安排社交活动，与邻居朋友聊聊天\n");
                tips.append("· 如果感到疲乏，短暂闭目养神即可\n");
            }
            case "傍晚（17:00-20:00）" -> {
                tips.append("🌆 **傍晚时光**\n");
                tips.append("· 晚餐要清淡，以蔬菜、粗粮为主，少吃油腻\n");
                tips.append("· 晚饭时间不要太晚，18:00-19:00最佳\n");
                tips.append("· 饭后30分钟至1小时，可以外出散步15-20分钟\n");
                tips.append("· 避免傍晚看令人情绪激动的新闻或节目\n");
                tips.append("· 晚饭后可以给子女打电话聊聊天，保持好心情\n");
            }
            case "晚上（20:00-23:00）" -> {
                tips.append("🌙 **晚间时光**\n");
                tips.append("· 晚9点后减少剧烈活动和兴奋刺激\n");
                tips.append("· 睡前1-2小时可以用热水泡脚（40°C左右，15-20分钟）\n");
                tips.append("· 睡前不要看手机屏幕（蓝光影响睡眠）\n");
                tips.append("· 保持卧室安静、黑暗、凉爽（18-22°C最佳）\n");
                tips.append("· 建议10:00-11:00上床睡觉，保证7-8小时睡眠\n");
            }
            default -> {
                tips.append("🌃 **夜间时光**\n");
                tips.append("· 深夜应保证充足睡眠\n");
                tips.append("· 如果有起夜习惯，床边放夜灯，避免摸黑起床跌倒\n");
                tips.append("· 深夜不要进食（影响消化和血糖）\n");
            }
        }

        // 季节性提示
        tips.append(String.format("%n🍃 **%s养生提示**：%n", season));
        tips.append(getSeasonTips(month));

        // 每周特别提示
        if (dayOfWeek == 1) {
            tips.append("\n📅 **周一提醒**：新的一周开始了，检查一下本周的复诊预约和用药是否充足。\n");
        } else if (dayOfWeek >= 6) {
            tips.append("\n📅 **周末提示**：子女可能回来探望，注意饮食不要过度，保持平时的规律作息。\n");
        }

        return tips.toString();
    }

    /**
     * 运动方案推荐
     */
    @Tool(description = "根据年龄和健康状况，为老年人推荐合适的运动方案，包括运动类型、频率、注意事项。" +
            "当用户问'我适合做什么运动'、'有什么运动推荐'、'怎么锻炼身体'时调用。")
    public String getExerciseRecommendation(
            @ToolParam(description = "年龄，如 68") int age,
            @ToolParam(description = "主要健康问题或限制，如：高血压、糖尿病、膝盖不好、心脏病、无特殊限制等") String healthCondition) {

        boolean hasHypertension = healthCondition.contains("高血压");
        boolean hasDiabetes = healthCondition.contains("糖尿病");
        boolean hasKneeProblems = healthCondition.contains("膝盖") || healthCondition.contains("关节炎");
        boolean hasHeartDisease = healthCondition.contains("心脏") || healthCondition.contains("冠心病") || healthCondition.contains("心衰");
        boolean hasOsteoporosis = healthCondition.contains("骨质疏松");
        boolean isHealthy = healthCondition.contains("无") || healthCondition.isBlank();

        StringBuilder plan = new StringBuilder();
        plan.append(String.format("【%d岁运动推荐方案】%n%n", age));

        // 目标心率计算
        int maxHR = 220 - age;
        int targetHR_low = (int)(maxHR * 0.5);
        int targetHR_high = (int)(maxHR * 0.7);
        plan.append(String.format("💓 安全运动心率范围：%d-%d 次/分钟%n%n", targetHR_low, targetHR_high));

        // 有氧运动推荐
        plan.append("🏃 **推荐有氧运动**（每次20-40分钟，每周3-5次）：\n");

        if (hasKneeProblems) {
            plan.append("✅ 游泳/水中运动（最适合，减轻关节压力）\n");
            plan.append("✅ 骑固定自行车（低冲击，适合膝盖）\n");
            plan.append("✅ 椭圆机（比跑步友好）\n");
            plan.append("❌ 避免：跑步、爬山、爬楼梯、深蹲\n");
        } else if (hasHeartDisease) {
            plan.append("✅ 平地慢走（最安全的有氧运动）\n");
            plan.append("✅ 太极拳（对心脏友好）\n");
            plan.append("⚠️ 必须在医生评估后，制定个性化运动方案\n");
            plan.append("❌ 避免：剧烈运动、早晨6-10点高强度运动\n");
        } else if (age >= 80) {
            plan.append("✅ 缓慢散步（每天15-20分钟即可）\n");
            plan.append("✅ 简单体操（坐在椅子上也可以做）\n");
            plan.append("✅ 伸展运动（改善柔韧性）\n");
        } else {
            plan.append("✅ 快步走（最简单易行，效果显著）\n");
            plan.append("✅ 太极拳/广场舞（兼顾运动和社交）\n");
            plan.append("✅ 游泳（全身性、低冲击）\n");
            plan.append("✅ 骑自行车（室内或户外均可）\n");
        }

        // 平衡和力量训练
        plan.append("\n⚖️ **平衡训练**（预防跌倒，每天5-10分钟）：\n");
        plan.append("· 单腿站立（金鸡独立）：扶椅子练习，每次10-30秒\n");
        plan.append("· 踮脚走路：沿直线行走，锻炼平衡感\n");
        plan.append("· 转头运动：缓慢向左右各转头，增强颈部平衡\n");

        if (!hasOsteoporosis) {
            plan.append("\n💪 **轻度力量训练**（每周2-3次）：\n");
            plan.append("· 靠墙深蹲（15-30度）：增强腿部力量\n");
            plan.append("· 坐姿手臂弯举（0.5-1kg哑铃）：维持上肢力量\n");
            plan.append("· 腹部呼吸练习：增强核心稳定性\n");
        }

        // 特殊健康状况提示
        if (hasHypertension) {
            plan.append("\n⚠️ **高血压运动注意事项**：\n");
            plan.append("· 运动前测量血压，收缩压>180不宜运动\n");
            plan.append("· 避免憋气、头部低于心脏的动作\n");
            plan.append("· 冬天运动要做好热身\n");
        }

        if (hasDiabetes) {
            plan.append("\n⚠️ **糖尿病运动注意事项**：\n");
            plan.append("· 餐后1小时再运动，避免低血糖\n");
            plan.append("· 随身携带糖果或葡萄糖片\n");
            plan.append("· 注意检查足部，穿合适的运动鞋\n");
        }

        plan.append("\n📋 **通用运动安全原则**：\n");
        plan.append("· 每次运动前5分钟热身，结束后5分钟放松\n");
        plan.append("· 运动中出现胸痛、头晕、心跳不规则，立即停止\n");
        plan.append("· 循序渐进，不要强迫自己\n");
        plan.append("· 运动后注意补水\n");
        plan.append("· 天气极端（高温、寒冷、大风）时减少户外运动\n");

        return plan.toString();
    }

    /**
     * 饮食健康指导
     */
    @Tool(description = "根据健康状况提供个性化的饮食建议，包括推荐食物、禁忌食物、饮食注意事项。" +
            "当用户问'我能吃什么'、'什么食物对我的病好'、'有什么饮食建议'时调用。")
    public String getDietAdvice(
            @ToolParam(description = "主要健康状况，如：高血压、糖尿病、高血脂、肾病、骨质疏松、消化不好等") String healthCondition,
            @ToolParam(description = "特别关注点，如：最近便秘、食欲不好、消化不良等（可留空）") String specificConcern) {

        StringBuilder advice = new StringBuilder();
        advice.append(String.format("【饮食健康建议：%s】%n%n", healthCondition));

        // 通用老年人饮食原则
        advice.append("🍱 **通用饮食原则**：\n");
        advice.append("· 少量多餐：三餐+1-2次加餐，每餐七八分饱\n");
        advice.append("· 细嚼慢咽：每口食物咀嚼15-20次，减轻消化负担\n");
        advice.append("· 温热为主：避免过凉、过烫的食物\n");
        advice.append("· 每天饮水：至少1500-2000ml（8杯水），少量多次\n\n");

        if (healthCondition.contains("高血压")) {
            advice.append("🔵 **高血压饮食**：\n");
            advice.append("✅ 推荐：\n");
            advice.append("  · 蔬菜：芹菜、菠菜、洋葱、香蕉、橙子（含钾，降压）\n");
            advice.append("  · 深海鱼：三文鱼、沙丁鱼（每周2-3次）\n");
            advice.append("  · 低脂乳制品：脱脂牛奶、低脂酸奶\n");
            advice.append("  · 坚果：核桃、杏仁（少量，每日一小把）\n");
            advice.append("❌ 限制：\n");
            advice.append("  · 食盐 <5g/天（包括酱油、味精中的钠）\n");
            advice.append("  · 腌制食品（泡菜、咸鱼、腊肉）\n");
            advice.append("  · 浓茶、咖啡、烈酒\n\n");
        }

        if (healthCondition.contains("糖尿病")) {
            advice.append("🟢 **糖尿病饮食**：\n");
            advice.append("✅ 推荐（低升糖指数食物）：\n");
            advice.append("  · 主食：燕麦、荞麦、糙米、紫薯（代替白米白面）\n");
            advice.append("  · 蔬菜：苦瓜、黄瓜、西兰花、苦菊（有助控糖）\n");
            advice.append("  · 蛋白质：鱼类、豆腐、鸡蛋（优先植物蛋白）\n");
            advice.append("  · 坚果：少量核桃、花生（控制升糖）\n");
            advice.append("❌ 禁止/限制：\n");
            advice.append("  · 白糖、蜂蜜、含糖饮料、果汁\n");
            advice.append("  · 精制主食（白面包、饼干、糯米）\n");
            advice.append("  · 高GI水果（西瓜、荔枝）改为低GI（苹果、梨、草莓）\n\n");
        }

        if (healthCondition.contains("高血脂")) {
            advice.append("🟡 **高血脂饮食**：\n");
            advice.append("✅ 推荐：\n");
            advice.append("  · 富含Omega-3：三文鱼、亚麻籽油、核桃\n");
            advice.append("  · 膳食纤维：燕麦、苹果、豆类（降低胆固醇吸收）\n");
            advice.append("  · 大豆及豆制品：豆腐、豆浆\n");
            advice.append("  · 橄榄油代替植物油\n");
            advice.append("❌ 限制：\n");
            advice.append("  · 动物内脏、蛋黄（每周≤4个）\n");
            advice.append("  · 红肉（每天<75g）、肥肉、动物油脂\n");
            advice.append("  · 油炸食品、奶油蛋糕\n\n");
        }

        if (healthCondition.contains("骨质疏松") || healthCondition.contains("补钙")) {
            advice.append("🦴 **骨质疏松/补钙饮食**：\n");
            advice.append("✅ 高钙食物（每日钙需求1000-1200mg）：\n");
            advice.append("  · 牛奶1杯（200ml，约240mg钙）+ 酸奶\n");
            advice.append("  · 豆腐（北豆腐约100g含127mg钙）\n");
            advice.append("  · 虾皮（钙含量极高，每次少量）\n");
            advice.append("  · 深色蔬菜：西兰花、芥菜、小白菜\n");
            advice.append("  · 芝麻酱（高钙，可拌菜）\n");
            advice.append("⚠️ 同时注意：\n");
            advice.append("  · 维生素D：每天晒太阳20分钟（手臂和脸部）\n");
            advice.append("  · 减少影响钙吸收的食物：可乐、浓茶、大量菠菜\n\n");
        }

        if (healthCondition.contains("便秘") || (specificConcern != null && specificConcern.contains("便秘"))) {
            advice.append("🟤 **改善便秘饮食**：\n");
            advice.append("✅ 推荐：\n");
            advice.append("  · 高纤维食物：红薯、燕麦、芹菜、火龙果\n");
            advice.append("  · 发酵食品：酸奶（益生菌改善肠道）\n");
            advice.append("  · 早晨空腹喝一杯温水或蜂蜜水\n");
            advice.append("  · 适量食用香蕉（熟透的）\n");
            advice.append("⚠️ 注意：\n");
            advice.append("  · 每天饮水量要充足\n");
            advice.append("  · 饭后适当活动，促进肠胃蠕动\n\n");
        }

        if (healthCondition.contains("消化") || (specificConcern != null && specificConcern.contains("消化"))) {
            advice.append("🟠 **改善消化饮食**：\n");
            advice.append("✅ 推荐：\n");
            advice.append("  · 易消化食物：小米粥、蒸鸡蛋、清蒸鱼\n");
            advice.append("  · 发酵食品：酸奶、发酵豆腐\n");
            advice.append("  · 少量山楂（饭后助消化）\n");
            advice.append("❌ 避免：\n");
            advice.append("  · 油炸、生冷、辛辣、粗糙食物\n");
            advice.append("  · 暴饮暴食，进食过快\n\n");
        }

        advice.append("📋 **购买食材小贴士**：\n");
        advice.append("· 每周购物时参考「一拳蔬菜、一掌蛋白、一捧主食」的比例\n");
        advice.append("· 颜色越丰富的蔬果，营养越均衡（彩虹饮食原则）\n");
        advice.append("· 少食加工食品，优选新鲜食材\n");

        return advice.toString();
    }

    /**
     * 睡眠健康建议
     */
    @Tool(description = "提供改善睡眠质量的实用建议，包括睡前准备、睡眠环境、应对失眠的方法。" +
            "当用户提到睡眠不好、失眠、睡不着、睡眠浅等问题时调用。")
    public String getSleepAdvice(
            @ToolParam(description = "主要睡眠问题，如：入睡困难、睡眠浅、频繁醒来、早醒、白天困等") String sleepProblem) {

        StringBuilder advice = new StringBuilder();
        advice.append("【睡眠健康改善方案】\n\n");

        advice.append("⏰ **黄金睡眠时间**：老年人建议晚上10点-早上6点，总睡眠7-8小时\n\n");

        advice.append("🌙 **改善睡眠的好习惯**：\n");
        advice.append("1. **固定作息**：每天同一时间上床、起床（包括周末）\n");
        advice.append("2. **睡前准备**（9-10点）：\n");
        advice.append("   · 泡脚：40°C热水泡脚15-20分钟，促进血液循环\n");
        advice.append("   · 喝热牛奶（200ml，含色氨酸，助眠）\n");
        advice.append("   · 轻柔拉伸或腹式呼吸放松\n");
        advice.append("   · 关掉手机或调为勿扰模式\n");
        advice.append("3. **睡眠环境**：\n");
        advice.append("   · 室温18-22°C最适宜睡眠\n");
        advice.append("   · 避免噪音和光线（用遮光窗帘）\n");
        advice.append("   · 枕头高度适中（侧卧时颈部不弯曲）\n");

        if (sleepProblem.contains("入睡困难") || sleepProblem.contains("睡不着")) {
            advice.append("\n😴 **针对入睡困难**：\n");
            advice.append("· **4-7-8呼吸法**：吸气4秒→屏气7秒→呼气8秒，重复4次\n");
            advice.append("· **渐进式肌肉放松**：从脚趾到头部，依次绷紧再放松每块肌肉\n");
            advice.append("· 睡前1小时避免看手机、电视（蓝光抑制褪黑素）\n");
            advice.append("· 躺在床上超过20分钟没睡着，起来做些轻松的事，等困了再上床\n");
        }

        if (sleepProblem.contains("频繁醒") || sleepProblem.contains("睡眠浅")) {
            advice.append("\n😴 **针对睡眠浅/频繁醒来**：\n");
            advice.append("· 检查是否有睡眠呼吸暂停（打鼾+停止呼吸），如有需就医\n");
            advice.append("· 睡前减少饮水（减少夜间起夜次数）\n");
            advice.append("· 使用耳塞或白噪音机器（减少外界声音干扰）\n");
            advice.append("· 避免睡前喝咖啡、茶、酒（酒精会让睡眠变浅）\n");
        }

        if (sleepProblem.contains("早醒")) {
            advice.append("\n😴 **针对早醒**：\n");
            advice.append("· 早醒常见于老年人，适量是正常的\n");
            advice.append("· 醒来后不要看手机查时间（会让大脑兴奋）\n");
            advice.append("· 可以做腹式呼吸，帮助重新入睡\n");
            advice.append("· 如果每天早醒伴有情绪低落，要注意是否有抑郁情绪，建议咨询医生\n");
        }

        advice.append("\n⚠️ **注意事项**：\n");
        advice.append("· 安眠药要在医生指导下使用，不要自行服用\n");
        advice.append("· 长期失眠（超过1个月）要及时就医，排除疾病因素\n");
        advice.append("· 白天午睡不超过30分钟，太长影响晚上睡眠\n");
        advice.append("· 下午3点后不要喝含咖啡因的饮料\n");

        return advice.toString();
    }

    /**
     * 心理健康支持
     */
    @Tool(description = "提供老年人心理健康指导，帮助应对孤独、焦虑、情绪低落等情绪问题，" +
            "提供具体的情绪调节方法和社交建议。" +
            "当用户表达孤独、担心、焦虑、心情不好、想念家人等情绪时调用。")
    public String getMentalHealthSupport(
            @ToolParam(description = "情绪困扰描述，如：孤独、焦虑、心情不好、担心病情、想念家人、无聊等") String emotionalConcern) {

        StringBuilder support = new StringBuilder();
        support.append("【心理健康支持建议】\n\n");

        if (emotionalConcern.contains("孤独") || emotionalConcern.contains("寂寞")) {
            support.append("💙 **关于孤独感**：\n");
            support.append("孤独是很多老人都有的感受，您并不孤单。以下方法可以帮助您：\n\n");
            support.append("🤝 **增加社交连接**：\n");
            support.append("· 参加社区老年活动中心或老年大学（书法、舞蹈、合唱等）\n");
            support.append("· 主动与邻居打招呼、聊天，建立邻里关系\n");
            support.append("· 与老朋友联系，约着出来喝茶、散步\n");
            support.append("· 学习用手机和子女视频通话，随时分享生活\n\n");
            support.append("🐾 **其他方式**：\n");
            support.append("· 养一盆绿植或花草（有生命陪伴感）\n");
            support.append("· 做志愿者，帮助他人（增加价值感和社交）\n");
            support.append("· 培养兴趣爱好（读书、绘画、钓鱼等）\n");
        }

        if (emotionalConcern.contains("焦虑") || emotionalConcern.contains("担心") || emotionalConcern.contains("紧张")) {
            support.append("💛 **关于焦虑担心**：\n");
            support.append("适度担心健康是正常的，但过度焦虑会影响生活质量。\n\n");
            support.append("🧘 **缓解焦虑的方法**：\n");
            support.append("· **腹式呼吸**：深吸气4秒（腹部鼓起）→缓慢呼气6秒，重复10次\n");
            support.append("· **写下来**：把担心的事写在纸上，然后针对每件事想一个可行的应对方法\n");
            support.append("· **活在当下**：把注意力放到眼前的事上，而不是将来的担忧\n");
            support.append("· **与家人倾诉**：把担心告诉子女或朋友，不要憋在心里\n");
        }

        if (emotionalConcern.contains("心情不好") || emotionalConcern.contains("难过") || emotionalConcern.contains("情绪低落")) {
            support.append("🩵 **关于情绪低落**：\n");
            support.append("情绪低落时，请给自己一些温柔和理解。\n\n");
            support.append("☀️ **改善心情的方法**：\n");
            support.append("· 出门晒太阳，日光能促进大脑分泌让心情好的物质\n");
            support.append("· 做一件让自己高兴的事（吃喜欢的食物、听老歌）\n");
            support.append("· 与家人或老朋友聊聊心里话\n");
            support.append("· 回忆美好的往事，翻看老照片\n\n");
            support.append("⚠️ **需要关注的情况**：\n");
            support.append("如果情绪低落持续超过2周，同时出现：\n");
            support.append("· 完全失去对生活的兴趣\n");
            support.append("· 食欲和体重明显变化\n");
            support.append("· 有悲观或轻生的念头\n");
            support.append("请务必告诉家人，并就医评估是否有抑郁症。\n");
        }

        if (emotionalConcern.contains("无聊") || emotionalConcern.contains("没意思")) {
            support.append("🌸 **关于无聊感**：\n");
            support.append("退休后生活节奏变慢是很多老人的感受，关键是找到新的生活意义。\n\n");
            support.append("🎯 **填充生活的建议**：\n");
            support.append("· **学点新东西**：老年大学、网络课程（书画、烹饪、历史）\n");
            support.append("· **参与力所能及的家务**：种菜、烹饪、整理，保持生活参与感\n");
            support.append("· **传授人生经验**：给孙辈讲故事、写回忆录\n");
            support.append("· **参加社区活动**：广场舞、棋牌、健步走队伍\n");
        }

        support.append("\n💬 **小灵陪伴您**：\n");
        support.append("无论您有什么心里话，都可以跟我说说。我随时都在，愿意聆听您的故事和感受。\n");
        support.append("您的心情和健康同样重要，请好好爱护自己！💕");

        return support.toString();
    }

    // ─── 内部辅助方法 ─────────────────────────────────────────

    private String getTimeSegment(int hour) {
        if (hour >= 5 && hour < 9) return "清晨（5:00-9:00）";
        if (hour >= 9 && hour < 12) return "上午（9:00-12:00）";
        if (hour >= 12 && hour < 14) return "中午（12:00-14:00）";
        if (hour >= 14 && hour < 17) return "下午（14:00-17:00）";
        if (hour >= 17 && hour < 20) return "傍晚（17:00-20:00）";
        if (hour >= 20 && hour < 23) return "晚上（20:00-23:00）";
        return "深夜";
    }

    private String getSeason(int month) {
        if (month >= 3 && month <= 5) return "春季";
        if (month >= 6 && month <= 8) return "夏季";
        if (month >= 9 && month <= 11) return "秋季";
        return "冬季";
    }

    private String getSeasonTips(int month) {
        if (month == 3 || month == 4 || month == 5) {
            return "· 春季气温变化大，注意「春捂」，不要急于减衣\n" +
                   "· 春季容易过敏，花粉过敏者戴口罩出行\n" +
                   "· 春天是养肝好时节：多吃绿色蔬菜，保持好心情\n";
        } else if (month == 6 || month == 7 || month == 8) {
            return "· 夏季注意防暑：避免正午（10:00-16:00）在烈日下活动\n" +
                   "· 多补水：每天至少2000ml，大量出汗时可适量喝淡盐水\n" +
                   "· 空调温度不要太低（建议26°C以上），避免「空调病」\n" +
                   "· 饮食注意食品安全，夏天食物容易变质\n";
        } else if (month == 9 || month == 10 || month == 11) {
            return "· 秋季干燥，多吃润肺食物：梨、百合、银耳\n" +
                   "· 「秋冻」不适合老年人，感觉凉了就加衣\n" +
                   "· 深秋注意保护关节和腰部\n" +
                   "· 是接种流感疫苗的好时机（10月前接种）\n";
        } else {
            return "· 冬季保暖最重要：重点保护头颈、腰背、膝盖\n" +
                   "· 洗澡水温不要太高（38-40°C），洗澡时间不超过15分钟\n" +
                   "· 早晨起床先在床上活动，不要立刻起身去寒冷地方\n" +
                   "· 心脑血管疾病患者冬天要特别小心，如感不适及时就医\n";
        }
    }
}
