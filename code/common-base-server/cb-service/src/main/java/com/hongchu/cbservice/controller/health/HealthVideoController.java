package com.hongchu.cbservice.controller.health;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.hongchu.cbcommon.result.Result;
import com.hongchu.cbpojo.entity.health.HealthVideo;
import com.hongchu.cbservice.mapper.health.HealthVideoMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Slf4j
@RestController
@RequestMapping("/health-video")
@CrossOrigin
@RequiredArgsConstructor
public class HealthVideoController {

    private final HealthVideoMapper healthVideoMapper;

    @GetMapping("/list")
    public Result<List<HealthVideo>> getVideoList(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size) {
        log.info("获取健康视频列表: page={}, size={}", page, size);

        Page<HealthVideo> pageParam = new Page<>(page, size);
        LambdaQueryWrapper<HealthVideo> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.orderByDesc(HealthVideo::getUploadTime);

        Page<HealthVideo> result = healthVideoMapper.selectPage(pageParam, queryWrapper);
        return Result.success(result.getRecords());
    }

    @GetMapping("/{id}")
    public Result<HealthVideo> getVideoById(@PathVariable Long id) {
        log.info("获取健康视频详情: id={}", id);
        HealthVideo video = healthVideoMapper.selectById(id);
        if (video == null) {
            return Result.fail("视频不存在");
        }
        return Result.success(video);
    }

    @PostMapping("/add")
    public Result<String> addVideo(@RequestBody HealthVideo video) {
        log.info("添加健康视频: title={}", video.getTitle());
        healthVideoMapper.insert(video);
        return Result.success("添加成功");
    }

    @DeleteMapping("/delete/{id}")
    public Result<String> deleteVideo(@PathVariable Long id) {
        log.info("删除健康视频: id={}", id);
        healthVideoMapper.deleteById(id);
        return Result.success("删除成功");
    }
}
