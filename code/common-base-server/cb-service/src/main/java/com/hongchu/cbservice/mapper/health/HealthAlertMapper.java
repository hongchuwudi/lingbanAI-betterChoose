package com.hongchu.cbservice.mapper.health;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.hongchu.cbpojo.entity.health.HealthAlert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * 健康预警Mapper
 */
@Mapper
public interface HealthAlertMapper extends BaseMapper<HealthAlert> {
    
    @Select("SELECT * FROM health_alert WHERE user_id = #{userId} AND status = 0 ORDER BY alert_time DESC LIMIT #{limit}")
    List<HealthAlert> findUnhandledByUserId(@Param("userId") Long userId, @Param("limit") int limit);
}
