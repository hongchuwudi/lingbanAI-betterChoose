package com.hongchu.cbservice.mapper.health;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.hongchu.cbpojo.entity.health.MedicationPlan;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * 用药计划Mapper
 */
@Mapper
public interface MedicationPlanMapper extends BaseMapper<MedicationPlan> {
    
    @Select("SELECT * FROM medication_plan WHERE user_id = #{userId} AND is_active = true AND start_date <= CURRENT_DATE AND (end_date IS NULL OR end_date >= CURRENT_DATE)")
    List<MedicationPlan> findActiveByUserId(@Param("userId") Long userId);
}
