package com.hongchu.cbservice.service.interfaces.ai;

import org.springframework.web.multipart.MultipartFile;

import java.util.List;

/**
 * 聊天文件服务接口
 */
public interface IChatFileService {

    List<String> uploadImages(List<MultipartFile> files, Long userId);
}
