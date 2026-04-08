package com.hongchu.cbservice.controller.health;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.hongchu.cbcommon.result.Result;
import com.hongchu.cbpojo.entity.health.WechatArticle;
import com.hongchu.cbservice.mapper.health.WechatArticleMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Slf4j
@RestController
@RequestMapping("/wechat-article")
@CrossOrigin
@RequiredArgsConstructor
public class WechatArticleController {

    private final WechatArticleMapper wechatArticleMapper;

    @GetMapping("/list")
    public Result<List<WechatArticle>> getArticleList(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size) {
        log.info("获取公众号推文列表: page={}, size={}", page, size);

        Page<WechatArticle> pageParam = new Page<>(page, size);
        LambdaQueryWrapper<WechatArticle> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.orderByDesc(WechatArticle::getPublishTime);

        Page<WechatArticle> result = wechatArticleMapper.selectPage(pageParam, queryWrapper);
        return Result.success(result.getRecords());
    }

    @GetMapping("/{id}")
    public Result<WechatArticle> getArticleById(@PathVariable Long id) {
        log.info("获取公众号推文详情: id={}", id);
        WechatArticle article = wechatArticleMapper.selectById(id);
        if (article == null) {
            return Result.fail("推文不存在");
        }
        return Result.success(article);
    }

    @PostMapping("/add")
    public Result<String> addArticle(@RequestBody WechatArticle article) {
        log.info("添加公众号推文: title={}", article.getTitle());
        wechatArticleMapper.insert(article);
        return Result.success("添加成功");
    }

    @DeleteMapping("/delete/{id}")
    public Result<String> deleteArticle(@PathVariable Long id) {
        log.info("删除公众号推文: id={}", id);
        wechatArticleMapper.deleteById(id);
        return Result.success("删除成功");
    }
}
