package com.hongchu.cbservice.tools;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.tool.annotation.Tool;
import org.springframework.ai.tool.annotation.ToolParam;
import org.springframework.stereotype.Component;

import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Map;

/**
 * 天气查询工具
 * 使用 Open-Meteo（完全免费，无需 API Key）查询城市天气
 * 支持中国主要城市及全球城市
 */
@Component
@Slf4j
@RequiredArgsConstructor
public class WeatherTool {

    private final ObjectMapper objectMapper;

    // 常见中国城市的经纬度预置（避免频繁请求 geocoding 接口）
    private static final Map<String, double[]> CITY_COORDS = Map.ofEntries(
        Map.entry("北京",   new double[]{39.9042, 116.4074}),
        Map.entry("上海",   new double[]{31.2304, 121.4737}),
        Map.entry("广州",   new double[]{23.1291, 113.2644}),
        Map.entry("深圳",   new double[]{22.5431, 114.0579}),
        Map.entry("成都",   new double[]{30.5728, 104.0668}),
        Map.entry("杭州",   new double[]{30.2741, 120.1551}),
        Map.entry("武汉",   new double[]{30.5928, 114.3055}),
        Map.entry("南京",   new double[]{32.0603, 118.7969}),
        Map.entry("西安",   new double[]{34.3416, 108.9398}),
        Map.entry("重庆",   new double[]{29.5630, 106.5516}),
        Map.entry("天津",   new double[]{39.3434, 117.3616}),
        Map.entry("苏州",   new double[]{31.2990, 120.5853}),
        Map.entry("郑州",   new double[]{34.7472, 113.6249}),
        Map.entry("长沙",   new double[]{28.2280, 112.9388}),
        Map.entry("济南",   new double[]{36.6512, 117.1201}),
        Map.entry("青岛",   new double[]{36.0671, 120.3826}),
        Map.entry("沈阳",   new double[]{41.8057, 123.4315}),
        Map.entry("哈尔滨", new double[]{45.8038, 126.5349}),
        Map.entry("长春",   new double[]{43.8171, 125.3235}),
        Map.entry("大连",   new double[]{38.9140, 121.6147}),
        Map.entry("昆明",   new double[]{25.0389, 102.7183}),
        Map.entry("贵阳",   new double[]{26.6470, 106.6302}),
        Map.entry("南昌",   new double[]{28.6820, 115.8579}),
        Map.entry("合肥",   new double[]{31.8206, 117.2272}),
        Map.entry("福州",   new double[]{26.0745, 119.2965}),
        Map.entry("厦门",   new double[]{24.4798, 118.0894}),
        Map.entry("南宁",   new double[]{22.8170, 108.3665}),
        Map.entry("海口",   new double[]{20.0444, 110.1999}),
        Map.entry("乌鲁木齐", new double[]{43.8256, 87.6168}),
        Map.entry("呼和浩特", new double[]{40.8426, 111.7520}),
        Map.entry("银川",   new double[]{38.4872, 106.2309}),
        Map.entry("兰州",   new double[]{36.0611, 103.8343}),
        Map.entry("西宁",   new double[]{36.6171, 101.7782}),
        Map.entry("拉萨",   new double[]{29.6520, 91.1723}),
        Map.entry("太原",   new double[]{37.8706, 112.5489}),
        Map.entry("石家庄", new double[]{38.0428, 114.5149}),
        Map.entry("南通",   new double[]{32.0161, 120.8636}),
        Map.entry("温州",   new double[]{28.0000, 120.6720}),
        Map.entry("宁波",   new double[]{29.8683, 121.5440}),
        Map.entry("佛山",   new double[]{23.0219, 113.1219})
    );

    // WMO 天气代码 → 中文描述
    private static final Map<Integer, String> WEATHER_CODE_DESC = Map.ofEntries(
        Map.entry(0, "晴空万里☀️"),
        Map.entry(1, "基本晴朗🌤️"),
        Map.entry(2, "局部多云⛅"),
        Map.entry(3, "阴天☁️"),
        Map.entry(45, "雾天🌫️"),
        Map.entry(48, "雾凇🌫️"),
        Map.entry(51, "小毛毛雨🌦️"),
        Map.entry(53, "毛毛雨🌦️"),
        Map.entry(55, "大毛毛雨🌧️"),
        Map.entry(61, "小雨🌧️"),
        Map.entry(63, "中雨🌧️"),
        Map.entry(65, "大雨🌧️"),
        Map.entry(71, "小雪❄️"),
        Map.entry(73, "中雪❄️"),
        Map.entry(75, "大雪❄️"),
        Map.entry(77, "雪粒❄️"),
        Map.entry(80, "阵雨🌦️"),
        Map.entry(81, "中阵雨🌧️"),
        Map.entry(82, "强阵雨🌧️"),
        Map.entry(85, "小阵雪🌨️"),
        Map.entry(86, "大阵雪🌨️"),
        Map.entry(95, "雷阵雨⛈️"),
        Map.entry(96, "雷雨夹冰雹⛈️"),
        Map.entry(99, "强雷雨夹冰雹⛈️")
    );

    /**
     * 查询城市当前天气
     */
    @Tool(description = "查询指定城市的当前天气和未来三天天气预报，包括温度、天气状况、湿度、风速等信息。" +
            "当用户问'今天天气怎么样'、'明天会不会下雨'、'外面冷不冷'等天气相关问题时调用。")
    public String getCurrentWeather(
            @ToolParam(description = "城市名称，支持中国各城市，如：北京、上海、广州、成都等") String cityName) {
        try {
            double[] coords = resolveCityCoords(cityName);
            if (coords == null) {
                return String.format("抱歉，暂时无法获取【%s】的天气信息。建议您打开手机天气应用查看，或收听广播天气预报。", cityName);
            }

            String url = buildWeatherUrl(coords[0], coords[1]);
            String responseBody = fetchUrl(url);
            if (responseBody == null) {
                return "天气服务暂时不可用，请稍后再试，或收听本地广播天气预报。";
            }

            return parseWeatherResponse(cityName, responseBody);
        } catch (Exception e) {
            log.warn("天气查询失败，城市: {}, 原因: {}", cityName, e.getMessage());
            return String.format("获取【%s】天气信息时遇到问题，请稍后重试。建议您查看手机天气应用获取准确信息。", cityName);
        }
    }

    /**
     * 根据天气给出老年人健康建议
     */
    @Tool(description = "根据某城市的天气情况，为老年人提供健康出行和日常生活建议，如是否适合外出、穿衣保暖、运动注意事项等。" +
            "当用户问'今天适合出去散步吗'、'要不要带伞'、'天冷了要注意什么'等问题时调用。")
    public String getWeatherHealthAdvice(
            @ToolParam(description = "城市名称，如北京、上海等") String cityName) {
        try {
            double[] coords = resolveCityCoords(cityName);
            if (coords == null) {
                return String.format("无法获取【%s】天气数据，建议您查看手机天气应用后根据实际天气情况做决定。", cityName);
            }

            String url = buildWeatherUrl(coords[0], coords[1]);
            String responseBody = fetchUrl(url);
            if (responseBody == null) {
                return "天气服务暂时不可用，请稍后再试。";
            }

            JsonNode root = objectMapper.readTree(responseBody);
            JsonNode current = root.path("current");

            double temp = current.path("temperature_2m").asDouble();
            double humidity = current.path("relative_humidity_2m").asDouble();
            double windSpeed = current.path("wind_speed_10m").asDouble();
            int weatherCode = current.path("weather_code").asInt();
            double precip = current.path("precipitation").asDouble();

            String weatherDesc = WEATHER_CODE_DESC.getOrDefault(weatherCode, "天气状况未知");
            StringBuilder advice = new StringBuilder();
            advice.append(String.format("【%s今日天气健康提示】%n", cityName));
            advice.append(String.format("当前天气：%s，气温 %.0f°C%n%n", weatherDesc, temp));

            // 温度建议
            if (temp <= 0) {
                advice.append("🧥 **穿衣**：天气严寒，请穿厚羽绒服，戴帽子、手套，注意防寒保暖，预防冻伤。\n");
            } else if (temp <= 10) {
                advice.append("🧥 **穿衣**：天气较冷，建议穿厚外套，注意颈部和腰部保暖。\n");
            } else if (temp <= 18) {
                advice.append("🧥 **穿衣**：天气凉爽，建议穿薄外套或毛衣，早晚适当加衣。\n");
            } else if (temp <= 28) {
                advice.append("🧥 **穿衣**：气温适宜，穿薄衫即可，注意保持舒适。\n");
            } else if (temp <= 35) {
                advice.append("🧥 **穿衣**：天气较热，穿透气轻薄的衣物，注意防晒。\n");
            } else {
                advice.append("🌡️ **穿衣**：高温天气！穿宽松透气衣物，避免在烈日下长时间外出，预防中暑。\n");
            }

            // 降水建议
            if (precip > 0 || weatherCode >= 51) {
                advice.append("☂️ **出行**：有降水，出门请带好雨伞，路面湿滑，走路要小心，防止跌倒。\n");
            } else if (weatherCode <= 1) {
                if (temp >= 10 && temp <= 28) {
                    advice.append("🚶 **出行**：天气晴好，是散步、做操的好时机，建议上午9-11点出行。\n");
                } else {
                    advice.append("🚶 **出行**：天气晴朗，可以外出，注意按温度适当着装。\n");
                }
            }

            // 风速建议
            if (windSpeed > 30) {
                advice.append("💨 **注意**：风力较大，外出要注意安全，帽子、围巾要系好。有心脑血管病史者减少外出。\n");
            } else if (windSpeed > 20) {
                advice.append("💨 **注意**：有一定风力，外出注意保暖，避免风直吹头颈部。\n");
            }

            // 湿度建议
            if (humidity > 85) {
                advice.append("💧 **湿度**：空气潮湿，关节炎患者注意关节保暖，室内注意通风除湿。\n");
            } else if (humidity < 30) {
                advice.append("💧 **湿度**：空气较干燥，多喝水，可使用加湿器，注意皮肤和嗓子的保湿。\n");
            }

            // 极端天气警告
            if (temp >= 37 || (temp <= -5 && windSpeed > 20)) {
                advice.append("\n⚠️ **特别提醒**：今日天气较为极端，建议减少外出，如有不适请及时就医。");
            }

            return advice.toString();
        } catch (Exception e) {
            log.warn("天气健康建议生成失败: {}", e.getMessage());
            return "获取天气信息时遇到问题，请参考手机天气应用后，根据实际天气情况做适当安排。";
        }
    }

    // ─── 内部辅助方法 ─────────────────────────────────────────

    private double[] resolveCityCoords(String cityName) {
        // 1. 精确匹配预置城市
        if (CITY_COORDS.containsKey(cityName)) {
            return CITY_COORDS.get(cityName);
        }
        // 2. 去掉"市"后缀再匹配
        String stripped = cityName.replace("市", "").replace("区", "").replace("县", "");
        if (CITY_COORDS.containsKey(stripped)) {
            return CITY_COORDS.get(stripped);
        }
        // 3. 模糊匹配（城市名包含关系）
        for (Map.Entry<String, double[]> entry : CITY_COORDS.entrySet()) {
            if (cityName.contains(entry.getKey()) || entry.getKey().contains(stripped)) {
                return entry.getValue();
            }
        }
        // 4. 尝试通过 Open-Meteo Geocoding 接口获取
        return fetchCityCoords(cityName);
    }

    private double[] fetchCityCoords(String cityName) {
        try {
            String encodedCity = URLEncoder.encode(cityName, StandardCharsets.UTF_8);
            String url = "https://geocoding-api.open-meteo.com/v1/search?name=" + encodedCity
                + "&count=1&language=zh&format=json";
            String body = fetchUrl(url);
            if (body == null) return null;

            JsonNode root = objectMapper.readTree(body);
            JsonNode results = root.path("results");
            if (results.isEmpty()) return null;

            JsonNode first = results.get(0);
            return new double[]{first.path("latitude").asDouble(), first.path("longitude").asDouble()};
        } catch (Exception e) {
            log.debug("Geocoding 查询失败: {}", e.getMessage());
            return null;
        }
    }

    private String buildWeatherUrl(double lat, double lon) {
        return String.format(
            "https://api.open-meteo.com/v1/forecast" +
            "?latitude=%.4f&longitude=%.4f" +
            "&current=temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m" +
            "&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_sum" +
            "&timezone=Asia%%2FShanghai&forecast_days=4",
            lat, lon
        );
    }

    private String parseWeatherResponse(String cityName, String body) throws Exception {
        JsonNode root = objectMapper.readTree(body);
        JsonNode current = root.path("current");
        JsonNode daily = root.path("daily");

        double temp = current.path("temperature_2m").asDouble();
        double feelsLike = current.path("apparent_temperature").asDouble();
        double humidity = current.path("relative_humidity_2m").asDouble();
        double windSpeed = current.path("wind_speed_10m").asDouble();
        int weatherCode = current.path("weather_code").asInt();
        double precip = current.path("precipitation").asDouble();

        String weatherDesc = WEATHER_CODE_DESC.getOrDefault(weatherCode, "天气状况未知");

        StringBuilder sb = new StringBuilder();
        sb.append(String.format("【%s当前天气】%n", cityName));
        sb.append(String.format("天气状况：%s%n", weatherDesc));
        sb.append(String.format("气温：%.0f°C（体感 %.0f°C）%n", temp, feelsLike));
        sb.append(String.format("湿度：%.0f%%%n", humidity));
        sb.append(String.format("风速：%.0f km/h%n", windSpeed));
        if (precip > 0) {
            sb.append(String.format("当前降水：%.1f mm%n", precip));
        }

        // 三天预报
        sb.append("\n【近三天天气预报】\n");
        JsonNode dates = daily.path("time");
        JsonNode maxTemps = daily.path("temperature_2m_max");
        JsonNode minTemps = daily.path("temperature_2m_min");
        JsonNode dayCodes = daily.path("weather_code");
        JsonNode precipSums = daily.path("precipitation_sum");

        String[] dayNames = {"今天", "明天", "后天"};
        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("MM月dd日");

        for (int i = 0; i < Math.min(3, dayNames.length); i++) {
            String date = dates.path(i).asText();
            double max = maxTemps.path(i).asDouble();
            double min = minTemps.path(i).asDouble();
            int code = dayCodes.path(i).asInt();
            double rain = precipSums.path(i).asDouble();
            String desc = WEATHER_CODE_DESC.getOrDefault(code, "未知");

            String dateStr = "";
            try {
                LocalDate d = LocalDate.parse(date);
                dateStr = d.format(fmt);
            } catch (Exception ignored) {
                dateStr = date;
            }

            sb.append(String.format("· %s（%s）：%s，%.0f~%.0f°C", dayNames[i], dateStr, desc, min, max));
            if (rain > 0.5) sb.append(String.format("，降水 %.0fmm", rain));
            sb.append("\n");
        }

        return sb.toString();
    }

    private String fetchUrl(String url) {
        try {
            HttpClient client = HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(8))
                .followRedirects(HttpClient.Redirect.NORMAL)
                .build();
            HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .header("User-Agent", "LingbanHealthApp/1.0")
                .timeout(Duration.ofSeconds(10))
                .GET()
                .build();
            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() == 200) {
                return response.body();
            }
            log.warn("HTTP请求失败，状态码: {}, URL: {}", response.statusCode(), url);
            return null;
        } catch (Exception e) {
            log.warn("HTTP请求异常: {}, URL: {}", e.getMessage(), url);
            return null;
        }
    }
}
