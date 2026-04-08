package com.hongchu.cbservice.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.hongchu.cbpojo.entity.FrontendSettings;
import org.apache.ibatis.annotations.Mapper;

/**
 * 前端设置表 Mapper 接口
 */
@Mapper
public interface FrontendSettingsMapper extends BaseMapper<FrontendSettings> {
}