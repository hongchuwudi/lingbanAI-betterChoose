package com.hongchu.cbservice.controller;

import com.hongchu.cbcommon.result.Result;
import com.hongchu.cbpojo.vo.SystemNotificationVO;
import com.hongchu.cbservice.annotation.Role;
import com.hongchu.cbcommon.context.BaseContext;
import com.hongchu.cbservice.service.interfaces.ISystemNotificationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Slf4j
@RestController
@RequestMapping("/user/notification")
@RequiredArgsConstructor
public class NotificationController {

    private final ISystemNotificationService notificationService;

    @GetMapping("/unread")
    @Role({"ADMIN", "WHITE", "BUSINESS", "GUEST"})
    public Result<List<SystemNotificationVO>> getUnreadNotifications() {
        Long userId = BaseContext.getCurrentId();
        log.info("获取未读通知: userId={}", userId);
        return Result.success(notificationService.getUnreadNotifications(userId));
    }

    @GetMapping("/all")
    @Role({"ADMIN", "WHITE", "BUSINESS", "GUEST"})
    public Result<List<SystemNotificationVO>> getAllNotifications() {
        Long userId = BaseContext.getCurrentId();
        log.info("获取所有通知: userId={}", userId);
        return Result.success(notificationService.getAllNotifications(userId));
    }

    @GetMapping("/unread-count")
    @Role({"ADMIN", "WHITE", "BUSINESS", "GUEST"})
    public Result<Integer> getUnreadCount() {
        Long userId = BaseContext.getCurrentId();
        log.info("获取未读通知数量: userId={}", userId);
        return Result.success(notificationService.getUnreadCount(userId));
    }

    @PutMapping("/read/{notificationId}")
    @Role({"ADMIN", "WHITE", "BUSINESS", "GUEST"})
    public Result<String> markAsRead(@PathVariable Long notificationId) {
        Long userId = BaseContext.getCurrentId();
        log.info("标记通知已读: userId={}, notificationId={}", userId, notificationId);
        notificationService.markAsRead(notificationId, userId);
        return Result.success("已标记为已读");
    }

    @PutMapping("/read-all")
    @Role({"ADMIN", "WHITE", "BUSINESS", "GUEST"})
    public Result<String> markAllAsRead() {
        Long userId = BaseContext.getCurrentId();
        log.info("标记所有通知已读: userId={}", userId);
        notificationService.markAllAsRead(userId);
        return Result.success("已全部标记为已读");
    }
}
