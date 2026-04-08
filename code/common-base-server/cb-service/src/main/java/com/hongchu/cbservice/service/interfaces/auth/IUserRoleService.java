package com.hongchu.cbservice.service.interfaces.auth;

import com.hongchu.cbpojo.dto.UserRoleAssignRequestDTO;
import com.hongchu.cbpojo.entity.UserRole;
import com.baomidou.mybatisplus.extension.service.IService;
import com.hongchu.cbpojo.vo.UserRoleVO;
import com.hongchu.cbservice.controller.UserRoleController;

/**
 * <p>
 * 用户角色表 服务类
 * </p>
 *
 * @author hongchu
 * @since 2026-03-27
 */
public interface IUserRoleService extends IService<UserRole> {

    /**
     * 根据用户ID获取用户角色
     * @param userId 用户ID
     * @return 用户角色信息
     */
    UserRole getUserRoleByUserId(Long userId);

    /**
     * 检查用户是否拥有指定角色
     * @param userId 用户ID
     * @param roleCode 角色代码
     * @return 是否拥有该角色
     */
    boolean hasUserRole(Long userId, String roleCode);

    /**
     * 检查用户是否拥有指定角色分类
     * @param userId 用户ID
     * @param roleCategory 角色分类
     * @return 是否拥有该角色分类
     */
    boolean hasUserRoleCategory(Long userId, String roleCategory);

    /**
     * 为用户分配角色
     * @param userId 用户ID
     * @param roleCode 角色代码
     * @param roleName 角色名称
     * @param roleCategory 角色分类
     * @param roleDescription 角色描述
     * @return 是否分配成功
     */
    boolean assignRoleToUser(Long userId, String roleCode, String roleName, String roleCategory, String roleDescription);

    /**
     * 更新用户角色
     * @param userId 用户ID
     * @param newRoleCode 新的角色代码
     * @param newRoleName 新的角色名称
     * @param newRoleCategory 新的角色分类
     * @param newRoleDescription 新的角色描述
     * @return 是否更新成功
     */
    boolean updateUserRole(Long userId, String newRoleCode, String newRoleName, String newRoleCategory, String newRoleDescription);

    /**
     * 禁用用户角色
     * @param userId 用户ID
     * @return 是否禁用成功
     */
    boolean disableUserRole(Long userId);

    /**
     * 启用用户角色
     * @param userId 用户ID
     * @param roleCode 角色代码
     * @return 是否启用成功
     */
    boolean enableUserRole(Long userId, String roleCode);

    /**
     * 获取当前用户的角色
     */
    UserRole getUserRole();

    /**
     * 获取当前用户的角色VO
     */
    UserRoleVO getUserRoleVO();

    /**
     * 分配或切换当前用户的角色（包含切换规则校验）
     */
    void assignOrSwitchRole(UserRoleAssignRequestDTO request);
}