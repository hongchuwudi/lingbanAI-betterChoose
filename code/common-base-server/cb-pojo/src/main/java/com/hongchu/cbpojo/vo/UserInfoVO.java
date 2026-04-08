package com.hongchu.cbpojo.vo;

import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.fasterxml.jackson.databind.ser.std.ToStringSerializer;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

// 用户信息视图对象
@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class UserInfoVO {
    // user表
    Boolean isVip = false;
    @JsonSerialize(using = ToStringSerializer.class)
    private Long id;                        // 主键
    private String nickname;                // 昵称
    private String username;                // 用户名
    private String email;                   // 邮箱
    private String phone;                   // 手机号
    private String avatar;                  // 头像
    private java.time.LocalDate birthday;   // 生日
    private Integer gender;                 // 性别
    private String bio;                     // 简介
    private Integer updateUnTimes;          // 剩余更改username的次数
    private LocalDateTime createdAt;        // 创建时间
    private LocalDateTime updatedAt;        // 更新时间
    // user_role表
    private String roleCode;                // 角色代码
    private String roleName;                // 角色名称
    private String roleCategory;            // 角色分类: ADMIN-最高权限, WHITE-白名单, BLACK-黑名单, GUEST-游客, BUSINESS-业务
    private String roleDescription;         // 角色描述
    private Boolean isActive;               // 是否启用
    // 额外
    private String token;                   // token
    private String refreshToken;            // refreshToken
    // 老人档案信息
    private ElderlyProfileVO elderlyProfile;
    // 子女档案信息
    private ChildProfileVO childProfile;
}
