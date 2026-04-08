package com.hongchu.cbservice.service.interfaces.health;

import com.hongchu.cbpojo.vo.health.HealthDashboardVO;

/**
 * 健康服务接口
 */
public interface IHealthService {
    
    /**
     * 获取健康看板数据
     */
    HealthDashboardVO getDashboard(Long userId);
}
