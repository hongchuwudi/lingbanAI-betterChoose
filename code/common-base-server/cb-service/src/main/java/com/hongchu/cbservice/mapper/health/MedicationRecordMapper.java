package com.hongchu.cbservice.mapper.health;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.hongchu.cbpojo.entity.health.MedicationRecord;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 用药执行记录Mapper
 */
@Mapper
public interface MedicationRecordMapper extends BaseMapper<MedicationRecord> {
    
    @Select("SELECT * FROM medication_record WHERE user_id = #{userId} AND scheduled_time >= #{startTime} AND scheduled_time < #{endTime} ORDER BY scheduled_time")
    List<MedicationRecord> findByUserIdAndTimeRange(@Param("userId") Long userId, 
                                                      @Param("startTime") LocalDateTime startTime,
                                                      @Param("endTime") LocalDateTime endTime);
}
