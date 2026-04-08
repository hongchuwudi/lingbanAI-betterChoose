package com.hongchu.cbservice.service.impl.auth;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hongchu.cbcommon.context.BaseContext;
import com.hongchu.cbcommon.context.ErrorMessageConstants;
import com.hongchu.cbcommon.exception.BusinessException;
import com.hongchu.cbpojo.entity.ElderlyProfile;
import com.hongchu.cbpojo.vo.ElderlyProfileVO;
import com.hongchu.cbservice.mapper.ElderlyProfileMapper;
import com.hongchu.cbservice.service.interfaces.auth.IElderlyProfileService;
import com.hongchu.cbservice.service.interfaces.auth.IUserRoleService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

/**
 * 老人档案服务实现类
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ElderlyProfileServiceImpl extends ServiceImpl<ElderlyProfileMapper, ElderlyProfile> implements IElderlyProfileService {

    private final ElderlyProfileMapper elderlyProfileMapper;
    private final IUserRoleService userRoleService;

    private Long getCurrentUserId() {
        Long userId = BaseContext.getCurrentId();
        if (userId == null)
            throw new BusinessException(ErrorMessageConstants.ERROR_USER_NOT_LOGIN);

        return userId;
    }

    private ElderlyProfileVO convertToVO(ElderlyProfile profile) {
        if (profile == null) return null;
        ElderlyProfileVO vo = new ElderlyProfileVO();
        BeanUtils.copyProperties(profile, vo);
        return vo;
    }

    @Override
    public ElderlyProfileVO getElderlyProfileByCurrentUser() {
        Long userId = getCurrentUserId();
        ElderlyProfile profile = lambdaQuery().eq(ElderlyProfile::getUserId, userId).one();
        return convertToVO(profile);
    }

    @Override
    public ElderlyProfileVO getElderlyProfileByUserId(Long userId) {
        ElderlyProfile profile = lambdaQuery().eq(ElderlyProfile::getUserId, userId).one();
        return convertToVO(profile);
    }

    @Override
    public boolean isElderlyUser() {
        Long userId = getCurrentUserId();
        return lambdaQuery().eq(ElderlyProfile::getUserId, userId).exists();
    }

    @Override
    public ElderlyProfileVO createElderlyProfile(ElderlyProfile elderlyProfile) {
        Long userId = getCurrentUserId();

        if (isElderlyUser()) throw new BusinessException("该用户已存在老人档案信息");

        elderlyProfile.setUserId(userId);
        
        LocalDateTime now = LocalDateTime.now();
        elderlyProfile.setCreatedAt(now);
        elderlyProfile.setUpdatedAt(now);
        
        save(elderlyProfile);
        
        userRoleService.assignRoleToUser(userId, "oldMan", "老人", "BUSINESS", "老人用户");
        
        log.info("创建老人档案成功，用户ID={}", userId);
        return getElderlyProfileByCurrentUser();
    }

    @Override
    public ElderlyProfileVO updateElderlyProfile(ElderlyProfile elderlyProfile) {
        Long userId = getCurrentUserId();

        ElderlyProfile existing = lambdaQuery().eq(ElderlyProfile::getUserId, userId).one();
        if (existing == null) throw new BusinessException("老人档案不存在");

        elderlyProfile.setId(existing.getId());
        elderlyProfile.setUserId(userId);
        updateById(elderlyProfile);
        log.info("更新老人档案成功，用户ID={}", userId);
        return getElderlyProfileByCurrentUser();
    }

    @Override
    public void deleteElderlyProfile() {
        Long userId = getCurrentUserId();

        boolean removed = lambdaUpdate().eq(ElderlyProfile::getUserId, userId).remove();
        if (!removed) throw new BusinessException("老人档案不存在或删除失败");

        log.info("删除老人档案成功，用户ID={}", userId);
    }
}