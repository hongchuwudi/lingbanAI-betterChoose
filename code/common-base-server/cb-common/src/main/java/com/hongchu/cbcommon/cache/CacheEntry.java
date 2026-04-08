// CacheEntry.java
package com.hongchu.cbcommon.cache;

import lombok.Data;

@Data
public class CacheEntry<T> {
    private T data;
    private long expireTime;
    
    public CacheEntry(T data, long expireTime) {
        this.data = data;
        this.expireTime = expireTime;
    }
    
    /**
     * 检查是否过期
     */
    public boolean isExpired() {
        return System.currentTimeMillis() > expireTime;
    }
}