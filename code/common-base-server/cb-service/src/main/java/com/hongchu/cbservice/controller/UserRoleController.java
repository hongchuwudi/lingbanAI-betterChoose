package com.hongchu.cbservice.controller;

import com.hongchu.cbcommon.context.BaseContext;
import com.hongchu.cbcommon.result.Result;
import com.hongchu.cbpojo.dto.UserRoleAssignRequestDTO;
import com.hongchu.cbpojo.vo.UserRoleVO;
import com.hongchu.cbservice.annotation.Role;
import com.hongchu.cbservice.service.interfaces.auth.IUserRoleService;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

/**
 * 用户角色控制器
 */
@Slf4j
@RestController
@RequestMapping("/user/role")
@CrossOrigin
@RequiredArgsConstructor
@Role({"ADMIN", "WHITE", "BUSINESS", "GUEST"})
public class UserRoleController {

    private final IUserRoleService userRoleService;

    /**
     * 检查当前用户是否有角色
     */
    @GetMapping("/check")
    public Result<UserRoleVO> checkUserRole() {
        Long userId = BaseContext.getCurrentId();
        log.info("检查用户角色: userId={}", userId);
        return Result.success(userRoleService.getUserRoleVO());
    }

    /**
     * 分配/切换用户角色
     */
    @PostMapping("/assign")
    public Result<String> assignUserRole(@RequestBody UserRoleAssignRequestDTO request) {
        Long userId = BaseContext.getCurrentId();
        log.info("分配用户角色: userId={}, roleCategory={}", userId, request.getRoleCategory());
        userRoleService.assignOrSwitchRole(request);
        return Result.success("操作成功");
    }


}