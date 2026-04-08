package com.hongchu.cbservice.service.interfaces.ai;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.hongchu.cbpojo.dto.ExtractedHealthIndicator;
import com.hongchu.cbpojo.entity.health.HealthDocumentParseRecord;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;

public interface IHealthParseService {

    HealthDocumentParseRecord createParseRecord(MultipartFile file, Long userId) throws IOException;

    void parseDocumentAsync(Long recordId, byte[] fileBytes, String fileName, String contentType);

    HealthDocumentParseRecord getParseRecord(Long recordId);

    Page<HealthDocumentParseRecord> getParseRecordList(Long userId, int page, int size);

    List<ExtractedHealthIndicator> parseDocument(MultipartFile file) throws IOException;

    void saveIndicators(List<ExtractedHealthIndicator> indicators, Long userId);
}
