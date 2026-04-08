package com.hongchu.cbservice.mapper.health;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.hongchu.cbpojo.entity.health.StepRecord;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.time.LocalDate;

/**
 * 步数记录Mapper
 */
@Mapper
public interface StepRecordMapper extends BaseMapper<StepRecord> {
    
    @Select("SELECT * FROM step_record WHERE user_id = #{userId} AND record_date = #{date}")
    StepRecord findByUserIdAndDate(@Param("userId") Long userId, @Param("date") LocalDate date);
}
