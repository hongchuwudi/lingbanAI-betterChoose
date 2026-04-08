package com.hongchu.cbservice.controller;

import com.hongchu.cbcommon.result.Result;
import com.hongchu.cbcommon.util.AliyunOSSOperator;
import com.hongchu.cbpojo.vo.FileUploadResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.Objects;

/**
 * 文件管理通用控制器.
 *
 * <p>
 * 封装了对阿里云 OSS 的文件上传能力，提供统一的上传入口，包含：
 * </p>
 * <ul>
 * <li>基础上传：接收前端上传的 MultipartFile</li>
 * <li>业务类型标记：通过 bizType 区分不同业务场景下的文件</li>
 * <li>标准化的上传结果封装</li>
 * </ul>
 *
 * @author hongchu
 * @since 2025-12-18
 */
@RestController
@Slf4j
@RequestMapping("/file")
@CrossOrigin
public class FileController {

    /**
     * OSS 操作工具类.
     *
     * <p>
     * 封装了与阿里云对象存储交互的底层细节。
     * </p>
     */
    @Autowired
    private AliyunOSSOperator aliyunOSSOperator;

    /**
     * 上传文件到对象存储.
     *
     * <p>
     * 上传前会对文件是否为空进行基础校验，并在成功后返回统一的文件信息。
     * </p>
     *
     * @param file    前端上传的文件
     * @param bizType 业务类型标识，例如：avatar、homework、resource 等，默认值为 other
     * @return 上传结果包装，包含文件访问地址、大小等信息
     * @throws Exception 当底层上传过程出现异常时抛出
     */
    @PostMapping("/upload")
    public Result<FileUploadResponse> upload(
            @RequestParam("file") MultipartFile file,
            @RequestParam(value = "bizType", required = false, defaultValue = "other") String bizType)
            throws Exception {
        String originalFilename = file.getOriginalFilename();
        log.info("文件上传: {}, bizType: {}", originalFilename, bizType);

        // 1. 验证文件
        if (file.isEmpty()) {
            log.warn("文件为空: {}", originalFilename);
            return Result.fail("文件不能为空");
        }

        // 2. 上传文件到OSS
        String fileUrl = aliyunOSSOperator.upload(
                file.getBytes(),
                Objects.requireNonNull(originalFilename),
                bizType);

        // 3. 构建响应对象
        FileUploadResponse response = FileUploadResponse.of(
                file.getOriginalFilename(),
                fileUrl,
                file.getSize(),
                file.getContentType()
        );

        // 4.返回结果
        log.info("文件上传成功: fileName={}, fileSize={}, fileUrl={}",
                originalFilename, file.getSize(), fileUrl);
        return Result.success(response);
    }

    /**
     * 通过文件对象路径删除对象存储中的文件.
     *
     * <p>
     * 此方法使用文件在OSS中的内部存储路径（objectName）进行删除，适合以下场景：
     * </p>
     * <ul>
     * <li>后台管理系统，已知文件在OSS中的完整存储路径</li>
     * <li>业务代码中存储了文件的对象路径而非访问URL</li>
     * <li>需要直接操作OSS存储结构的场景</li>
     * </ul>
     *
     * <p><strong>对象路径格式说明：</strong></p>
     * <pre>
     * 对象路径由 {@link #upload} 方法生成，格式为：
     * {bizType}/{yyyy}/{MM}/{uuid}{extension}
     *
     * 示例：
     * 1. avatar/2024/12/550e8400-e29b-41d4-a716-446655440000.jpg
     * 2. assignment/2024/11/6ba7b810-9dad-11d1-80b4-00c04fd430c8.pdf
     * 3. other/2024/10/123e4567-e89b-12d3-a456-426614174000.png
     * </pre>
     *
     * <p><strong>与URL删除的区别：</strong></p>
     * <ul>
     * <li>此方法需要<strong>对象路径</strong>，如：avatar/2024/12/uuid.jpg</li>
     * <li>{@link #deleteByUrl} 方法需要<strong>完整访问URL</strong></li>
     * </ul>
     *
     * <p><strong>注意事项：</strong></p>
     * <ol>
     * <li>对象路径不包含协议头、域名和Bucket名称</li>
     * <li>路径中的斜杠(/)为目录分隔符，实际存储为扁平结构</li>
     * <li>删除操作不可逆，请谨慎调用</li>
     * <li>如果文件不存在，OSS会静默返回成功（实际无文件可删）</li>
     * </ol>
     *
     * @param objectName 文件在OSS中的对象存储路径，通常由 {@link #upload} 方法生成
     * @return 删除操作结果，成功返回"删除成功"，失败返回具体错误信息
     */
    @PostMapping("/delete")
    public Result<String> delete(@RequestParam("file-url") String objectName) {
        boolean result = aliyunOSSOperator.delete(objectName);
        return result ? Result.success("删除成功") : Result.fail("删除失败");
    }

    /**
     * 通过文件访问URL删除对象存储中的文件.
     *
     * <p>
     * 与直接使用对象路径删除相比，此方法更加灵活和便捷，客户端无需解析URL即可直接删除文件。
     * 适用于以下典型场景：
     * </p>
     * <ul>
     * <li>前端已获取文件完整访问URL，需要直接使用该URL进行删除操作</li>
     * <li>业务代码中仅保存了文件访问URL，未保存原始对象路径</li>
     * <li>需要提供与上传返回结果直接对应的删除接口</li>
     * </ul>
     *
     * <p><strong>URL格式要求：</strong></p>
     * <pre>
     * 支持阿里云OSS标准访问URL格式：
     * 1. HTTPS格式：https://{bucket}.{endpoint}/{objectName}
     *    示例：<a href="https://my-bucket.oss-cn-hangzhou.aliyuncs.com/avatar/2024/12/uuid123.jpg">...</a>
     * 2. HTTP格式：http://{bucket}.{endpoint}/{objectName}
     *    示例：<a href="http://my-bucket.oss-cn-hangzhou.aliyuncs.com/avatar/2024/12/uuid123.jpg">...</a>
     * </pre>
     *
     * <p><strong>处理流程：</strong></p>
     * <ol>
     * <li>从URL中提取Bucket名称和对象路径</li>
     * <li>验证当前配置的Bucket与URL中的Bucket是否匹配（安全校验）</li>
     * <li>调用OSS删除接口执行删除操作</li>
     * <li>返回操作结果</li>
     * </ol>
     *
     * @param fileUrl 文件的完整访问URL，通常由 {@link #upload} 方法返回
     * @return 删除操作结果，成功返回"删除成功"，失败返回具体错误信息
     */
    @PostMapping("/delete-by-url")
    public Result<String> deleteByUrl(@RequestParam("file-url") String fileUrl) {
        log.info("通过URL删除文件: {}", fileUrl);

        // 1. 参数校验
        if (fileUrl == null || fileUrl.trim().isEmpty()) {
            log.warn("删除请求中的文件URL为空");
            return Result.fail("文件URL不能为空");
        }

        // 2. 执行删除
        boolean result = aliyunOSSOperator.deleteByUrl(fileUrl);

        // 3. 返回结果
        if (result) {
            log.info("文件删除成功: {}", fileUrl);
            return Result.success("删除成功");
        } else {
            log.error("文件删除失败: {}", fileUrl);
            return Result.fail("删除失败，请检查文件URL是否正确");
        }
    }
}