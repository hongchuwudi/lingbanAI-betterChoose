package com.hongchu.cbservice.service.interfaces.health;

import java.util.List;
import java.util.Map;

/**
 * 健康记录服务接口
 */
public interface IHealthRecordService {
    
    /**
     * 保存健康记录
     */
    void saveHealthRecord(Long userId, Map<String, Object> data);
    
    /**
     * 获取血压记录列表
     */
    List<?> getBloodPressureList(Long userId, int page, int size);
    
    /**
     * 获取血糖记录列表
     */
    List<?> getGlucoseList(Long userId, int page, int size);
    
    /**
     * 获取心率记录列表
     */
    List<?> getHeartRateList(Long userId, int page, int size);
    
    /**
     * 获取体重记录列表
     */
    List<?> getWeightList(Long userId, int page, int size);
    
    /**
     * 获取血氧记录列表
     */
    List<?> getSpo2List(Long userId, int page, int size);
    
    /**
     * 删除记录
     */
    void deleteRecord(Long userId, String type, Long id);
}
