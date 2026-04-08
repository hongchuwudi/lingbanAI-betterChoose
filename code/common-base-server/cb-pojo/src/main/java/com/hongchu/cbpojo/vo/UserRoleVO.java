package com.hongchu.cbpojo.vo;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class UserRoleVO {
    private Long id;
    private Long userId;
    private String roleCode;
    private String roleName;
    private String roleCategory;
    private String roleDescription;
    private Boolean isActive;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}