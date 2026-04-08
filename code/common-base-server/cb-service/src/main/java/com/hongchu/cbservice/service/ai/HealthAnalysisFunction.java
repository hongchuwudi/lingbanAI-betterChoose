package com.hongchu.cbservice.service.ai;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.hongchu.cbpojo.entity.health.HealthRecord;
import com.hongchu.cbservice.mapper.health.HealthRecordMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Slf4j
@Component
@RequiredArgsConstructor
public class HealthAnalysisFunction {

    private final HealthRecordMapper healthRecordMapper;

    public String getUserHealthData(Long userId, Long parseRecordId) {
        log.info("获取用户健康数据: userId={}, parseRecordId={}", userId, parseRecordId);

        LambdaQueryWrapper<HealthRecord> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(HealthRecord::getUserId, userId)
                .orderByDesc(HealthRecord::getRecordTime)
                .last("LIMIT 50");

        List<HealthRecord> records = healthRecordMapper.selectList(queryWrapper);

        if (records.isEmpty()) {
            return "用户暂无健康记录数据";
        }

        StringBuilder sb = new StringBuilder();
        sb.append("用户健康数据如下：\n\n");

        Map<String, List<HealthRecord>> groupedRecords = records.stream()
                .collect(Collectors.groupingBy(HealthRecord::getIndicatorCode));

        for (Map.Entry<String, List<HealthRecord>> entry : groupedRecords.entrySet()) {
            String indicatorCode = entry.getKey();
            List<HealthRecord> indicatorRecords = entry.getValue();

            sb.append("【").append(getIndicatorName(indicatorCode)).append("】\n");

            for (HealthRecord record : indicatorRecords) {
                String value = record.getValueDecimal() != null 
                        ? record.getValueDecimal().toString() 
                        : record.getValueText();
                String time = record.getRecordTime() != null 
                        ? record.getRecordTime().toString() 
                        : "未知时间";
                sb.append("  - 数值: ").append(value)
                  .append(", 时间: ").append(time).append("\n");
            }
            sb.append("\n");
        }

        sb.append("共计 ").append(records.size()).append(" 条记录。");

        log.info("健康数据获取完成: 共{}条记录", records.size());
        return sb.toString();
    }

    private String getIndicatorName(String code) {
        return switch (code) {
            case "bp_systolic" -> "收缩压";
            case "bp_diastolic" -> "舒张压";
            case "pulse" -> "脉搏";
            case "glucose_fasting" -> "空腹血糖";
            case "glucose_postprandial" -> "餐后血糖";
            case "heart_rate" -> "心率";
            case "weight" -> "体重";
            case "spo2" -> "血氧饱和度";
            case "total_cholesterol" -> "总胆固醇";
            case "triglyceride" -> "甘油三酯";
            case "hdl_cholesterol" -> "高密度脂蛋白";
            case "ldl_cholesterol" -> "低密度脂蛋白";
            case "creatinine" -> "肌酐";
            case "uric_acid" -> "尿酸";
            case "alt" -> "谷丙转氨酶";
            case "ast" -> "谷草转氨酶";
            case "white_blood_cell_count" -> "白细胞计数";
            case "red_blood_cell_count" -> "红细胞计数";
            case "hemoglobin" -> "血红蛋白";
            case "platelet_count" -> "血小板计数";
            default -> code;
        };
    }
}
