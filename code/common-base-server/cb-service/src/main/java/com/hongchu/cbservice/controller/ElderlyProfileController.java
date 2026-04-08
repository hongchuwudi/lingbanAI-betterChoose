package com.hongchu.cbservice.controller;

import com.hongchu.cbcommon.result.Result;
import com.hongchu.cbpojo.entity.ElderlyProfile;
import com.hongchu.cbpojo.vo.ElderlyProfileVO;
import com.hongchu.cbservice.annotation.Role;
import com.hongchu.cbservice.service.interfaces.auth.IElderlyProfileService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 用户端-老人档案控制器
 * 提供老人档案的增删改查接口
 */
@Slf4j
@RestController("UserElderlyProfileController")
@RequestMapping("/user/elderly-profile")
@CrossOrigin
@RequiredArgsConstructor
public class ElderlyProfileController {

    private final IElderlyProfileService elderlyProfileService;

    /**
     * 新增当前用户的老人档案
     */
    @PostMapping("/add")
    public Result<ElderlyProfileVO> addElderlyProfile(@RequestBody ElderlyProfile elderlyProfile) {
        log.info("新增当前用户老人档案");
        return Result.success(elderlyProfileService.createElderlyProfile(elderlyProfile));
    }

    /**
     * 查询当前用户的老人档案
     */
    @GetMapping("/get")
    public Result<ElderlyProfileVO> getElderlyProfile() {
        log.info("查询当前用户老人档案");
        return Result.success(elderlyProfileService.getElderlyProfileByCurrentUser());
    }

    /**
     * 根据用户ID查询老人档案
     */
    @GetMapping("/get-by-user/{userId}")
    public Result<ElderlyProfileVO> getElderlyProfileByUserId(@PathVariable Long userId) {
        log.info("根据用户ID查询老人档案: userId={}", userId);
        return Result.success(elderlyProfileService.getElderlyProfileByUserId(userId));
    }

    /**
     * 更新当前用户的老人档案
     */
    @PutMapping("/update")
    public Result<ElderlyProfileVO> updateElderlyProfile(@RequestBody ElderlyProfile elderlyProfile) {
        log.info("更新当前用户老人档案");
        return Result.success(elderlyProfileService.updateElderlyProfile(elderlyProfile));
    }

    /**
     * 删除当前用户的老人档案
     */
    @DeleteMapping("/delete")
    public Result<String> deleteElderlyProfile() {
        log.info("删除当前用户老人档案");
        elderlyProfileService.deleteElderlyProfile();
        return Result.success("老人档案删除成功");
    }

    /**
     * 查询所有老人档案列表
     */
    @GetMapping("/list")
    public Result<List<ElderlyProfile>> listElderlyProfiles() {
        log.info("查询所有老人档案列表");
        return Result.success(elderlyProfileService.list());
    }

    /**
     * 判断当前用户是否为老人用户
     */
    @GetMapping("/is-elderly")
    public Result<Boolean> isElderlyUser() {
        log.info("判断当前用户是否为老人用户");
        return Result.success(elderlyProfileService.isElderlyUser());
    }

    /**
     * 批量更新老人档案
     */
    @PutMapping("/batch-update")
    public Result<String> batchUpdateElderlyProfiles(@RequestBody List<ElderlyProfile> elderlyProfiles) {
        log.info("批量更新老人档案: 数量={}", elderlyProfiles.size());
        elderlyProfileService.updateBatchById(elderlyProfiles);
        return Result.success("批量更新成功");
    }
}