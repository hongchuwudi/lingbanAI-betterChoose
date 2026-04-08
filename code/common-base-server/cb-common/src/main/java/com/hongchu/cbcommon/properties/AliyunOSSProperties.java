package com.hongchu.cbcommon.properties;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

/**
 * 阿里云OSS配置类（纯配置类，不依赖Spring）
 * 在 lt-service 模块中通过 @ConfigurationProperties 绑定
 */
@Data
@Component
@ConfigurationProperties(prefix = "aliyun-oss")
public class AliyunOSSProperties {
    private String endpoint;
    private String bucketName;
    private String region;
    private String accessKeyId;
    private String accessKeySecret;
}
