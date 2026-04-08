package com.hongchu.cbservice.service.interfaces.auth;

import com.baomidou.mybatisplus.extension.service.IService;
import com.hongchu.cbpojo.entity.ChildProfile;
import com.hongchu.cbpojo.vo.ChildProfileVO;

/**
 * 子女档案服务接口
 */
public interface IChildProfileService extends IService<ChildProfile> {
    // 获取当前用户的子女档案
    ChildProfileVO getChildProfileByCurrentUser();
    // 根据用户ID获取子女档案
    ChildProfileVO getChildProfileByUserId(Long userId);
    // 判断当前用户是否为子女用户
    boolean isChildUser();
    // 创建当前用户的子女档案
    ChildProfileVO createChildProfile(ChildProfile childProfile);
    // 更新当前用户的子女档案
    ChildProfileVO updateChildProfile(ChildProfile childProfile);
    // 删除当前用户的子女档案
    void deleteChildProfile();
}