package com.hongchu.cbpojo.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.baomidou.mybatisplus.annotation.IdType;
import java.time.LocalDateTime;
import com.baomidou.mybatisplus.annotation.TableId;
import java.io.Serializable;

import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.fasterxml.jackson.databind.ser.std.ToStringSerializer;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.experimental.Accessors;

/**
 * <p>
 * 用户角色表(一个账户只能有一个角色,支持角色切换)
 * </p>
 *
 * @author hongchu
 * @since 2026-03-27
 */
@Data
@EqualsAndHashCode(callSuper = false)
@Accessors(chain = true)
@TableName("user_role")
public class UserRole implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 主键ID
     */
    @TableId(value = "id", type = IdType.ASSIGN_ID)
    @JsonSerialize(using = ToStringSerializer.class)
    private Long id;

    /**
     * 用户ID，关联用户表
     */
    private Long userId;

    /**
     * 角色代码，如: ADMIN_001
     */
    private String roleCode;

    /**
     * 角色名称，如: 系统管理员
     */
    private String roleName;

    /**
     * 角色分类: ADMIN-最高权限, WHITE-白名单, BLACK-黑名单, GUEST-游客, BUSINESS-业务
     */
    private String roleCategory;

    /**
     * 角色详细描述
     */
    private String roleDescription;

    /**
     * 是否启用: true-启用, false-禁用
     */
    private Boolean isActive;

    /**
     * 创建时间
     */
    private LocalDateTime createdAt;

    /**
     * 更新时间
     */
    private LocalDateTime updatedAt;
}