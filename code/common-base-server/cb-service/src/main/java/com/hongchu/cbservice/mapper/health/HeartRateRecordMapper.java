package com.hongchu.cbservice.mapper.health;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.hongchu.cbpojo.entity.health.HeartRateRecord;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * 心率记录Mapper
 */
@Mapper
public interface HeartRateRecordMapper extends BaseMapper<HeartRateRecord> {
    
    @Select("SELECT * FROM heart_rate_record WHERE user_id = #{userId} ORDER BY record_time DESC LIMIT 1")
    HeartRateRecord findLatestByUserId(@Param("userId") Long userId);

    @Select("SELECT * FROM heart_rate_record WHERE user_id = #{userId} ORDER BY record_time DESC LIMIT #{offset}, #{size}")
    List<HeartRateRecord> findByUserIdOrderByRecordTimeDesc(@Param("userId") Long userId, @Param("offset") int offset, @Param("size") int size);
}
