package com.hongchu.cbservice.service.impl.common;

import com.hongchu.cbpojo.entity.CommonLog;
import com.hongchu.cbservice.mapper.CommonLogMapper;
import com.hongchu.cbservice.service.interfaces.common.ICommonLogService;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

/**
 * <p>
 * 系统日志表 服务实现类
 * </p>
 *
 * @author hongchu
 * @since 2026-01-30
 */
@Service
public class CommonLogServiceImpl extends ServiceImpl<CommonLogMapper, CommonLog> implements ICommonLogService {

    // 异步保存日志
    @Async
    @Override
    public void saveAsync(CommonLog commonLog) {
        try {
            // 使用MP提供的save方法
            save(commonLog);
        } catch (Exception e) {
            log.error("异步保存日志失败: {}", e);
        }
    }
}
