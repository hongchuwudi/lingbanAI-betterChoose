package com.hongchu.cbservice.tools;

import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.tool.annotation.Tool;
import org.springframework.ai.tool.annotation.ToolParam;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;

/**
 * 日期时间工具
 * 提供当前时间查询、日期倒计时等功能
 */
@Component
@Slf4j
public class DateTimeTool {

    private static final String[] WEEK_NAMES = {"", "星期一", "星期二", "星期三", "星期四", "星期五", "星期六", "星期日"};
    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("yyyy年MM月dd日");
    private static final DateTimeFormatter TIME_FORMATTER = DateTimeFormatter.ofPattern("HH:mm");

    /**
     * 获取当前完整日期时间
     */
    @Tool(description = "获取当前的日期和时间，包括年月日、几时几分、星期几。当用户问'今天几号'、'现在几点'、'今天是什么日子'等问题时调用。")
    public String getCurrentDateTime() {
        LocalDateTime now = LocalDateTime.now();
        String weekDay = WEEK_NAMES[now.getDayOfWeek().getValue()];
        String timeOfDay = getTimeOfDay(now.getHour());
        String season = getSeason(now.getMonthValue());

        return String.format(
            "现在是 %s %s，%s好！%n" +
            "· 日期：%d年%d月%d日%n" +
            "· 时间：%s%n" +
            "· 星期：%s%n" +
            "· 季节：%s",
            DATE_FORMATTER.format(now), weekDay, timeOfDay,
            now.getYear(), now.getMonthValue(), now.getDayOfMonth(),
            TIME_FORMATTER.format(now),
            weekDay,
            season
        );
    }

    /**
     * 获取今天简要信息
     */
    @Tool(description = "查询今天是几月几号、星期几。当用户问'今天星期几'、'今天几号'时调用。")
    public String getTodayInfo() {
        LocalDate today = LocalDate.now();
        String weekDay = WEEK_NAMES[today.getDayOfWeek().getValue()];
        String season = getSeason(today.getMonthValue());
        boolean isWeekend = today.getDayOfWeek().getValue() >= 6;

        return String.format(
            "今天是 %d年%d月%d日，%s。%n当前季节：%s。%s",
            today.getYear(), today.getMonthValue(), today.getDayOfMonth(),
            weekDay, season,
            isWeekend ? "今天是周末，可以好好休息一下！" : "今天是工作日。"
        );
    }

    /**
     * 计算距离目标日期的天数
     */
    @Tool(description = "计算距离某个重要日期还有多少天，适用于提醒复查日期、服药截止日、节日倒计时等场景。")
    public String daysUntilDate(
            @ToolParam(description = "目标日期，格式为 yyyy-MM-dd，例如 2025-06-01") String targetDate,
            @ToolParam(description = "日期的用途说明，例如：复查日、服药结束日、生日等") String purpose) {
        try {
            LocalDate target = LocalDate.parse(targetDate);
            LocalDate today = LocalDate.now();
            long days = ChronoUnit.DAYS.between(today, target);

            String purposeText = (purpose != null && !purpose.isBlank()) ? purpose : "目标日期";

            if (days < 0) {
                return String.format("%s（%s）已经过去了 %d 天。", purposeText, targetDate, Math.abs(days));
            } else if (days == 0) {
                return String.format("今天就是您的%s（%s）！请不要忘记！", purposeText, targetDate);
            } else if (days <= 3) {
                return String.format("您的%s（%s）快到了，还有 %d 天，请做好准备！", purposeText, targetDate, days);
            } else if (days <= 7) {
                return String.format("距离您的%s（%s）还有 %d 天（不到一周）。", purposeText, targetDate, days);
            } else {
                long weeks = days / 7;
                long remainDays = days % 7;
                String weekInfo = weeks > 0 ? String.format("约 %d 周", weeks) : "";
                String dayInfo = remainDays > 0 ? String.format("%d 天", remainDays) : "";
                String combined = weekInfo + (!weekInfo.isEmpty() && !dayInfo.isEmpty() ? "零" : "") + dayInfo;
                return String.format("距离您的%s（%s）还有 %d 天（%s）。", purposeText, targetDate, days, combined);
            }
        } catch (Exception e) {
            log.warn("日期解析失败: {}", targetDate);
            return "日期格式有误，请使用 yyyy-MM-dd 格式，例如 2025-06-01。";
        }
    }

    /**
     * 查询某月某日是星期几
     */
    @Tool(description = "查询某个具体日期是星期几，例如查询某个预约日期是不是周末。")
    public String getDayOfWeekForDate(
            @ToolParam(description = "要查询的日期，格式为 yyyy-MM-dd，例如 2025-08-15") String date) {
        try {
            LocalDate target = LocalDate.parse(date);
            String weekDay = WEEK_NAMES[target.getDayOfWeek().getValue()];
            boolean isWeekend = target.getDayOfWeek().getValue() >= 6;
            LocalDate today = LocalDate.now();
            long days = ChronoUnit.DAYS.between(today, target);

            String relativeInfo = "";
            if (days == 0) relativeInfo = "（今天）";
            else if (days == 1) relativeInfo = "（明天）";
            else if (days == -1) relativeInfo = "（昨天）";
            else if (days > 0) relativeInfo = String.format("（%d天后）", days);
            else relativeInfo = String.format("（%d天前）", Math.abs(days));

            return String.format("%s%s 是 %s。%s",
                target.format(DATE_FORMATTER), relativeInfo, weekDay,
                isWeekend ? "这天是周末。" : "这天是工作日。");
        } catch (Exception e) {
            return "日期格式有误，请使用 yyyy-MM-dd 格式，例如 2025-08-15。";
        }
    }

    // ─── 辅助方法 ───────────────────────────────────────────────

    private String getTimeOfDay(int hour) {
        if (hour >= 5 && hour < 9) return "清晨";
        if (hour >= 9 && hour < 12) return "上午";
        if (hour >= 12 && hour < 14) return "中午";
        if (hour >= 14 && hour < 17) return "下午";
        if (hour >= 17 && hour < 20) return "傍晚";
        if (hour >= 20 && hour < 23) return "晚上";
        return "深夜";
    }

    private String getSeason(int month) {
        if (month >= 3 && month <= 5) return "春季";
        if (month >= 6 && month <= 8) return "夏季";
        if (month >= 9 && month <= 11) return "秋季";
        return "冬季";
    }
}
