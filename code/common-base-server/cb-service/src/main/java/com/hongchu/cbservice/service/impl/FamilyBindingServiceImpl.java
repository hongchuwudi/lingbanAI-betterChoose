package com.hongchu.cbservice.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hongchu.cbcommon.context.BaseContext;
import com.hongchu.cbcommon.exception.BusinessException;
import com.hongchu.cbcommon.vo.WebSocketMessage;
import com.hongchu.cbpojo.entity.ChildProfile;
import com.hongchu.cbpojo.entity.ElderlyProfile;
import com.hongchu.cbpojo.entity.FamilyBinding;
import com.hongchu.cbpojo.entity.User;
import com.hongchu.cbpojo.vo.FamilyBindingVO;
import com.hongchu.cbservice.mapper.ChildProfileMapper;
import com.hongchu.cbservice.mapper.ElderlyProfileMapper;
import com.hongchu.cbservice.mapper.FamilyBindingMapper;
import com.hongchu.cbservice.mapper.UserMapper;
import com.hongchu.cbservice.service.interfaces.IFamilyBindingService;
import com.hongchu.cbservice.websocket.WebSocketUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class FamilyBindingServiceImpl extends ServiceImpl<FamilyBindingMapper, FamilyBinding> implements IFamilyBindingService {

    private final FamilyBindingMapper familyBindingMapper;
    private final ElderlyProfileMapper elderlyProfileMapper;
    private final ChildProfileMapper childProfileMapper;
    private final UserMapper userMapper;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void addBinding(Long elderlyProfileId, Long childProfileId, String relationType, String elderlyToChildRelation) {
        Long currentUserId = BaseContext.getCurrentId();
        
        ElderlyProfile elderlyProfile = elderlyProfileMapper.selectById(elderlyProfileId);
        ChildProfile childProfile = childProfileMapper.selectById(childProfileId);
        
        if (elderlyProfile == null) {
            throw new BusinessException("老人档案不存在");
        }
        if (childProfile == null) {
            throw new BusinessException("子女档案不存在");
        }
        
        Long count = lambdaQuery()
            .eq(FamilyBinding::getElderlyProfileId, elderlyProfileId)
            .eq(FamilyBinding::getChildProfileId, childProfileId)
            .count();
        if (count > 0) {
            throw new BusinessException("该关系已存在");
        }
        
        FamilyBinding binding = FamilyBinding.builder()
            .elderlyProfileId(elderlyProfileId)
            .childProfileId(childProfileId)
            .relationType(relationType)
            .elderlyToChildRelation(elderlyToChildRelation)
            .status(2)
            .build();
        
        save(binding);
        log.info("创建绑定关系成功: 老人档案ID={}, 子女档案ID={}, 子女对老人称呼={}, 老人对子女称呼={}", 
                elderlyProfileId, childProfileId, relationType, elderlyToChildRelation);
        
        User currentUser = userMapper.selectById(currentUserId);
        String currentUserName = currentUser != null ? currentUser.getNickname() : "用户";
        
        boolean isElderlyInitiator = elderlyProfile.getUserId().equals(currentUserId);
        Long receiverUserId;
        String displayRelation;
        
        if (isElderlyInitiator) {
            receiverUserId = childProfile.getUserId();
            displayRelation = relationType;
        } else {
            receiverUserId = elderlyProfile.getUserId();
            displayRelation = elderlyToChildRelation;
        }
        
        WebSocketMessage notification = WebSocketMessage.familyBindingRequest(
            String.valueOf(currentUserId),
            String.valueOf(receiverUserId),
            currentUserName,
            displayRelation
        );
        WebSocketUtil.notifyUser(String.valueOf(receiverUserId), notification);
        log.info("发送绑定请求通知: 发起者={}, 接收者={}", currentUserId, receiverUserId);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteBinding(Long id) {
        Long currentUserId = BaseContext.getCurrentId();
        
        FamilyBinding binding = getById(id);
        if (binding == null) {
            throw new BusinessException("绑定关系不存在");
        }
        
        ElderlyProfile elderlyProfile = elderlyProfileMapper.selectById(binding.getElderlyProfileId());
        ChildProfile childProfile = childProfileMapper.selectById(binding.getChildProfileId());
        
        User currentUser = userMapper.selectById(currentUserId);
        String currentUserName = currentUser != null ? currentUser.getNickname() : "用户";
        
        if (elderlyProfile != null && childProfile != null) {
            boolean isElderlyDeleting = elderlyProfile.getUserId().equals(currentUserId);
            Long receiverUserId;
            
            if (isElderlyDeleting) {
                receiverUserId = childProfile.getUserId();
            } else {
                receiverUserId = elderlyProfile.getUserId();
            }
            
            WebSocketMessage notification = WebSocketMessage.familyBindingDeleted(
                String.valueOf(currentUserId),
                String.valueOf(receiverUserId),
                currentUserName
            );
            WebSocketUtil.notifyUser(String.valueOf(receiverUserId), notification);
            log.info("发送删除绑定通知: 操作者={}, 接收者={}", currentUserId, receiverUserId);
        }
        
        removeById(id);
        log.info("删除绑定关系成功: ID={}", id);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateBinding(Long id, String relationType) {
        FamilyBinding binding = getById(id);
        if (binding == null) {
            throw new BusinessException("绑定关系不存在");
        }
        
        binding.setRelationType(relationType);
        updateById(binding);
        log.info("修改绑定关系成功: ID={}, 新关系={}", id, relationType);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateStatus(Long id, Integer status) {
        Long currentUserId = BaseContext.getCurrentId();
        
        FamilyBinding binding = getById(id);
        if (binding == null) {
            throw new BusinessException("绑定关系不存在");
        }
        
        if (status != 1 && status != 3) {
            throw new BusinessException("状态值无效，只能设置为1(已绑定)或3(已解绑)");
        }
        
        binding.setStatus(status);
        updateById(binding);
        log.info("更新绑定状态成功: ID={}, 新状态={}", id, status);
        
        ElderlyProfile elderlyProfile = elderlyProfileMapper.selectById(binding.getElderlyProfileId());
        ChildProfile childProfile = childProfileMapper.selectById(binding.getChildProfileId());
        
        if (elderlyProfile == null || childProfile == null) {
            return;
        }
        
        User currentUser = userMapper.selectById(currentUserId);
        String currentUserName = currentUser != null ? currentUser.getNickname() : "用户";
        
        boolean isElderlyConfirming = elderlyProfile.getUserId().equals(currentUserId);
        Long receiverUserId;
        String displayRelation;
        
        if (isElderlyConfirming) {
            receiverUserId = childProfile.getUserId();
            displayRelation = binding.getRelationType();
        } else {
            receiverUserId = elderlyProfile.getUserId();
            displayRelation = binding.getElderlyToChildRelation();
        }
        
        if (status == 1) {
            WebSocketMessage notification = WebSocketMessage.familyBindingConfirmed(
                String.valueOf(currentUserId),
                String.valueOf(receiverUserId),
                currentUserName,
                displayRelation
            );
            WebSocketUtil.notifyUser(String.valueOf(receiverUserId), notification);
            log.info("发送绑定确认通知: 确认者={}, 接收者={}", currentUserId, receiverUserId);
        } else if (status == 3) {
            WebSocketMessage notification = WebSocketMessage.familyBindingDeleted(
                String.valueOf(currentUserId),
                String.valueOf(receiverUserId),
                currentUserName
            );
            WebSocketUtil.notifyUser(String.valueOf(receiverUserId), notification);
            log.info("发送解绑通知: 操作者={}, 接收者={}", currentUserId, receiverUserId);
        }
    }

    @Override
    public List<FamilyBindingVO> getMyRelations() {
        Long userId = BaseContext.getCurrentId();
        List<FamilyBindingVO> result = new ArrayList<>();
        
        ElderlyProfile elderlyProfile = elderlyProfileMapper.selectOne(
            new LambdaQueryWrapper<ElderlyProfile>().eq(ElderlyProfile::getUserId, userId)
        );
        if (elderlyProfile != null) {
            List<FamilyBindingVO> elderlyRelations = getElderlyRelations(elderlyProfile.getId());
            for (FamilyBindingVO vo : elderlyRelations) {
                vo.setMyRole("elderly");
            }
            result.addAll(elderlyRelations);
        }
        
        ChildProfile childProfile = childProfileMapper.selectOne(
            new LambdaQueryWrapper<ChildProfile>().eq(ChildProfile::getUserId, userId)
        );
        if (childProfile != null) {
            List<FamilyBindingVO> childRelations = getChildRelations(childProfile.getId());
            for (FamilyBindingVO vo : childRelations) {
                vo.setMyRole("child");
            }
            result.addAll(childRelations);
        }
        
        return result;
    }

    @Override
    public List<FamilyBindingVO> getPendingBindings() {
        Long userId = BaseContext.getCurrentId();
        List<FamilyBindingVO> result = new ArrayList<>();
        
        ElderlyProfile elderlyProfile = elderlyProfileMapper.selectOne(
            new LambdaQueryWrapper<ElderlyProfile>().eq(ElderlyProfile::getUserId, userId)
        );
        if (elderlyProfile != null) {
            List<FamilyBinding> bindings = lambdaQuery()
                .eq(FamilyBinding::getElderlyProfileId, elderlyProfile.getId())
                .eq(FamilyBinding::getStatus, 2)
                .list();
            
            for (FamilyBinding binding : bindings) {
                FamilyBindingVO vo = convertToVO(binding, "elderly");
                result.add(vo);
            }
        }
        
        ChildProfile childProfile = childProfileMapper.selectOne(
            new LambdaQueryWrapper<ChildProfile>().eq(ChildProfile::getUserId, userId)
        );
        if (childProfile != null) {
            List<FamilyBinding> bindings = lambdaQuery()
                .eq(FamilyBinding::getChildProfileId, childProfile.getId())
                .eq(FamilyBinding::getStatus, 2)
                .list();
            
            for (FamilyBinding binding : bindings) {
                FamilyBindingVO vo = convertToVO(binding, "child");
                result.add(vo);
            }
        }
        
        return result;
    }

    @Override
    public FamilyBindingVO getBindingDetail(Long id) {
        FamilyBinding binding = getById(id);
        if (binding == null) {
            throw new BusinessException("绑定关系不存在");
        }
        return convertToVO(binding, null);
    }

    @Override
    public List<FamilyBindingVO> getElderlyRelations(Long elderlyProfileId) {
        List<FamilyBinding> bindings = lambdaQuery()
                .eq(FamilyBinding::getElderlyProfileId, elderlyProfileId)
                .eq(FamilyBinding::getStatus, 1)
                .list();

        List<FamilyBindingVO> result = new ArrayList<>();
        for (FamilyBinding binding : bindings) {
            FamilyBindingVO vo = convertToVO(binding, "elderly");
            result.add(vo);
        }
        return result;
    }

    @Override
    public List<FamilyBindingVO> getChildRelations(Long childProfileId) {
        List<FamilyBinding> bindings = lambdaQuery()
                .eq(FamilyBinding::getChildProfileId, childProfileId)
                .eq(FamilyBinding::getStatus, 1)
                .list();

        List<FamilyBindingVO> result = new ArrayList<>();
        for (FamilyBinding binding : bindings) {
            FamilyBindingVO vo = convertToVO(binding, "child");
            result.add(vo);
        }
        return result;
    }
    
    private FamilyBindingVO convertToVO(FamilyBinding binding, String myRole) {
        FamilyBindingVO vo = new FamilyBindingVO();
        vo.setId(String.valueOf(binding.getId()));
        vo.setElderlyProfileId(String.valueOf(binding.getElderlyProfileId()));
        vo.setChildProfileId(String.valueOf(binding.getChildProfileId()));
        vo.setRelationType(binding.getRelationType());
        vo.setElderlyToChildRelation(binding.getElderlyToChildRelation());
        vo.setStatus(binding.getStatus());
        vo.setCreatedAt(binding.getCreatedAt());
        vo.setUpdatedAt(binding.getUpdatedAt());
        vo.setMyRole(myRole);
        
        ElderlyProfile elderlyProfile = elderlyProfileMapper.selectById(binding.getElderlyProfileId());
        if (elderlyProfile != null) {
            User elderlyUser = userMapper.selectById(elderlyProfile.getUserId());
            if (elderlyUser != null) {
                vo.setElderlyName(elderlyUser.getNickname());
                vo.setElderlyAvatar(elderlyUser.getAvatar());
                vo.setElderlyPhone(elderlyUser.getPhone());
                vo.setElderlyGender(elderlyUser.getGender());
                vo.setElderlyBirthday(String.valueOf(elderlyUser.getBirthday()));
            }
            vo.setElderlyChronicDiseases(elderlyProfile.getChronicDiseases());
            vo.setElderlyAllergies(elderlyProfile.getAllergies());
            vo.setElderlyBloodType(elderlyProfile.getBloodType());
            vo.setElderlyHeight(elderlyProfile.getHeight());
            vo.setElderlyWeight(elderlyProfile.getWeight());
            vo.setElderlyLivingStatus(elderlyProfile.getLivingStatus());
            vo.setElderlyAddress(elderlyProfile.getAddress());
            vo.setElderlyEmergencyContact(elderlyProfile.getEmergencyContact());
            vo.setElderlyDietRestrictions(elderlyProfile.getDietRestrictions());
            vo.setElderlyMedicalHistory(elderlyProfile.getMedicalHistory());
        }
        
        ChildProfile childProfile = childProfileMapper.selectById(binding.getChildProfileId());
        if (childProfile != null) {
            User childUser = userMapper.selectById(childProfile.getUserId());
            if (childUser != null) {
                vo.setChildName(childUser.getNickname());
                vo.setChildAvatar(childUser.getAvatar());
                vo.setChildPhone(childUser.getPhone());
                vo.setChildGender(childUser.getGender());
                vo.setChildBirthday(String.valueOf(childUser.getBirthday()));
            }
            vo.setChildGuardianSettings(childProfile.getGuardianSettings());
            vo.setChildCheckinSettings(childProfile.getCheckinSettings());
        }
        
        return vo;
    }
}
