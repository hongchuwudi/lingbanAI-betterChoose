package com.hongchu.cbservice.mapper.health;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.hongchu.cbpojo.entity.health.SleepRecord;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.time.LocalDate;

/**
 * 睡眠记录Mapper
 */
@Mapper
public interface SleepRecordMapper extends BaseMapper<SleepRecord> {
    
    @Select("SELECT * FROM sleep_record WHERE user_id = #{userId} AND record_date = #{date}")
    SleepRecord findByUserIdAndDate(@Param("userId") Long userId, @Param("date") LocalDate date);
}
