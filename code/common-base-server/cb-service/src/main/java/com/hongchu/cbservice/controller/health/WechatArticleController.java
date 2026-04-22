package com.hongchu.cbservice.controller.health;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.hongchu.cbcommon.result.Result;
import com.hongchu.cbpojo.entity.health.WechatArticle;
import com.hongchu.cbservice.mapper.health.WechatArticleMapper;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 公众号推文控制器
 * <p>
 * 提供公众号推文的增删改查接口，包括：
 * <ul>
 *     <li>推文列表查询（分页）</li>
 *     <li>推文详情查询</li>
 *     <li>推文新增</li>
 *     <li>推文修改</li>
 *     <li>推文删除</li>
 * </ul>
 * </p>
 *
 * @author hongchu
 * @since 2026-04-09
 */
@Slf4j
@RestController
@RequestMapping("/wechat-article")
@CrossOrigin
@RequiredArgsConstructor
public class WechatArticleController {

    private final WechatArticleMapper wechatArticleMapper;

    /**
     * 分页条件查询推文列表
     * 支持参数：page(页码)、size(每页数量)、keyword(标题/描述关键词)、source(来源)、author(作者)
     */
    @GetMapping("/list")
    public Result<Map<String, Object>> getArticleList(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String source,
            @RequestParam(required = false) String author) {
        log.info("获取公众号推文列表: page={}, size={}, keyword={}, source={}, author={}",
                page, size, keyword, source, author);

        Page<WechatArticle> pageParam = new Page<>(page, size);
        LambdaQueryWrapper<WechatArticle> queryWrapper = new LambdaQueryWrapper<>();

        // 关键词模糊搜索（标题或描述）
        if (StringUtils.hasText(keyword)) {
            queryWrapper.and(w -> w
                    .like(WechatArticle::getTitle, keyword)
                    .or()
                    .like(WechatArticle::getDescription, keyword));
        }
        // 来源精确过滤
        if (StringUtils.hasText(source)) {
            queryWrapper.eq(WechatArticle::getSource, source);
        }
        // 作者精确过滤
        if (StringUtils.hasText(author)) {
            queryWrapper.eq(WechatArticle::getAuthor, author);
        }

        queryWrapper.orderByDesc(WechatArticle::getPublishTime);

        Page<WechatArticle> result = wechatArticleMapper.selectPage(pageParam, queryWrapper);

        // 返回分页数据 + 总数，方便前端分页组件使用
        Map<String, Object> data = new HashMap<>();
        data.put("records", result.getRecords());
        data.put("total", result.getTotal());
        data.put("page", result.getCurrent());
        data.put("size", result.getSize());
        data.put("pages", result.getPages());
        return Result.success(data);
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
