package com.hongchu.cbservice.mapper.health;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.hongchu.cbpojo.entity.health.GlucoseRecord;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * 血糖记录Mapper
 */
@Mapper
public interface GlucoseRecordMapper extends BaseMapper<GlucoseRecord> {
    
    @Select("SELECT * FROM glucose_record WHERE user_id = #{userId} ORDER BY record_time DESC LIMIT 1")
    GlucoseRecord findLatestByUserId(@Param("userId") Long userId);

    @Select("SELECT * FROM glucose_record WHERE user_id = #{userId} ORDER BY record_time DESC LIMIT #{offset}, #{size}")
    List<GlucoseRecord> findByUserIdOrderByRecordTimeDesc(@Param("userId") Long userId, @Param("offset") int offset, @Param("size") int size);
}
