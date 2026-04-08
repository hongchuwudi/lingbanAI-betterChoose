package com.hongchu.cbservice.mapper.health;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.hongchu.cbpojo.entity.health.WeightRecord;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * 体重记录Mapper
 */
@Mapper
public interface WeightRecordMapper extends BaseMapper<WeightRecord> {
    
    @Select("SELECT * FROM weight_record WHERE user_id = #{userId} ORDER BY record_time DESC LIMIT 1")
    WeightRecord findLatestByUserId(@Param("userId") Long userId);

    @Select("SELECT * FROM weight_record WHERE user_id = #{userId} ORDER BY record_time DESC LIMIT #{offset}, #{size}")
    List<WeightRecord> findByUserIdOrderByRecordTimeDesc(@Param("userId") Long userId, @Param("offset") int offset, @Param("size") int size);
}
