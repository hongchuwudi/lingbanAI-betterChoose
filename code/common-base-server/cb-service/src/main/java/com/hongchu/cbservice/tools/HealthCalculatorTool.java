package com.hongchu.cbservice.tools;

import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.tool.annotation.Tool;
import org.springframework.ai.tool.annotation.ToolParam;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.Period;

/**
 * 健康计算工具
 * 提供BMI计算、血压分析、年龄计算、用药时间计算等功能
 */
@Component
@Slf4j
public class HealthCalculatorTool {

    /**
     * 计算BMI指数
     */
    @Tool(description = "根据身高和体重计算BMI体重指数，并给出中国老年人标准的健康评估和建议。" +
            "当用户问'我的体重正常吗'、'帮我算一下BMI'、'我体重XX公斤身高XX厘米标准吗'等问题时调用。")
    public String calculateBMI(
            @ToolParam(description = "体重，单位：千克（公斤），例如 65.5") double weightKg,
            @ToolParam(description = "身高，单位：厘米，例如 165") double heightCm) {
        if (weightKg <= 0 || heightCm <= 0) {
            return "请提供正确的身高和体重数值。";
        }

        double heightM = heightCm / 100.0;
        double bmi = weightKg / (heightM * heightM);

        String category;
        String advice;
        String emoji;

        // 使用中国/亚洲标准（比西方标准略严）
        if (bmi < 18.5) {
            category = "偏瘦（体重不足）";
            emoji = "⚠️";
            advice = "您的体重偏轻，建议适当增加营养摄入。可多食用富含蛋白质的食物（鸡蛋、鱼、豆制品），以及优质碳水化合物（全谷物、薯类）。老年人偏瘦会增加骨折和感染风险，建议在医生指导下制定增重计划。";
        } else if (bmi < 24.0) {
            category = "正常体重";
            emoji = "✅";
            advice = "您的体重在健康范围内，请继续保持均衡饮食和适度运动的好习惯！建议定期监测体重变化，避免体重大幅波动。";
        } else if (bmi < 28.0) {
            category = "超重";
            emoji = "⚠️";
            advice = "您的体重略微超标。建议：①适当控制主食量，减少油腻食物；②每天坚持30分钟左右的有氧运动（如散步、太极）；③避免睡前进食。定期检查血压、血糖、血脂，预防代谢综合征。";
        } else if (bmi < 32.0) {
            category = "轻度肥胖";
            emoji = "⚠️";
            advice = "您的体重属于轻度肥胖，心脑血管疾病风险有所增加。建议：①在医生指导下制定减重计划；②减少高糖高脂食物；③选择低强度运动（游泳、慢走）。请定期监测血压和血糖。";
        } else {
            category = "中度及以上肥胖";
            emoji = "🔴";
            advice = "您的体重严重超标，建议尽快到内分泌科或营养科就诊，在医生指导下进行系统性减重管理。肥胖可显著增加糖尿病、高血压、心脏病等风险，请重视！";
        }

        // 理想体重范围
        double idealMin = 18.5 * heightM * heightM;
        double idealMax = 24.0 * heightM * heightM;

        return String.format(
            "【BMI健康评估结果】%n%n" +
            "%s 您的BMI指数：**%.1f**%n" +
            "健康分类：%s%n" +
            "身高：%.0f cm，体重：%.1f kg%n%n" +
            "健康体重范围：%.1f ~ %.1f kg%n%n" +
            "📋 健康建议：%n%s",
            emoji, bmi, category, heightCm, weightKg, idealMin, idealMax, advice
        );
    }

    /**
     * 计算实际年龄
     */
    @Tool(description = "根据出生日期计算精确年龄（岁数），以及对应年龄段的健康注意事项。" +
            "当用户问'我今年多少岁了'、'帮我算一下年龄'时调用。")
    public String calculateAge(
            @ToolParam(description = "出生年份，如 1955") int birthYear,
            @ToolParam(description = "出生月份，1-12，如 8") int birthMonth,
            @ToolParam(description = "出生日期，1-31，如 15") int birthDay) {
        try {
            LocalDate birthDate = LocalDate.of(birthYear, birthMonth, birthDay);
            LocalDate today = LocalDate.now();

            if (birthDate.isAfter(today)) {
                return "出生日期不能是未来的日期，请检查输入。";
            }

            Period period = Period.between(birthDate, today);
            int years = period.getYears();
            int months = period.getMonths();
            int days = period.getDays();

            String ageGroup;
            String healthFocus;

            if (years < 60) {
                ageGroup = "中年";
                healthFocus = "这个年龄段应注意预防三高（高血压、高血糖、高血脂），保持健康体重，每年做一次全面体检。";
            } else if (years < 70) {
                ageGroup = "低龄老年（60-69岁）";
                healthFocus = "刚进入老年阶段，身体功能开始逐渐变化。重点关注：心脑血管健康、骨密度检测、视力听力筛查，保持社交活动和适度运动。";
            } else if (years < 80) {
                ageGroup = "中龄老年（70-79岁）";
                healthFocus = "这个阶段要特别注意预防跌倒和骨折，做好慢病管理。建议：家里做好防滑措施，坚持适当运动（如太极、散步），定期监测血压血糖。";
            } else if (years < 90) {
                ageGroup = "高龄老年（80-89岁）";
                healthFocus = "高龄阶段重点是维持生活质量和功能独立性。注意营养均衡（防止肌肉萎缩），预防肺炎和跌倒，多与家人沟通，保持良好心态。";
            } else {
                ageGroup = "超高龄老年（90岁以上）";
                healthFocus = "超高龄是非常值得庆贺的！这个阶段重点是舒适护理、营养支持，保持心情愉快，家人的陪伴和关爱尤为重要。";
            }

            return String.format(
                "【年龄计算结果】%n%n" +
                "🎂 您今年 **%d 岁**（%d个月%d天）%n" +
                "出生日期：%d年%d月%d日%n" +
                "年龄分组：%s%n%n" +
                "📋 健康关注重点：%n%s",
                years, months, days,
                birthYear, birthMonth, birthDay,
                ageGroup, healthFocus
            );
        } catch (Exception e) {
            return "出生日期有误，请检查年月日是否正确（例如2月没有30日）。";
        }
    }

    /**
     * 分析血压值
     */
    @Tool(description = "分析血压测量值是否正常，给出血压分级和专业建议。" +
            "当用户说'我今天量血压是XXX'、'血压多少算正常'、'帮我看看我的血压正常吗'时调用。")
    public String analyzeBloodPressure(
            @ToolParam(description = "收缩压（高压），单位mmHg，例如 135") int systolic,
            @ToolParam(description = "舒张压（低压），单位mmHg，例如 85") int diastolic) {
        if (systolic < 50 || systolic > 300 || diastolic < 30 || diastolic > 200) {
            return "血压数值超出正常测量范围，请检查是否输入正确，或重新测量血压。";
        }

        String grade;
        String emoji;
        String advice;
        String urgency = "";

        if (systolic < 90 || diastolic < 60) {
            grade = "低血压";
            emoji = "⚠️";
            advice = "您的血压偏低。轻度低血压可能引起头晕、乏力、站起时眼前发黑等症状。建议：①适当增加盐分和水分摄入；②起身时动作要缓慢；③避免长时间站立。如经常出现头晕等症状，请及时就医。";
        } else if (systolic < 120 && diastolic < 80) {
            grade = "理想血压（正常偏低）";
            emoji = "✅";
            advice = "您的血压非常理想！保持健康生活方式即可：清淡饮食、适量运动、保持心情愉快、戒烟限酒。";
        } else if (systolic < 130 && diastolic < 85) {
            grade = "正常血压";
            emoji = "✅";
            advice = "您的血压在正常范围内。继续保持良好生活习惯，定期监测血压变化即可。建议每月至少测量2-3次。";
        } else if (systolic < 140 && diastolic < 90) {
            grade = "正常高值（血压偏高）";
            emoji = "🔶";
            advice = "您的血压属于正常高值，虽然还不到高血压标准，但已需要注意。建议：①减少食盐（每天不超过5克）；②控制体重；③减少饮酒；④保持规律运动；⑤定期监测血压，每周至少测2次。";
        } else if (systolic < 160 && diastolic < 100) {
            grade = "1级高血压（轻度）";
            emoji = "🔴";
            advice = "您的血压属于1级高血压。需要在医生指导下进行治疗，一般先通过生活方式干预（低盐饮食、运动、戒烟）1-3个月，如效果不佳则需要药物治疗。请不要自行停药或调整药量！";
        } else if (systolic < 180 && diastolic < 110) {
            grade = "2级高血压（中度）";
            emoji = "🔴";
            advice = "您的血压达到2级高血压，建议尽快就医，通常需要药物治疗配合生活方式改善。请遵医嘱规律服药，不要自行停药！日常需每天监测血压并记录。";
        } else {
            grade = "3级高血压（重度）";
            emoji = "🚨";
            urgency = "\n\n⚠️ 紧急提醒：血压过高！如同时出现头痛剧烈、视力模糊、胸痛、言语不清等症状，请立即拨打120急救！";
            advice = "您的血压严重偏高，属于高血压危象风险范围。如无明显症状，请立即联系您的主治医生或前往医院就诊；" + urgency;
        }

        return String.format(
            "【血压分析结果】%n%n" +
            "%s 您的血压：**%d/%d mmHg**%n" +
            "血压分级：%s%n%n" +
            "参考标准：%n" +
            "· 理想血压：<120/80 mmHg%n" +
            "· 正常血压：<130/85 mmHg%n" +
            "· 正常高值：130-139/85-89 mmHg%n" +
            "· 高血压一级：≥140/90 mmHg%n%n" +
            "📋 建议：%n%s",
            emoji, systolic, diastolic, grade, advice
        );
    }

    /**
     * 计算血糖评估
     */
    @Tool(description = "分析血糖测量值，判断是否在正常范围内，并给出糖尿病相关建议。" +
            "当用户问'我的血糖是多少正常'、'空腹血糖6.5高吗'、'餐后血糖多少算正常'时调用。")
    public String analyzeBloodSugar(
            @ToolParam(description = "血糖值，单位 mmol/L，例如 6.5") double glucoseValue,
            @ToolParam(description = "测量时间类型：空腹（fasting）或 餐后2小时（postprandial）") String measureType) {
        if (glucoseValue < 1 || glucoseValue > 40) {
            return "血糖值超出正常测量范围，请确认数值单位是 mmol/L，并重新测量。";
        }

        boolean isFasting = measureType == null || measureType.contains("空腹") || measureType.contains("fasting");
        String timeLabel = isFasting ? "空腹血糖" : "餐后2小时血糖";

        String status;
        String emoji;
        String advice;

        if (isFasting) {
            if (glucoseValue < 3.9) {
                status = "低血糖";
                emoji = "🚨";
                advice = "血糖过低，可能出现心慌、手抖、出冷汗等症状。请立即进食含糖食物（糖果、果汁），15分钟后重测。如症状未缓解请就医。";
            } else if (glucoseValue < 6.1) {
                status = "正常";
                emoji = "✅";
                advice = "您的空腹血糖正常！继续保持健康饮食和运动习惯。建议每年检测一次空腹血糖。";
            } else if (glucoseValue < 7.0) {
                status = "空腹血糖受损（糖尿病前期）";
                emoji = "🔶";
                advice = "空腹血糖偏高，属于糖尿病前期。需要积极干预：①控制饮食，减少精制碳水化合物；②每天至少30分钟中等强度运动；③每3-6个月复查血糖；④保持健康体重。此阶段干预得当可避免发展为糖尿病！";
            } else {
                status = "糖尿病（需就医确诊）";
                emoji = "🔴";
                advice = "您的空腹血糖达到糖尿病诊断标准，建议尽快到内分泌科就诊进行确诊（需要再次空腹血糖或OGTT检查）。糖尿病需要长期管理，早发现早治疗效果更好！";
            }
        } else {
            // 餐后2小时血糖
            if (glucoseValue < 3.9) {
                status = "低血糖（餐后）";
                emoji = "🚨";
                advice = "餐后血糖过低，属于反应性低血糖，可能与胰岛素分泌过快有关，请就医评估。";
            } else if (glucoseValue < 7.8) {
                status = "正常";
                emoji = "✅";
                advice = "您的餐后2小时血糖正常！继续保持健康的饮食习惯，避免高糖高升糖指数食物。";
            } else if (glucoseValue < 11.1) {
                status = "糖耐量受损（糖尿病前期）";
                emoji = "🔶";
                advice = "餐后血糖偏高，属于糖尿病前期。建议：①减少主食量，选择低GI食物（燕麦、糙米）；②饭后30分钟散步20分钟；③3-6个月复查；④积极减重（如有超重）。";
            } else {
                status = "糖尿病（需就医确诊）";
                emoji = "🔴";
                advice = "餐后血糖明显偏高，需尽快就医检查。请记录近期血糖数值带去就诊，医生会根据情况制定治疗方案。";
            }
        }

        return String.format(
            "【血糖分析结果】%n%n" +
            "%s %s：**%.1f mmol/L**%n" +
            "评估结果：%s%n%n" +
            "参考标准：%n" +
            "· 正常空腹：3.9 - 6.1 mmol/L%n" +
            "· 正常餐后2h：< 7.8 mmol/L%n" +
            "· 糖尿病诊断：空腹 ≥ 7.0 或 餐后 ≥ 11.1 mmol/L%n%n" +
            "📋 建议：%n%s",
            emoji, timeLabel, glucoseValue, status, advice
        );
    }

    /**
     * 计算用药提醒
     */
    @Tool(description = "根据每日服药次数和用餐时间，生成个性化的每日服药时间表。" +
            "当用户问'一天三次饭前服药什么时间吃'、'帮我安排一下用药时间'时调用。")
    public String calculateMedicationSchedule(
            @ToolParam(description = "每日服药次数，如 1、2、3") int timesPerDay,
            @ToolParam(description = "服药时机：饭前（before_meal）、饭后（after_meal）、饭时（with_meal）、空腹（empty_stomach）") String mealTiming,
            @ToolParam(description = "起床时间，格式HH:mm，如 07:00") String wakeUpTime) {
        if (timesPerDay < 1 || timesPerDay > 6) {
            return "每日服药次数通常在1-6次之间，请确认处方说明。";
        }

        // 解析起床时间（默认7:00）
        int wakeHour = 7;
        try {
            if (wakeUpTime != null && wakeUpTime.contains(":")) {
                wakeHour = Integer.parseInt(wakeUpTime.split(":")[0]);
            }
        } catch (Exception ignored) {}

        // 根据起床时间推算三餐时间（基准）
        int breakfastHour = wakeHour + 1;   // 起床1小时后吃早餐
        int lunchHour = 12;
        int dinnerHour = 18;
        int bedHour = wakeHour + 15;         // 起床15小时后睡觉

        String timingLabel;
        int offsetMinutes;  // 相对于餐点的分钟偏移

        switch (mealTiming != null ? mealTiming : "after_meal") {
            case "before_meal" -> { timingLabel = "饭前30分钟"; offsetMinutes = -30; }
            case "with_meal" -> { timingLabel = "随餐（吃饭时一起）"; offsetMinutes = 0; }
            case "empty_stomach" -> { timingLabel = "空腹（晨起空腹）"; offsetMinutes = -60; }
            default -> { timingLabel = "饭后30分钟"; offsetMinutes = 30; }
        }

        StringBuilder sb = new StringBuilder();
        sb.append(String.format("【每日服药时间表】%n"));
        sb.append(String.format("服药次数：每日 %d 次，%s%n%n", timesPerDay, timingLabel));
        sb.append("建议服药时间：\n");

        if (timesPerDay == 1) {
            int hour = "empty_stomach".equals(mealTiming) ? wakeHour : (lunchHour + offsetMinutes / 60);
            sb.append(String.format("· 每日1次：约 %02d:%02d%n", Math.max(6, hour), Math.abs(offsetMinutes % 60)));
        } else if (timesPerDay == 2) {
            int t1 = breakfastHour * 60 + offsetMinutes;
            int t2 = dinnerHour * 60 + offsetMinutes;
            sb.append(String.format("· 第1次：早餐%s，约 %02d:%02d%n", timingLabel, t1 / 60, Math.abs(t1 % 60)));
            sb.append(String.format("· 第2次：晚餐%s，约 %02d:%02d%n", timingLabel, t2 / 60, Math.abs(t2 % 60)));
        } else if (timesPerDay == 3) {
            int t1 = breakfastHour * 60 + offsetMinutes;
            int t2 = lunchHour * 60 + offsetMinutes;
            int t3 = dinnerHour * 60 + offsetMinutes;
            sb.append(String.format("· 第1次：早餐%s，约 %02d:%02d%n", timingLabel, t1 / 60, Math.abs(t1 % 60)));
            sb.append(String.format("· 第2次：午餐%s，约 %02d:%02d%n", timingLabel, t2 / 60, Math.abs(t2 % 60)));
            sb.append(String.format("· 第3次：晚餐%s，约 %02d:%02d%n", timingLabel, t3 / 60, Math.abs(t3 % 60)));
        } else {
            // 4次及以上：均匀分布
            int intervalMinutes = (bedHour - wakeHour) * 60 / timesPerDay;
            int startMinutes = wakeHour * 60 + 60;
            for (int i = 0; i < timesPerDay; i++) {
                int total = startMinutes + i * intervalMinutes;
                sb.append(String.format("· 第%d次：约 %02d:%02d%n", i + 1, total / 60, total % 60));
            }
        }

        sb.append("\n⚠️ 重要提醒：\n");
        sb.append("· 以上为参考时间，请以医生或药品说明书为准\n");
        sb.append("· 尽量固定每天服药时间，不要随意改变\n");
        sb.append("· 如果某次漏服，请根据说明书指引处理，不要自行加倍补服\n");
        sb.append("· 建议设置手机闹钟提醒，避免漏服");

        return sb.toString();
    }
}
