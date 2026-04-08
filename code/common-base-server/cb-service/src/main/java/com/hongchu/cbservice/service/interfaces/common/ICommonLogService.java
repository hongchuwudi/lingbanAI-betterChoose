package com.hongchu.cbservice.service.interfaces.common;

import com.hongchu.cbpojo.entity.CommonLog;
import com.baomidou.mybatisplus.extension.service.IService;

/**
 * <p>
 * 系统日志表 服务类
 * </p>
 *
 * @author hongchu
 * @since 2026-01-30
 */
public interface ICommonLogService extends IService<CommonLog> {
    // 异步保存日志
    void saveAsync(CommonLog commonLog);
}
