package com.hongchu.cbservice.mapper.health;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.hongchu.cbpojo.entity.health.Spo2Record;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * 血氧记录Mapper
 */
@Mapper
public interface Spo2RecordMapper extends BaseMapper<Spo2Record> {
    
    @Select("SELECT * FROM spo2_record WHERE user_id = #{userId} ORDER BY record_time DESC LIMIT 1")
    Spo2Record findLatestByUserId(@Param("userId") Long userId);

    @Select("SELECT * FROM spo2_record WHERE user_id = #{userId} ORDER BY record_time DESC LIMIT #{offset}, #{size}")
    List<Spo2Record> findByUserIdOrderByRecordTimeDesc(@Param("userId") Long userId, @Param("offset") int offset, @Param("size") int size);
}
