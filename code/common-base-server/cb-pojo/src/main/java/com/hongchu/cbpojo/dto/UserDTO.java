package com.hongchu.cbpojo.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class UserDTO {
    Boolean isVip = false;
    private Long id;                        // 主键
    private String nickname;                // 昵称
    private String email;                   // 邮箱
    private String phone;                   // 手机号
    private String avatar;                  // 头像
    private java.time.LocalDate birthday;   // 生日
    private Integer gender;                 // 性别
    private String bio;                     // 简介
}
