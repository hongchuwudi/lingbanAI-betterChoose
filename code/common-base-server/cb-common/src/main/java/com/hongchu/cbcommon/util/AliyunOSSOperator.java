package com.hongchu.cbcommon.util;

import com.aliyun.oss.OSS;
import com.aliyun.oss.OSSClientBuilder;
import com.aliyun.oss.OSSException;
import com.aliyun.oss.ClientException;
import com.hongchu.cbcommon.properties.AliyunOSSProperties;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.UUID;

@Component
@Slf4j
public class AliyunOSSOperator {

    @Autowired
    private AliyunOSSProperties aliyunOSSProperties;

    /**
     * 文件上传
     * @param bytes 文件字节数组
     * @param originalFilename 原始文件名
     * @param bizType 业务类型（avatar/assignment/other）
     * @return 文件访问URL
     */
    public String upload(byte[] bytes, String originalFilename, String bizType) {
        this.init();

        // 1. 从配置类获取配置
        String endpoint = aliyunOSSProperties.getEndpoint();
        String accessKeyId = aliyunOSSProperties.getAccessKeyId();
        String accessKeySecret = aliyunOSSProperties.getAccessKeySecret();
        String bucketName = aliyunOSSProperties.getBucketName();

        // 2. 生成存储路径
        String dir = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy/MM"));
        String newFileName = UUID.randomUUID() + getFileExtension(originalFilename);
        String objectName = buildObjectName(bizType, dir, newFileName);

        // 3. 创建OSSClient实例
        OSS ossClient = new OSSClientBuilder().build(endpoint, accessKeyId, accessKeySecret);

        try {
            log.info("开始上传文件到OSS: bucket={}, object={}, endpoint={}",
                    bucketName, objectName, endpoint);
            log.info("使用的AccessKeyId: {}...", accessKeyId.substring(0, Math.min(8, accessKeyId.length())));

            // 4. 上传文件
            ossClient.putObject(bucketName, objectName, new ByteArrayInputStream(bytes));

            // 5. 生成访问URL
            String url = generateUrl(bucketName, endpoint, objectName);
            log.info("文件上传成功: {}", url);
            return url;

        } catch (OSSException oe) {
            log.error("OSS服务异常 - ErrorCode: {}, ErrorMessage: {}, RequestId: {}",
                    oe.getErrorCode(), oe.getErrorMessage(), oe.getRequestId());
            throw new RuntimeException("OSS服务异常: " + oe.getErrorMessage(), oe);
        } catch (ClientException ce) {
            log.error("OSS客户端异常: {}", ce.getMessage());
            throw new RuntimeException("网络连接异常: " + ce.getMessage(), ce);
        } catch (Exception e) {
            log.error("文件上传异常", e);
            throw new RuntimeException("文件上传失败: " + e.getMessage(), e);
        } finally {
            if (ossClient != null) {
                ossClient.shutdown();
            }
        }
    }

    /**
     * 文件删除
     * @param objectName 文件对象名
     * @return 是否删除成功
     */
    public boolean delete(String objectName) {
        String endpoint = aliyunOSSProperties.getEndpoint();
        String accessKeyId = aliyunOSSProperties.getAccessKeyId();
        String accessKeySecret = aliyunOSSProperties.getAccessKeySecret();
        String bucketName = aliyunOSSProperties.getBucketName();

        OSS ossClient = new OSSClientBuilder().build(endpoint, accessKeyId, accessKeySecret);

        try {
            ossClient.deleteObject(bucketName, objectName);
            log.info("文件删除成功: {}", objectName);
            return true;
        } catch (Exception e) {
            log.error("文件删除失败: {}", objectName, e);
            return false;
        } finally {
            if (ossClient != null) {
                ossClient.shutdown();
            }
        }
    }

    /**
     * 文件删除（通过文件URL）
     * @param fileUrl 文件的完整访问URL
     * @return 是否删除成功
     */
    public boolean deleteByUrl(String fileUrl) {
        // 从URL中提取objectName
        String objectName = extractObjectNameFromUrl(fileUrl);
        if (objectName == null) {
            log.error("无法从URL中提取objectName: {}", fileUrl);
            return false;
        }

        // 调用原有的delete方法
        return delete(objectName);
    }

    /**
     * 从OSS文件URL中提取objectName
     */
    private String extractObjectNameFromUrl(String fileUrl) {
        if (fileUrl == null || fileUrl.isEmpty()) {
            return null;
        }

        try {
            // 支持的URL格式：
            // 1. https://bucket-name.oss-cn-hangzhou.aliyuncs.com/avatar/2024/12/abc123.jpg
            // 2. http://bucket-name.oss-cn-hangzhou.aliyuncs.com/avatar/2024/12/abc123.jpg

            // 移除协议头
            String urlWithoutProtocol;
            if (fileUrl.startsWith("https://")) {
                urlWithoutProtocol = fileUrl.substring(8);
            } else if (fileUrl.startsWith("http://")) {
                urlWithoutProtocol = fileUrl.substring(7);
            } else {
                // 如果URL没有协议头，可能已经是objectName了
                return fileUrl;
            }

            // 查找第一个斜杠，斜杠后的就是objectName
            int slashIndex = urlWithoutProtocol.indexOf('/');
            if (slashIndex == -1) {
                return null;
            }

            return urlWithoutProtocol.substring(slashIndex + 1);

        } catch (Exception e) {
            log.error("解析URL失败: {}", fileUrl, e);
            return null;
        }
    }

    /**
     * 生成访问URL
     */
    private String generateUrl(String bucketName, String endpoint, String objectName) {
        // 如果endpoint包含https://，需要处理
        if (endpoint.startsWith("https://")) {
            String cleanEndpoint = endpoint.substring(8); // 移除 https://
            return String.format("https://%s.%s/%s", bucketName, cleanEndpoint, objectName);
        } else if (endpoint.startsWith("http://")) {
            String cleanEndpoint = endpoint.substring(7); // 移除 http://
            return String.format("http://%s.%s/%s", bucketName, cleanEndpoint, objectName);
        } else {
            // endpoint没有协议头，直接拼接
            return String.format("https://%s.%s/%s", bucketName, endpoint, objectName);
        }
    }

    /**
     * 获取文件扩展名
     */
    private String getFileExtension(String filename) {
        if (filename == null || filename.isEmpty()) return "";
        int dotIndex = filename.lastIndexOf('.');
        return dotIndex > 0 ? filename.substring(dotIndex) : "";
    }

    /**
     * 构建存储路径
     */
    private String buildObjectName(String bizType, String dir, String filename) {
        StringBuilder builder = new StringBuilder();

        // 业务类型目录
        if (bizType != null && !bizType.trim().isEmpty()) {
            String normalizedBizType = bizType.trim().toLowerCase();
            if ("avatar".equals(normalizedBizType) ||
                    "assignment".equals(normalizedBizType) ||
                    "other".equals(normalizedBizType)) {
                builder.append(normalizedBizType).append("/");
            } else {
                builder.append("other/");
            }
        } else {
            builder.append("other/");
        }

        // 日期目录 + 文件名
        builder.append(dir).append("/").append(filename);
        return builder.toString();
    }

    /**
     * 初始化时打印配置信息（用于调试）
     */
    public void init() {
        log.info("OSS配置初始化完成:");
        log.info("  - endpoint: {}", aliyunOSSProperties.getEndpoint());
        log.info("  - bucketName: {}", aliyunOSSProperties.getBucketName());
        log.info("  - accessKeyId: {}", aliyunOSSProperties.getAccessKeyId());
        log.info("  - region: {}", aliyunOSSProperties.getRegion());

        // 检查配置是否解析
        String endpoint = aliyunOSSProperties.getEndpoint();
        if (endpoint != null && endpoint.contains("${")) {
            log.error("❌ endpoint配置未解析: {}", endpoint);
        }
    }
}