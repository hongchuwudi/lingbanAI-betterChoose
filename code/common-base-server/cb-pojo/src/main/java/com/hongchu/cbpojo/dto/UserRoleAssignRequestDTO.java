package com.hongchu.cbpojo.dto;

import lombok.Data;

/**
 * 角色分配请求参数
 */
@Data
public class UserRoleAssignRequestDTO {
    private String roleCode;
    private String roleName;
    private String roleCategory;
    private String roleDescription;
}