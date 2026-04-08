package com.hongchu.cbpojo.entity.health;

import com.baomidou.mybatisplus.annotation.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * 健康文档解析记录表
 */
@Data
@TableName("health_document_parse_record")
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class HealthDocumentParseRecord {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long userId;

    private String fileName;

    private String fileUrl;

    private String contentType;

    private Long fileSize;

    private String status;

    private Integer indicatorCount;

    private String errorMessage;

    private LocalDateTime parseStartTime;

    private LocalDateTime parseEndTime;

    @TableField(value = "created_at", fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(value = "updated_at", fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}
