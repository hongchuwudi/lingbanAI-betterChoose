package com.hongchu.cbservice.controller;

import com.hongchu.cbcommon.result.Result;
import com.hongchu.cbpojo.entity.ChildProfile;
import com.hongchu.cbpojo.vo.ChildProfileVO;
import com.hongchu.cbservice.annotation.Role;
import com.hongchu.cbservice.service.interfaces.auth.IChildProfileService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 用户端-子女档案控制器
 * 提供子女档案的增删改查接口
 */
@Slf4j
@RestController("UserChildProfileController")
@RequestMapping("/user/child-profile")
@CrossOrigin
@RequiredArgsConstructor
public class ChildProfileController {

    private final IChildProfileService childProfileService;

    /**
     * 新增当前用户的子女档案
     */
    @PostMapping("/add")
    public Result<ChildProfileVO> addChildProfile(@RequestBody ChildProfile childProfile) {
        log.info("新增当前用户子女档案");
        return Result.success(childProfileService.createChildProfile(childProfile));
    }

    /**
     * 查询当前用户的子女档案
     */
    @GetMapping("/get")
    public Result<ChildProfileVO> getChildProfile() {
        log.info("查询当前用户子女档案");
        return Result.success(childProfileService.getChildProfileByCurrentUser());
    }

    /**
     * 根据用户ID查询子女档案
     */
    @GetMapping("/get-by-user/{userId}")
    public Result<ChildProfileVO> getChildProfileByUserId(@PathVariable Long userId) {
        log.info("根据用户ID查询子女档案: userId={}", userId);
        return Result.success(childProfileService.getChildProfileByUserId(userId));
    }

    /**
     * 更新当前用户的子女档案
     */
    @PutMapping("/update")
    public Result<ChildProfileVO> updateChildProfile(@RequestBody ChildProfile childProfile) {
        log.info("更新当前用户子女档案");
        return Result.success(childProfileService.updateChildProfile(childProfile));
    }

    /**
     * 删除当前用户的子女档案
     */
    @DeleteMapping("/delete")
    public Result<String> deleteChildProfile() {
        log.info("删除当前用户子女档案");
        childProfileService.deleteChildProfile();
        return Result.success("子女档案删除成功");
    }

    /**
     * 查询所有子女档案列表
     */
    @GetMapping("/list")
    public Result<List<ChildProfile>> listChildProfiles() {
        log.info("查询所有子女档案列表");
        return Result.success(childProfileService.list());
    }

    /**
     * 判断当前用户是否为子女用户
     */
    @GetMapping("/is-child")
    public Result<Boolean> isChildUser() {
        log.info("判断当前用户是否为子女用户");
        return Result.success(childProfileService.isChildUser());
    }
}