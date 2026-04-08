package com.hongchu.cbpojo.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@TableName("family_binding")
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class FamilyBinding {

    @TableId(type = IdType.AUTO)
    private Long id;

    /** 老人档案ID */
    @TableField("elderly_profile_id")
    private Long elderlyProfileId;

    /** 子女档案ID */
    @TableField("child_profile_id")
    private Long childProfileId;

    /** 关系类型 - 子女对老人的称呼（如：父亲、母亲、爷爷、奶奶） */
    @TableField("relation_type")
    private String relationType;

    /** 老人对子女的称呼（如：儿子、女儿、孙子、孙女） */
    @TableField("elderly_to_child_relation")
    private String elderlyToChildRelation;

    /** 状态 */
    private Integer status;

    @TableField(value = "created_at", fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(value = "updated_at", fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}