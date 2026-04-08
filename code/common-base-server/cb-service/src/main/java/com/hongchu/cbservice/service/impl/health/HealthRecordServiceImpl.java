package com.hongchu.cbservice.service.impl.health;

import com.hongchu.cbcommon.exception.BusinessException;
import com.hongchu.cbpojo.entity.health.*;
import com.hongchu.cbservice.mapper.health.*;
import com.hongchu.cbservice.service.interfaces.health.IHealthRecordService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class HealthRecordServiceImpl implements IHealthRecordService {

    private final BloodPressureRecordMapper bpMapper;
    private final GlucoseRecordMapper glucoseMapper;
    private final HeartRateRecordMapper heartRateMapper;
    private final WeightRecordMapper weightMapper;
    private final Spo2RecordMapper spo2Mapper;

    @Override
    public void saveHealthRecord(Long userId, Map<String, Object> data) {
        String type = (String) data.get("type");
        if (type == null) {
            throw new BusinessException("缺少记录类型");
        }

        LocalDateTime now = LocalDateTime.now();

        switch (type) {
            case "blood_pressure":
                saveBloodPressure(userId, data, now);
                break;
            case "glucose":
                saveGlucose(userId, data, now);
                break;
            case "heart_rate":
                saveHeartRate(userId, data, now);
                break;
            case "weight":
                saveWeight(userId, data, now);
                break;
            case "spo2":
                saveSpo2(userId, data, now);
                break;
            default:
                throw new BusinessException("未知的记录类型: " + type);
        }
    }

    private void saveBloodPressure(Long userId, Map<String, Object> data, LocalDateTime now) {
        Integer systolic = getInteger(data, "systolic");
        Integer diastolic = getInteger(data, "diastolic");
        Integer pulse = getInteger(data, "pulse");

        if (systolic == null || diastolic == null) {
            throw new BusinessException("血压值不能为空");
        }

        BloodPressureRecord record = BloodPressureRecord.builder()
                .userId(userId)
                .systolic(systolic)
                .diastolic(diastolic)
                .pulse(pulse)
                .recordTime(now)
                .source("manual")
                .createdAt(now)
                .updatedAt(now)
                .build();

        bpMapper.insert(record);
        log.info("保存血压记录成功: userId={}, systolic={}, diastolic={}", userId, systolic, diastolic);
    }

    private void saveGlucose(Long userId, Map<String, Object> data, LocalDateTime now) {
        BigDecimal value = getBigDecimal(data, "value");
        String glucoseType = (String) data.get("glucoseType");

        if (value == null) {
            throw new BusinessException("血糖值不能为空");
        }

        if (glucoseType == null) {
            glucoseType = "fasting";
        }

        GlucoseRecord record = GlucoseRecord.builder()
                .userId(userId)
                .value(value)
                .type(glucoseType)
                .recordTime(now)
                .source("manual")
                .createdAt(now)
                .updatedAt(now)
                .build();

        glucoseMapper.insert(record);
        log.info("保存血糖记录成功: userId={}, value={}, type={}", userId, value, glucoseType);
    }

    private void saveHeartRate(Long userId, Map<String, Object> data, LocalDateTime now) {
        Integer value = getInteger(data, "value");

        if (value == null) {
            throw new BusinessException("心率值不能为空");
        }

        HeartRateRecord record = HeartRateRecord.builder()
                .userId(userId)
                .value(value)
                .recordTime(now)
                .source("manual")
                .createdAt(now)
                .updatedAt(now)
                .build();

        heartRateMapper.insert(record);
        log.info("保存心率记录成功: userId={}, value={}", userId, value);
    }

    private void saveWeight(Long userId, Map<String, Object> data, LocalDateTime now) {
        BigDecimal value = getBigDecimal(data, "value");

        if (value == null) {
            throw new BusinessException("体重值不能为空");
        }

        WeightRecord record = WeightRecord.builder()
                .userId(userId)
                .weight(value)
                .recordTime(now)
                .source("manual")
                .createdAt(now)
                .updatedAt(now)
                .build();

        weightMapper.insert(record);
        log.info("保存体重记录成功: userId={}, value={}", userId, value);
    }

    private void saveSpo2(Long userId, Map<String, Object> data, LocalDateTime now) {
        Integer value = getInteger(data, "value");

        if (value == null) {
            throw new BusinessException("血氧值不能为空");
        }

        Spo2Record record = Spo2Record.builder()
                .userId(userId)
                .value(value)
                .recordTime(now)
                .source("manual")
                .createdAt(now)
                .updatedAt(now)
                .build();

        spo2Mapper.insert(record);
        log.info("保存血氧记录成功: userId={}, value={}", userId, value);
    }

    @Override
    public List<?> getBloodPressureList(Long userId, int page, int size) {
        int offset = (page - 1) * size;
        return bpMapper.findByUserIdOrderByRecordTimeDesc(userId, offset, size);
    }

    @Override
    public List<?> getGlucoseList(Long userId, int page, int size) {
        int offset = (page - 1) * size;
        return glucoseMapper.findByUserIdOrderByRecordTimeDesc(userId, offset, size);
    }

    @Override
    public List<?> getHeartRateList(Long userId, int page, int size) {
        int offset = (page - 1) * size;
        return heartRateMapper.findByUserIdOrderByRecordTimeDesc(userId, offset, size);
    }

    @Override
    public List<?> getWeightList(Long userId, int page, int size) {
        int offset = (page - 1) * size;
        return weightMapper.findByUserIdOrderByRecordTimeDesc(userId, offset, size);
    }

    @Override
    public List<?> getSpo2List(Long userId, int page, int size) {
        int offset = (page - 1) * size;
        return spo2Mapper.findByUserIdOrderByRecordTimeDesc(userId, offset, size);
    }

    @Override
    public void deleteRecord(Long userId, String type, Long id) {
        switch (type) {
            case "blood_pressure":
                BloodPressureRecord bp = bpMapper.selectById(id);
                if (bp == null || !bp.getUserId().equals(userId)) {
                    throw new BusinessException("记录不存在或无权删除");
                }
                bpMapper.deleteById(id);
                break;
            case "glucose":
                GlucoseRecord glucose = glucoseMapper.selectById(id);
                if (glucose == null || !glucose.getUserId().equals(userId)) {
                    throw new BusinessException("记录不存在或无权删除");
                }
                glucoseMapper.deleteById(id);
                break;
            case "heart_rate":
                HeartRateRecord hr = heartRateMapper.selectById(id);
                if (hr == null || !hr.getUserId().equals(userId)) {
                    throw new BusinessException("记录不存在或无权删除");
                }
                heartRateMapper.deleteById(id);
                break;
            case "weight":
                WeightRecord weight = weightMapper.selectById(id);
                if (weight == null || !weight.getUserId().equals(userId)) {
                    throw new BusinessException("记录不存在或无权删除");
                }
                weightMapper.deleteById(id);
                break;
            case "spo2":
                Spo2Record spo2 = spo2Mapper.selectById(id);
                if (spo2 == null || !spo2.getUserId().equals(userId)) {
                    throw new BusinessException("记录不存在或无权删除");
                }
                spo2Mapper.deleteById(id);
                break;
            default:
                throw new BusinessException("未知的记录类型: " + type);
        }
        log.info("删除健康记录成功: userId={}, type={}, id={}", userId, type, id);
    }

    private Integer getInteger(Map<String, Object> data, String key) {
        Object value = data.get(key);
        if (value == null) return null;
        if (value instanceof Integer) return (Integer) value;
        if (value instanceof Number) return ((Number) value).intValue();
        try {
            return Integer.parseInt(value.toString());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private BigDecimal getBigDecimal(Map<String, Object> data, String key) {
        Object value = data.get(key);
        if (value == null) return null;
        if (value instanceof BigDecimal) return (BigDecimal) value;
        if (value instanceof Number) return BigDecimal.valueOf(((Number) value).doubleValue());
        try {
            return new BigDecimal(value.toString());
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
