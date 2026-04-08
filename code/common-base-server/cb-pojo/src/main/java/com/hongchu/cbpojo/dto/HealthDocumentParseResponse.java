package com.hongchu.cbpojo.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class HealthDocumentParseResponse {
    private Long recordId;
    private String status;
    private String fileUrl;
    private String fileName;
    private LocalDateTime createdAt;
}
