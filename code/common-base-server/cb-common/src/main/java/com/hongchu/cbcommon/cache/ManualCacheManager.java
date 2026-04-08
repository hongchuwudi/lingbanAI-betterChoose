// ManualCacheManager.java
package com.hongchu.cbcommon.cache;

import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.TimeUnit;

@Slf4j
@Component
public class ManualCacheManager {
    
    private final Map<String, CacheEntry<?>> cache = new ConcurrentHashMap<>();
    
    /**
     * 保存数据到缓存
     */
    public <T> void put(String key, T value, long timeout, TimeUnit unit) {
        long expireTime = System.currentTimeMillis() + unit.toMillis(timeout);
        cache.put(key, new CacheEntry<>(value, expireTime));
        log.debug("缓存保存成功，key: {}, 过期时间: {}ms", key, unit.toMillis(timeout));
    }
    
    /**
     * 获取缓存数据
     */
    @SuppressWarnings("unchecked")
    public <T> T get(String key) {
        CacheEntry<?> entry = cache.get(key);
        if (entry == null) {
            log.debug("缓存未命中，key: {}", key);
            return null;
        }
        
        if (entry.isExpired()) {
            cache.remove(key);
            log.debug("缓存已过期，key: {}", key);
            return null;
        }
        
        log.debug("缓存命中，key: {}", key);
        return (T) entry.getData();
    }
    
    /**
     * 删除缓存数据
     */
    public void delete(String key) {
        cache.remove(key);
        log.debug("缓存删除成功，key: {}", key);
    }
    
    /**
     * 检查缓存是否存在且未过期
     */
    public boolean contains(String key) {
        CacheEntry<?> entry = cache.get(key);
        if (entry == null) {
            return false;
        }
        
        if (entry.isExpired()) {
            cache.remove(key);
            return false;
        }
        
        return true;
    }
    
    /**
     * 清理所有过期缓存（定时任务）
     */
    @Scheduled(fixedRate = 600000) // 每10分钟执行一次
    public void cleanExpiredCache() {
        int initialSize = cache.size();
        cache.entrySet().removeIf(entry -> entry.getValue().isExpired());
        int cleanedCount = initialSize - cache.size();
        
        if (cleanedCount > 0) {
            log.info("清理了 {} 个过期缓存条目，当前缓存大小: {}", cleanedCount, cache.size());
        }
    }
    
    /**
     * 获取当前缓存大小（用于监控）
     */
    public int getCacheSize() {
        return cache.size();
    }
}