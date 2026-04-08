package com.hongchu.cbservice.service.impl.ai;

import com.hongchu.cbcommon.util.AliyunOSSOperator;
import com.hongchu.cbservice.service.interfaces.ai.IChatFileService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

/**
 * 聊天文件服务实现类
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ChatFileServiceImpl implements IChatFileService {

    private final AliyunOSSOperator aliyunOSSOperator;

    @Override
    public List<String> uploadImages(List<MultipartFile> files, Long userId) {
        List<String> imageUrls = new ArrayList<>();
        if (files == null || files.isEmpty() || userId == null) {
            return imageUrls;
        }
        
        for (MultipartFile file : files) {
            try {
                String fileUrl = aliyunOSSOperator.upload(
                        file.getBytes(),
                        Objects.requireNonNull(file.getOriginalFilename()),
                        "chat");
                imageUrls.add(fileUrl);
                log.debug("上传聊天图片成功: {}", fileUrl);
            } catch (Exception e) {
                log.error("上传聊天图片失败: {}", e.getMessage());
            }
        }
        return imageUrls;
    }
}
