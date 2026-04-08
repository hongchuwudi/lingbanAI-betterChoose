package com.hongchu.cbservice.service.interfaces;

import com.baomidou.mybatisplus.extension.service.IService;
import com.hongchu.cbpojo.entity.FamilyBinding;
import com.hongchu.cbpojo.vo.FamilyBindingVO;

import java.util.List;

public interface IFamilyBindingService extends IService<FamilyBinding> {

    void addBinding(Long elderlyProfileId, Long childProfileId, String relationType, String elderlyToChildRelation);

    void deleteBinding(Long id);

    void updateBinding(Long id, String relationType);

    void updateStatus(Long id, Integer status);

    List<FamilyBindingVO> getMyRelations();

    List<FamilyBindingVO> getPendingBindings();

    FamilyBindingVO getBindingDetail(Long id);

    List<FamilyBindingVO> getElderlyRelations(Long elderlyProfileId);

    List<FamilyBindingVO> getChildRelations(Long childProfileId);
}
