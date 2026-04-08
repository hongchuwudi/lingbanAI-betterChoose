package com.hongchu.cbpojo.entity;

import com.baomidou.mybatisplus.annotation.*;
import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.fasterxml.jackson.databind.ser.std.ToStringSerializer;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@TableName("users")
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class User {
    @TableId(type = IdType.ASSIGN_ID)
    @JsonSerialize(using = ToStringSerializer.class)
    private Long id;                        // 主键
    private String nickname;                // 昵称
    private String username;                // 用户名
    private String email;                   // 邮箱
    private String phone;                   //  手机
    @TableField("password_hash") private String passwordHash;            // 密码
    private String salt;                    // 盐
    private String avatar;                  // 头像
    private java.time.LocalDate birthday;   // 生日
    private Integer gender;                 // 性别
    private String bio;                     // 简介
    @TableField("update_un_times") private Integer updateUnTimes = 2; // 剩余更新username次数
    @TableField("is_vip") private Boolean isVip = false;
    @TableField(value = "created_at", fill = FieldFill.INSERT) private LocalDateTime createdAt;
    @TableField(value = "updated_at", fill = FieldFill.INSERT_UPDATE) private LocalDateTime updatedAt;

    // 临时字段，不存入数据库
    @TableField(exist = false) private String password;
}