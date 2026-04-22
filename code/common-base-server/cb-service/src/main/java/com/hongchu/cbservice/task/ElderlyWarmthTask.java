package com.hongchu.cbservice.task;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.hongchu.cbpojo.entity.ElderlyProfile;
import com.hongchu.cbservice.mapper.ElderlyProfileMapper;
import com.hongchu.cbservice.websocket.SimpleNotifyWS;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.*;

/**
 * 老年人关怀定时消息任务
 * 在一天中的多个时间点，向在线老年用户推送贴心的问候、健康提示和生活提醒。
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class ElderlyWarmthTask {

    private final ElderlyProfileMapper elderlyProfileMapper;
    private final ObjectMapper objectMapper;

    // ─────────────────────────────────────────────────────────────
    //  晨间问候 07:00
    // ─────────────────────────────────────────────────────────────
    @Scheduled(cron = "0 0 7 * * ?")
    public void sendMorningGreeting() {
        String today = LocalDate.now().format(DateTimeFormatter.ofPattern("M月d日"));
        String weekday = getWeekday(LocalDate.now().getDayOfWeek().getValue());
        String[] greetings = {
            "早上好！今天是" + today + "，" + weekday + "，愿您一天精神饱满、心情舒畅 ☀️",
            "新的一天开始了！" + today + "，天气正好，记得开窗通风，呼吸新鲜空气哦~",
            "早安！" + weekday + "的清晨，万物复苏，祝您今天身体棒棒、笑口常开！",
        };
        sendToAllElderly("morning_greeting", "每日晨间问候",
                pickRandom(greetings), "info");
        log.info("[ElderlyWarmthTask] 晨间问候已发送");
    }

    // ─────────────────────────────────────────────────────────────
    //  早餐提醒 07:45
    // ─────────────────────────────────────────────────────────────
    @Scheduled(cron = "0 45 7 * * ?")
    public void sendBreakfastReminder() {
        String[] tips = {
            "该吃早饭了！记得吃热乎乎的早餐，不要空腹喝药哦，身体好才是最重要的 🍳",
            "早饭时间到！建议多吃些杂粮粥、鸡蛋和蔬菜，营养均衡精力足~",
            "早餐是一天的开始，不要忽略哦！慢慢吃，不着急，吃好了再出发 🥣",
        };
        sendToAllElderly("health_reminder", "早餐提醒",
                pickRandom(tips), "info");
        log.info("[ElderlyWarmthTask] 早餐提醒已发送");
    }

    // ─────────────────────────────────────────────────────────────
    //  上午运动提示 09:30
    // ─────────────────────────────────────────────────────────────
    @Scheduled(cron = "0 30 9 * * ?")
    public void sendMorningExerciseTip() {
        String[] tips = {
            "上午好！天气晴好，适合出去走走，做做早操、打打太极，对心肺大有好处 🏃",
            "运动一下吧！每天30分钟的散步，可以有效降低血压、改善睡眠质量哦~",
            "活动活动筋骨！可以做做颈部旋转、肩部拉伸，缓解关节僵硬，预防跌倒 💪",
            "建议去小区花园走走，呼吸新鲜空气，遇见老朋友聊聊天，心情好身体棒！",
        };
        sendToAllElderly("health_reminder", "上午运动提示",
                pickRandom(tips), "info");
        log.info("[ElderlyWarmthTask] 上午运动提示已发送");
    }

    // ─────────────────────────────────────────────────────────────
    //  健康小贴士 10:30
    // ─────────────────────────────────────────────────────────────
    @Scheduled(cron = "0 30 10 * * ?")
    public void sendHealthTip() {
        String[] tips = {
            "💧 记得多喝水！老年人每天建议饮水1500-2000毫升，少量多次，不要等口渴才喝~",
            "🧠 动脑防痴呆！每天读读报纸、听听广播、下下棋，保持大脑活跃很重要哦！",
            "🌞 补充维生素D！晒晒太阳（避开中午强光），有助于钙的吸收，预防骨质疏松~",
            "😴 午休很重要！中午小睡20-30分钟，可以提高下午的精神状态，保护心脑血管~",
            "🥦 今日膳食建议：多吃深色蔬菜（菠菜、西兰花），富含叶酸和铁，对心血管有益！",
            "🦶 泡脚好处多！睡前用温水（40℃左右）泡脚15-20分钟，促进血液循环、改善睡眠~",
            "👁️ 保护眼睛！看电视或手机不超过1小时，每隔30分钟远眺窗外放松眼部肌肉~",
            "🎵 听音乐好处多！舒缓的音乐可以降低血压、缓解焦虑，今天不妨听听喜欢的老歌~",
        };
        sendToAllElderly("health_reminder", "每日健康小贴士",
                pickRandom(tips), "info");
        log.info("[ElderlyWarmthTask] 健康小贴士已发送");
    }

    // ─────────────────────────────────────────────────────────────
    //  午餐提醒 11:45
    // ─────────────────────────────────────────────────────────────
    @Scheduled(cron = "0 45 11 * * ?")
    public void sendLunchReminder() {
        String[] tips = {
            "午饭时间快到了！记得荤素搭配，少油少盐，细嚼慢咽，饭后别马上躺下哦 🍱",
            "中午好！建议今天吃点鱼肉或豆腐，优质蛋白质有助于增强免疫力~",
            "午餐提醒：饭量七八分饱就好，不要吃撑，饭后可以轻轻散散步、消食健胃 🌿",
        };
        sendToAllElderly("health_reminder", "午餐提醒",
                pickRandom(tips), "info");
        log.info("[ElderlyWarmthTask] 午餐提醒已发送");
    }

    // ─────────────────────────────────────────────────────────────
    //  下午关怀问候 15:00
    // ─────────────────────────────────────────────────────────────
    @Scheduled(cron = "0 0 15 * * ?")
    public void sendAfternoonGreeting() {
        String[] messages = {
            "下午好！喝杯温水、看看窗外风景，放松一下，今天有没有什么开心的事情呀？😊",
            "下午茶时间！可以泡杯清淡的绿茶或菊花茶，既解渴又有益健康~",
            "午后时光！如果没有午休，现在可以闭目养神10分钟，恢复一下精力哦 💤",
            "下午好！天气凉了记得添衣，出门溜达记得戴帽子。保暖防风，健康第一！🧣",
        };
        sendToAllElderly("system_notification", "下午关怀问候",
                pickRandom(messages), "info");
        log.info("[ElderlyWarmthTask] 下午关怀已发送");
    }

    // ─────────────────────────────────────────────────────────────
    //  血压/血糖监测提醒 16:00（慢病管理）
    // ─────────────────────────────────────────────────────────────
    @Scheduled(cron = "0 0 16 * * ?")
    public void sendHealthMonitorReminder() {
        String[] messages = {
            "⏰ 下午量血压的好时机！建议坐着休息5分钟后测量，左右臂都测一次，记录在健康本上~",
            "📊 如果您有血糖仪，现在可以测一下餐后血糖（午餐后约2小时），看看数值是否正常~",
            "💊 别忘了今天的健康监测！定期检查血压、血糖是慢性病管理的关键，坚持是良药~",
        };
        sendToAllElderly("health_reminder", "健康监测提醒",
                pickRandom(messages), "warning");
        log.info("[ElderlyWarmthTask] 健康监测提醒已发送");
    }

    // ─────────────────────────────────────────────────────────────
    //  傍晚散步鼓励 17:30
    // ─────────────────────────────────────────────────────────────
    @Scheduled(cron = "0 30 17 * * ?")
    public void sendEveningWalkReminder() {
        String[] messages = {
            "🌇 傍晚好时光！趁着天还亮，去散散步吧，呼吸新鲜空气，活动活动双腿~",
            "🌳 黄昏散步时间！建议走路20-30分钟，速度适中，遇到台阶要注意安全哦！",
            "夕阳无限好！这个时间出去走走，既锻炼身体又能欣赏美景，一举两得 🌅",
        };
        sendToAllElderly("health_reminder", "傍晚散步提醒",
                pickRandom(messages), "info");
        log.info("[ElderlyWarmthTask] 傍晚散步提醒已发送");
    }

    // ─────────────────────────────────────────────────────────────
    //  晚餐提醒 18:00
    // ─────────────────────────────────────────────────────────────
    @Scheduled(cron = "0 0 18 * * ?")
    public void sendDinnerReminder() {
        String[] tips = {
            "晚饭时间到！晚饭宜清淡，建议蒸煮为主，少炒炸；吃个七成饱，睡眠会更好~",
            "🥗 今晚吃什么？推荐来一碗杂粮粥配清炒时蔬，简单营养，消化吸收也好~",
            "晚餐小提醒：饭后不要马上躺下，可以在室内轻轻走动15分钟，有助于消食 🚶",
        };
        sendToAllElderly("health_reminder", "晚餐提醒",
                pickRandom(tips), "info");
        log.info("[ElderlyWarmthTask] 晚餐提醒已发送");
    }

    // ─────────────────────────────────────────────────────────────
    //  晚间关怀 20:00
    // ─────────────────────────────────────────────────────────────
    @Scheduled(cron = "0 0 20 * * ?")
    public void sendEveningCare() {
        String[] messages = {
            "晚上好！今天辛苦了，休息一下，看看电视或者和家人聊聊天，放松心情 ❤️",
            "🌙 夜幕降临，记得关好门窗，室内温度保持在18-22℃最舒适。祝您晚上好！",
            "温馨提示：睡前不要刷太长时间手机，建议9点后调暗屏幕亮度，让眼睛也休息哦~",
            "晚间问候：今天感觉怎么样？如有哪里不舒服，记得告诉家人，不要自己扛着哦 💕",
        };
        sendToAllElderly("system_notification", "晚间关怀",
                pickRandom(messages), "info");
        log.info("[ElderlyWarmthTask] 晚间关怀已发送");
    }

    // ─────────────────────────────────────────────────────────────
    //  睡眠提醒 21:30
    // ─────────────────────────────────────────────────────────────
    @Scheduled(cron = "0 30 21 * * ?")
    public void sendSleepReminder() {
        String[] messages = {
            "😴 准备休息啦！建议10点前入睡，保证7-8小时睡眠。睡前可以泡个脚，有助于入睡~",
            "晚安提醒：睡前记得关好煤气、锁好门，不要在床上吸烟。祝您一觉睡到自然醒！🌛",
            "🛏️ 睡前小提示：睡姿以侧卧为宜，枕头高度适中，有助于预防打鼾和颈椎不适~",
            "今天的灵伴服务到这里啦！晚安，好梦！明天我们再见 🌟",
        };
        sendToAllElderly("system_notification", "睡眠提醒",
                pickRandom(messages), "info");
        log.info("[ElderlyWarmthTask] 睡眠提醒已发送");
    }

    // ─────────────────────────────────────────────────────────────
    //  每周一：本周健康计划鼓励 08:30
    // ─────────────────────────────────────────────────────────────
    @Scheduled(cron = "0 30 8 * * MON")
    public void sendWeeklyHealthPlan() {
        String message = "🗓️ 新的一周开始了！本周健康小目标：\n"
                + "①每天散步30分钟\n"
                + "②每天喝足8杯水\n"
                + "③按时服药不漏服\n"
                + "④保持心情愉快\n"
                + "一起加油！您是最棒的 💪";
        sendToAllElderly("system_notification", "本周健康计划", message, "info");
        log.info("[ElderlyWarmthTask] 每周健康计划已发送");
    }

    // ─────────────────────────────────────────────────────────────
    //  工具方法
    // ─────────────────────────────────────────────────────────────

    /**
     * 向所有老年用户（有 elderly_profile 记录的）发送 WS 消息。
     * 只发给当前在线的用户，避免无效推送。
     */
    private void sendToAllElderly(String type, String title, String content, String level) {
        try {
            // 查所有老年用户ID
            List<ElderlyProfile> profiles = elderlyProfileMapper.selectList(
                    new LambdaQueryWrapper<ElderlyProfile>()
                            .select(ElderlyProfile::getUserId));

            if (profiles.isEmpty()) {
                log.debug("[ElderlyWarmthTask] 没有老年用户，跳过推送");
                return;
            }

            // 构造消息 JSON
            Map<String, Object> data = new HashMap<>();
            data.put("title", title);
            data.put("content", content);
            data.put("level", level);

            Map<String, Object> message = new HashMap<>();
            message.put("type", type);
            message.put("data", data);
            message.put("timestamp", System.currentTimeMillis());

            String json = objectMapper.writeValueAsString(message);

            int sent = 0;
            for (ElderlyProfile profile : profiles) {
                String userId = String.valueOf(profile.getUserId());
                if (SimpleNotifyWS.isUserOnline(userId)) {
                    SimpleNotifyWS.notifyUser(userId, json);
                    sent++;
                }
            }
            log.info("[ElderlyWarmthTask] 推送「{}」完成，在线发送 {}/{} 人",
                    title, sent, profiles.size());
        } catch (Exception e) {
            log.error("[ElderlyWarmthTask] 推送消息失败: {}", e.getMessage(), e);
        }
    }

    private String pickRandom(String[] arr) {
        return arr[new Random().nextInt(arr.length)];
    }

    private String getWeekday(int dayOfWeek) {
        return switch (dayOfWeek) {
            case 1 -> "星期一";
            case 2 -> "星期二";
            case 3 -> "星期三";
            case 4 -> "星期四";
            case 5 -> "星期五";
            case 6 -> "星期六";
            case 7 -> "星期日";
            default -> "";
        };
    }
}
