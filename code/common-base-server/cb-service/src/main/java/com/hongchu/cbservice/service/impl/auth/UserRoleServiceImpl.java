package com.hongchu.cbservice.service.impl.auth;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hongchu.cbcommon.context.BaseContext;
import com.hongchu.cbcommon.context.ErrorMessageConstants;
import com.hongchu.cbcommon.exception.BusinessException;
import com.hongchu.cbpojo.dto.UserRoleAssignRequestDTO;
import com.hongchu.cbpojo.entity.UserRole;
import com.hongchu.cbpojo.vo.UserRoleVO;
import com.hongchu.cbservice.mapper.UserRoleMapper;
import com.hongchu.cbservice.service.interfaces.auth.IUserRoleService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

/**
 * <p>
 * 用户角色表 服务实现类
 * </p>
 *
 * @author hongchu
 * @since 2026-03-27
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class UserRoleServiceImpl extends ServiceImpl<UserRoleMapper, UserRole> implements IUserRoleService {

    private final UserRoleMapper userRoleMapper;

    private Long getCurrentUserId() {
        Long userId = BaseContext.getCurrentId();
        if (userId == null) {
            throw new BusinessException(ErrorMessageConstants.ERROR_USER_NOT_LOGIN);
        }
        return userId;
    }

    @Override
    public UserRole getUserRoleByUserId(Long userId) {
        LambdaQueryWrapper<UserRole> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(UserRole::getUserId, userId)
                .eq(UserRole::getIsActive, true)
                .orderByDesc(UserRole::getCreatedAt)
                .last("LIMIT 1");
        return getOne(wrapper);
    }

    @Override
    public boolean hasUserRole(Long userId, String roleCode) {
        LambdaQueryWrapper<UserRole> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(UserRole::getUserId, userId)
                .eq(UserRole::getRoleCode, roleCode)
                .eq(UserRole::getIsActive, true);
        return count(wrapper) > 0;
    }

    @Override
    public boolean hasUserRoleCategory(Long userId, String roleCategory) {
        LambdaQueryWrapper<UserRole> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(UserRole::getUserId, userId)
                .eq(UserRole::getRoleCategory, roleCategory)
                .eq(UserRole::getIsActive, true);
        return count(wrapper) > 0;
    }

    @Override
    public boolean assignRoleToUser(Long userId, String roleCode, String roleName, String roleCategory, String roleDescription) {
        // 先禁用用户现有的角色
        disableUserRole(userId);

        // 创建新的角色记录
        UserRole userRole = new UserRole();
        userRole.setUserId(userId);
        userRole.setRoleCode(roleCode);
        userRole.setRoleName(roleName);
        userRole.setRoleCategory(roleCategory);
        userRole.setRoleDescription(roleDescription);
        userRole.setIsActive(true);
        userRole.setCreatedAt(LocalDateTime.now());
        userRole.setUpdatedAt(LocalDateTime.now());

        return save(userRole);
    }

    @Override
    public boolean updateUserRole(Long userId, String newRoleCode, String newRoleName, String newRoleCategory, String newRoleDescription) {
        UserRole userRole = getUserRoleByUserId(userId);
        if (userRole == null) {
            return assignRoleToUser(userId, newRoleCode, newRoleName, newRoleCategory, newRoleDescription);
        }

        userRole.setRoleCode(newRoleCode);
        userRole.setRoleName(newRoleName);
        userRole.setRoleCategory(newRoleCategory);
        userRole.setRoleDescription(newRoleDescription);
        userRole.setUpdatedAt(LocalDateTime.now());

        return updateById(userRole);
    }

    @Override
    public boolean disableUserRole(Long userId) {
        LambdaQueryWrapper<UserRole> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(UserRole::getUserId, userId)
                .eq(UserRole::getIsActive, true);

        UserRole userRole = new UserRole();
        userRole.setIsActive(false);
        userRole.setUpdatedAt(LocalDateTime.now());

        return update(userRole, wrapper);
    }

    @Override
    public boolean enableUserRole(Long userId, String roleCode) {
        LambdaQueryWrapper<UserRole> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(UserRole::getUserId, userId)
                .eq(UserRole::getRoleCode, roleCode);

        UserRole userRole = getOne(wrapper);
        if (userRole == null) {
            return false;
        }

        userRole.setIsActive(true);
        userRole.setUpdatedAt(LocalDateTime.now());

        return updateById(userRole);
    }

    @Override
    public UserRole getUserRole() {
        Long userId = getCurrentUserId();
        return getUserRoleByUserId(userId);
    }

    @Override
    public UserRoleVO getUserRoleVO() {
        UserRole userRole = getUserRole();
        if (userRole == null) {
            return null;
        }
        UserRoleVO vo = new UserRoleVO();
        BeanUtils.copyProperties(userRole, vo);
        return vo;
    }

    @Override
    @Transactional
    public void assignOrSwitchRole(UserRoleAssignRequestDTO request) {
        Long userId = getCurrentUserId();

        // 参数校验
        if (request.getRoleCode() == null || request.getRoleCode().trim().isEmpty())
            throw new BusinessException("角色代码不能为空");
        if (request.getRoleName() == null || request.getRoleName().trim().isEmpty())
            throw new BusinessException("角色名称不能为空");
        if (request.getRoleCategory() == null || request.getRoleCategory().trim().isEmpty())
            throw new BusinessException("角色分类不能为空");

        // 校验角色分类是否合法
        String roleCategory = request.getRoleCategory();
        if (!"ADMIN".equals(roleCategory) && !"WHITE".equals(roleCategory) &&
                !"BLACK".equals(roleCategory) && !"GUEST".equals(roleCategory) &&
                !"BUSINESS".equals(roleCategory)) {
            throw new BusinessException("无效的角色分类，必须是: ADMIN, WHITE, BLACK, GUEST, BUSINESS");
        }

        // 获取用户当前角色
        UserRole currentRole = getUserRole();

        // 无角色，直接分配
        if (currentRole == null) {
            boolean success = assignRoleToUser(
                    userId,
                    request.getRoleCode(),
                    request.getRoleName(),
                    request.getRoleCategory(),
                    request.getRoleDescription()
            );
            if (!success) {
                throw new BusinessException("角色分配失败");
            }
            log.info("分配角色成功: userId={}, roleCategory={}", userId, request.getRoleCategory());
            return;
        }

        // 有角色，校验切换规则
        String currentCategory = currentRole.getRoleCategory();
        String newCategory = request.getRoleCategory();

        // 角色切换规则校验
        if (!currentCategory.equals(newCategory)) {
            // ADMIN 和 WHITE 可以切换到任意角色
            if (!"ADMIN".equals(currentCategory) && !"WHITE".equals(currentCategory)) {
                // BLACK 只能切换到 WHITE/GUEST/BUSINESS
                if ("BLACK".equals(currentCategory)) {
                    if (!"WHITE".equals(newCategory) && !"GUEST".equals(newCategory) && !"BUSINESS".equals(newCategory)) {
                        throw new BusinessException(String.format("不允许从 %s 切换到 %s", currentCategory, newCategory));
                    }
                }
                // GUEST 只能切换到 BUSINESS/BLACK
                else if ("GUEST".equals(currentCategory)) {
                    if (!"BUSINESS".equals(newCategory) && !"BLACK".equals(newCategory)) {
                        throw new BusinessException(String.format("不允许从 %s 切换到 %s", currentCategory, newCategory));
                    }
                }
                // BUSINESS 只能切换到 BUSINESS/BLACK
                else if ("BUSINESS".equals(currentCategory)) {
                    if (!"BUSINESS".equals(newCategory) && !"BLACK".equals(newCategory)) {
                        throw new BusinessException(String.format("不允许从 %s 切换到 %s", currentCategory, newCategory));
                    }
                }
                else {
                    throw new BusinessException(String.format("不允许从 %s 切换到 %s", currentCategory, newCategory));
                }
            }
        }

        // 执行切换：先禁用当前角色，再激活或创建目标角色
        disableUserRole(userId);

        // 检查目标角色是否已存在
        UserRole targetRole = getRoleByCode(userId, request.getRoleCode());
        if (targetRole != null) {
            // 目标角色已存在，激活它
            targetRole.setIsActive(true);
            targetRole.setRoleName(request.getRoleName());
            targetRole.setRoleCategory(request.getRoleCategory());
            targetRole.setRoleDescription(request.getRoleDescription());
            targetRole.setUpdatedAt(LocalDateTime.now());
            updateById(targetRole);
            log.info("激活已有角色: userId={}, roleCode={}", userId, request.getRoleCode());
        } else {
            // 目标角色不存在，创建新记录
            UserRole newRole = new UserRole();
            newRole.setUserId(userId);
            newRole.setRoleCode(request.getRoleCode());
            newRole.setRoleName(request.getRoleName());
            newRole.setRoleCategory(request.getRoleCategory());
            newRole.setRoleDescription(request.getRoleDescription());
            newRole.setIsActive(true);
            newRole.setCreatedAt(LocalDateTime.now());
            newRole.setUpdatedAt(LocalDateTime.now());
            save(newRole);
            log.info("创建新角色: userId={}, roleCode={}", userId, request.getRoleCode());
        }

        log.info("切换角色成功: userId={}, {} -> {}", userId, currentCategory, newCategory);
    }

    private UserRole getRoleByCode(Long userId, String roleCode) {
        LambdaQueryWrapper<UserRole> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(UserRole::getUserId, userId)
                .eq(UserRole::getRoleCode, roleCode);
        return getOne(wrapper);
    }
}
