package com.hongchu.cbpojo.enums;

/**
 * 日志类型枚举
 */
public enum LogType {
    LOGIN("登录"),
    OPERATION("操作"), 
    ERROR("错误"),
    API("接口"),
    SYSTEM("系统");
    
    private final String description;
    
    LogType(String description) {
        this.description = description;
    }
    
    public String getDescription() {
        return description;
    }
}

