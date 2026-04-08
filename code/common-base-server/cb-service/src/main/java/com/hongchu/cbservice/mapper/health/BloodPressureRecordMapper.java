package com.hongchu.cbservice.mapper.health;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.hongchu.cbpojo.entity.health.BloodPressureRecord;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * 血压记录Mapper
 */
@Mapper
public interface BloodPressureRecordMapper extends BaseMapper<BloodPressureRecord> {
    
    @Select("SELECT * FROM blood_pressure_record WHERE user_id = #{userId} ORDER BY record_time DESC LIMIT 1")
    BloodPressureRecord findLatestByUserId(@Param("userId") Long userId);

    @Select("SELECT * FROM blood_pressure_record WHERE user_id = #{userId} ORDER BY record_time DESC LIMIT #{offset}, #{size}")
    List<BloodPressureRecord> findByUserIdOrderByRecordTimeDesc(@Param("userId") Long userId, @Param("offset") int offset, @Param("size") int size);
}
