package com.hongchu.cbservice.service.impl.auth;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hongchu.cbcommon.context.BaseContext;
import com.hongchu.cbcommon.context.ErrorMessageConstants;
import com.hongchu.cbcommon.exception.BusinessException;
import com.hongchu.cbpojo.entity.ChildProfile;
import com.hongchu.cbpojo.vo.ChildProfileVO;
import com.hongchu.cbservice.mapper.ChildProfileMapper;
import com.hongchu.cbservice.service.interfaces.auth.IChildProfileService;
import com.hongchu.cbservice.service.interfaces.auth.IUserRoleService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

/**
 * 子女档案服务实现类
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ChildProfileServiceImpl extends ServiceImpl<ChildProfileMapper, ChildProfile> implements IChildProfileService {

    private final ChildProfileMapper childProfileMapper;
    private final IUserRoleService userRoleService;

    private Long getCurrentUserId() {
        Long userId = BaseContext.getCurrentId();
        if (userId == null) {
            throw new BusinessException(ErrorMessageConstants.ERROR_USER_NOT_LOGIN);
        }
        return userId;
    }

    private ChildProfileVO convertToVO(ChildProfile profile) {
        if (profile == null) return null;
        ChildProfileVO vo = new ChildProfileVO();
        BeanUtils.copyProperties(profile, vo);
        return vo;
    }

    @Override
    public ChildProfileVO getChildProfileByCurrentUser() {
        Long userId = getCurrentUserId();
        ChildProfile profile = lambdaQuery().eq(ChildProfile::getUserId, userId).one();
        return convertToVO(profile);
    }

    @Override
    public ChildProfileVO getChildProfileByUserId(Long userId) {
        ChildProfile profile = lambdaQuery().eq(ChildProfile::getUserId, userId).one();
        return convertToVO(profile);
    }

    @Override
    public boolean isChildUser() {
        Long userId = getCurrentUserId();
        return lambdaQuery().eq(ChildProfile::getUserId, userId).exists();
    }

    @Override
    public ChildProfileVO createChildProfile(ChildProfile childProfile) {
        Long userId = getCurrentUserId();

        if (isChildUser()) throw new BusinessException("该用户已存在子女档案信息");

        childProfile.setUserId(userId);
        
        LocalDateTime now = LocalDateTime.now();
        childProfile.setCreatedAt(now);
        childProfile.setUpdatedAt(now);
        
        save(childProfile);
        
        userRoleService.assignRoleToUser(userId, "young", "子女", "BUSINESS", "子女用户");
        
        log.info("创建子女档案成功，用户ID={}", userId);
        return getChildProfileByCurrentUser();
    }

    @Override
    public ChildProfileVO updateChildProfile(ChildProfile childProfile) {
        Long userId = getCurrentUserId();

        ChildProfile existing = lambdaQuery().eq(ChildProfile::getUserId, userId).one();
        if (existing == null) throw new BusinessException("子女档案不存在");

        childProfile.setId(existing.getId());
        childProfile.setUserId(userId);
        updateById(childProfile);
        log.info("更新子女档案成功，用户ID={}", userId);
        return getChildProfileByCurrentUser();
    }

    @Override
    public void deleteChildProfile() {
        Long userId = getCurrentUserId();

        boolean removed = lambdaUpdate().eq(ChildProfile::getUserId, userId).remove();
        if (!removed) throw new BusinessException("子女档案不存在或删除失败");

        log.info("删除子女档案成功，用户ID={}", userId);
    }
}