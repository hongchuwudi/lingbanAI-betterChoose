package com.hongchu.cbcommon.context;

/**
 * 上下文工具类
 * 用于保存当前登录用户的ID和角色分类，贯穿整个项目
 */
public class BaseContext {
    // 用户ID
    private static final ThreadLocal<Long> threadLocal = new ThreadLocal<>();
    // 用户角色分类：ADMIN/WHITE/BLACK/GUEST/BUSINESS
    private static final ThreadLocal<String> threadLocalRoleCategory = new ThreadLocal<>();

    // ================ 用户ID相关方法 ================
    public static void setCurrentId(Long id) {threadLocal.set(id);}
    public static Long getCurrentId() {return threadLocal.get();}
    public static void removeCurrentId() {threadLocal.remove();}

    // ================ 用户角色分类相关方法 ================
    public static void setCurrentRoleCategory(String roleCategory) {threadLocalRoleCategory.set(roleCategory);}
    public static String getCurrentRoleCategory() {return threadLocalRoleCategory.get();}
    public static void removeCurrentRoleCategory() {threadLocalRoleCategory.remove();}

    // ================ 角色分类判断方法 ================

    /**
     * 判断当前用户是否为管理员角色
     */
    public static boolean isAdminRole() {
        return "ADMIN".equalsIgnoreCase(getCurrentRoleCategory());
    }

    /**
     * 判断当前用户是否为白名单角色
     */
    public static boolean isWhiteRole() {
        return "WHITE".equalsIgnoreCase(getCurrentRoleCategory());
    }

    /**
     * 判断当前用户是否为黑名单角色
     */
    public static boolean isBlackRole() {
        return "BLACK".equalsIgnoreCase(getCurrentRoleCategory());
    }

    /**
     * 判断当前用户是否为游客角色
     */
    public static boolean isGuestRole() {
        return "GUEST".equalsIgnoreCase(getCurrentRoleCategory());
    }

    /**
     * 判断当前用户是否为业务角色
     */
    public static boolean isBusinessRole() {
        return "BUSINESS".equalsIgnoreCase(getCurrentRoleCategory());
    }

    /**
     * 判断当前用户是否有指定角色分类
     */
    public static boolean hasRoleCategory(String roleCategory) {
        String currentRoleCategory = getCurrentRoleCategory();
        return currentRoleCategory != null && currentRoleCategory.equalsIgnoreCase(roleCategory);
    }

    /**
     * 判断当前用户是否有任一指定角色分类
     */
    public static boolean hasAnyRoleCategory(String... roleCategories) {
        if (roleCategories == null || roleCategories.length == 0)
            return false;

        String currentRoleCategory = getCurrentRoleCategory();
        if (currentRoleCategory == null) return false;

        for (String roleCategory : roleCategories) {
            if (currentRoleCategory.equalsIgnoreCase(roleCategory))
                return true;
        }

        return false;
    }

    // ================ 批量操作方法 ================

    /**
     * 同时设置用户ID和角色分类
     */
    public static void setUserContext(Long userId, String roleCategory) {
        setCurrentId(userId);
        setCurrentRoleCategory(roleCategory);
    }

    /**
     * 清除所有上下文信息（防止内存泄漏）
     */
    public static void clear() {
        removeCurrentId();
        removeCurrentRoleCategory();
    }
}