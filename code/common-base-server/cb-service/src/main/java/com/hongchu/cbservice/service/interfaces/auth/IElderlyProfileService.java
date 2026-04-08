package com.hongchu.cbservice.service.interfaces.auth;

import com.baomidou.mybatisplus.extension.service.IService;
import com.hongchu.cbpojo.entity.ElderlyProfile;
import com.hongchu.cbpojo.vo.ElderlyProfileVO;

/**
 * 老人档案服务接口
 */
public interface IElderlyProfileService extends IService<ElderlyProfile> {

    /**
     * 获取当前用户的老人档案
     */
    ElderlyProfileVO getElderlyProfileByCurrentUser();

    /**
     * 根据用户ID获取老人档案
     */
    ElderlyProfileVO getElderlyProfileByUserId(Long userId);

    /**
     * 判断当前用户是否为老人用户
     */
    boolean isElderlyUser();

    /**
     * 创建当前用户的老人档案
     */
    ElderlyProfileVO createElderlyProfile(ElderlyProfile elderlyProfile);

    /**
     * 更新当前用户的老人档案
     */
    ElderlyProfileVO updateElderlyProfile(ElderlyProfile elderlyProfile);

    /**
     * 删除当前用户的老人档案
     */
    void deleteElderlyProfile();
}