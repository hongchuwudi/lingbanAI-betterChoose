package com.hongchu.cbservice.controller;

import com.hongchu.cbcommon.result.Result;
import com.hongchu.cbpojo.vo.FamilyBindingVO;
import com.hongchu.cbservice.service.interfaces.IFamilyBindingService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Slf4j
@RestController
@RequestMapping("/user/family-binding")
@CrossOrigin
@RequiredArgsConstructor
public class FamilyBindingController {

    private final IFamilyBindingService familyBindingService;

    @PostMapping("/add")
    public Result<String> addBinding(
            @RequestParam Long elderlyProfileId,
            @RequestParam(required = false) Long childProfileId,
            @RequestParam(defaultValue = "其他") String relationType,
            @RequestParam(required = false, defaultValue = "其他") String elderlyToChildRelation) {
        log.info("增加关系: 老人档案ID={}, 子女档案ID={}, 子女对老人称呼={}, 老人对子女称呼={}", 
                elderlyProfileId, childProfileId, relationType, elderlyToChildRelation);
        
        if (childProfileId == null) {
            return Result.fail("对方尚未创建身份档案，请让对方先在APP中创建身份后再添加家人关系");
        }
        
        familyBindingService.addBinding(elderlyProfileId, childProfileId, relationType, elderlyToChildRelation);
        return Result.success("绑定请求已发送");
    }

    @DeleteMapping("/delete/{id}")
    public Result<String> deleteBinding(@PathVariable Long id) {
        log.info("删除关系: ID={}", id);
        familyBindingService.deleteBinding(id);
        return Result.success("删除成功");
    }

    @PutMapping("/update/{id}")
    public Result<String> updateBinding(
            @PathVariable Long id,
            @RequestParam String relationType) {
        log.info("修改关系: ID={}, 新关系={}", id, relationType);
        familyBindingService.updateBinding(id, relationType);
        return Result.success("修改成功");
    }

    @PutMapping("/confirm/{id}")
    public Result<String> confirmBinding(@PathVariable Long id) {
        log.info("确认绑定: ID={}", id);
        familyBindingService.updateStatus(id, 1);
        return Result.success("绑定成功");
    }

    @PutMapping("/unbind/{id}")
    public Result<String> unbindBinding(@PathVariable Long id) {
        log.info("解绑: ID={}", id);
        familyBindingService.updateStatus(id, 3);
        return Result.success("解绑成功");
    }

    @GetMapping("/my-relations")
    public Result<List<FamilyBindingVO>> getMyRelations() {
        log.info("查询当前用户的所有关系");
        return Result.success(familyBindingService.getMyRelations());
    }

    @GetMapping("/pending")
    public Result<List<FamilyBindingVO>> getPendingBindings() {
        log.info("查询待确认的绑定请求");
        return Result.success(familyBindingService.getPendingBindings());
    }

    @GetMapping("/detail/{id}")
    public Result<FamilyBindingVO> getBindingDetail(@PathVariable Long id) {
        log.info("查询绑定详情: ID={}", id);
        return Result.success(familyBindingService.getBindingDetail(id));
    }

    @GetMapping("/elderly/{elderlyProfileId}")
    public Result<List<FamilyBindingVO>> getElderlyRelations(@PathVariable Long elderlyProfileId) {
        log.info("查询老人的子女: 老人档案ID={}", elderlyProfileId);
        return Result.success(familyBindingService.getElderlyRelations(elderlyProfileId));
    }

    @GetMapping("/child/{childProfileId}")
    public Result<List<FamilyBindingVO>> getChildRelations(@PathVariable Long childProfileId) {
        log.info("查询子女的老人: 子女档案ID={}", childProfileId);
        return Result.success(familyBindingService.getChildRelations(childProfileId));
    }
}
