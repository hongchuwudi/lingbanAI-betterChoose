package com.hongchu.cbservice.mapper.health;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.hongchu.cbpojo.entity.health.HealthRecord;
import org.apache.ibatis.annotations.Mapper;

/**
 * 通用健康记录Mapper
 */
@Mapper
public interface HealthRecordMapper extends BaseMapper<HealthRecord> {
}
