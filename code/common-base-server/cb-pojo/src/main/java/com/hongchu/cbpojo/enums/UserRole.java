package com.hongchu.cbpojo.enums;

import lombok.Getter;

/**
 * 用户角色枚举
 * 包含中文名和英文名
 */
@Getter
public enum UserRole {
    
    // 管理类角色
    SUPER_ADMIN("超级管理员", "super_admin"),
    ADMIN("管理员", "admin"),
    TEACHER("老人", "oldMan"),
    STUDENT("家人", "family"),
    VIEWER("访客", "viewer"),
    OTHER("其他", "other");
    
    private final String chineseName;
    private final String englishName;
    
    UserRole(String chineseName, String englishName) {
        this.chineseName = chineseName;
        this.englishName = englishName;
    }
    
    /**
     * 根据英文名获取角色
     */
    public static UserRole fromEnglishName(String englishName) {
        for (UserRole role : values())
            if (role.getEnglishName().equals(englishName))
                return role;
        return OTHER;
    }
    
    /**
     * 根据中文名获取角色
     */
    public static UserRole fromChineseName(String chineseName) {
        for (UserRole role : values())
            if (role.getChineseName().equals(chineseName))
                return role;
        return OTHER;
    }
    
    /**
     * 检查是否为管理员角色
     */
    public boolean isAdminRole() {
        return this == SUPER_ADMIN || this == ADMIN;
    }
}