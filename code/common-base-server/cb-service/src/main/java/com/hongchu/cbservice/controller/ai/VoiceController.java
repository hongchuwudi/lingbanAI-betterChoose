package com.hongchu.cbservice.controller.ai;

import com.hongchu.cbservice.service.interfaces.ai.IVoiceService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.method.annotation.StreamingResponseBody;

import java.io.OutputStream;

@Tag(name = "语音AI接口", description = "语音合成与语音识别相关接口")
@RequiredArgsConstructor
@RestController
@RequestMapping("/ai/voice")
@Slf4j
public class VoiceController {

    private final IVoiceService voiceService;

    @Operation(summary = "语音合成(GET)", description = "将文本转换为语音，流式返回MP3格式音频，支持URL直接播放")
    @GetMapping(value = "/synthesize", produces = MediaType.APPLICATION_OCTET_STREAM_VALUE)
    public ResponseEntity<StreamingResponseBody> synthesizeGet(
            @Parameter(description = "要合成的文本内容", required = true)
            @RequestParam("text") String text) {
        
        log.info("收到语音合成请求(GET), 文本长度: {}", text != null ? text.length() : 0);
        
        if (text == null || text.trim().isEmpty()) {
            log.warn("文本内容为空");
            return ResponseEntity.badRequest().build();
        }

        StreamingResponseBody stream = outputStream -> {
            try {
                voiceService.synthesizeStream(text, outputStream);
            } catch (Exception e) {
                log.error("流式语音合成异常: {}", e.getMessage(), e);
            }
        };

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.parseMediaType("audio/mpeg"));
        headers.set(HttpHeaders.TRANSFER_ENCODING, "chunked");
        headers.set(HttpHeaders.CACHE_CONTROL, "no-cache");

        log.info("开始流式语音合成");
        return ResponseEntity.ok()
                .headers(headers)
                .body(stream);
    }

    @Operation(summary = "语音合成(POST)", description = "将文本转换为语音，流式返回MP3格式音频")
    @PostMapping(value = "/synthesize", produces = MediaType.APPLICATION_OCTET_STREAM_VALUE)
    public ResponseEntity<StreamingResponseBody> synthesize(
            @Parameter(description = "要合成的文本内容", required = true)
            @RequestBody java.util.Map<String, String> request) {
        
        String text = request.get("text");
        log.info("收到语音合成请求(POST), 文本长度: {}", text != null ? text.length() : 0);
        
        if (text == null || text.trim().isEmpty()) {
            log.warn("文本内容为空");
            return ResponseEntity.badRequest().build();
        }

        StreamingResponseBody stream = outputStream -> {
            try {
                voiceService.synthesizeStream(text, outputStream);
            } catch (Exception e) {
                log.error("流式语音合成异常: {}", e.getMessage(), e);
            }
        };

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.parseMediaType("audio/mpeg"));
        headers.set(HttpHeaders.TRANSFER_ENCODING, "chunked");

        log.info("开始流式语音合成");
        return ResponseEntity.ok()
                .headers(headers)
                .body(stream);
    }

    @Operation(summary = "语音识别", description = "将音频文件转换为文本，推荐使用16kHz单声道WAV格式")
    @PostMapping(value = "/transcribe", consumes = MediaType.MULTIPART_FORM_DATA_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<java.util.Map<String, String>> transcribe(
            @Parameter(description = "音频文件 (推荐: 16kHz单声道WAV)", required = true)
            @RequestParam("file") MultipartFile file) {
        
        log.info("收到语音识别请求, 文件名: {}, 大小: {} bytes, 类型: {}", 
                file.getOriginalFilename(), file.getSize(), file.getContentType());

        if (file == null || file.isEmpty()) {
            log.warn("音频文件为空");
            return ResponseEntity.badRequest().body(java.util.Map.of("text", ""));
        }

        try {
            String text = voiceService.transcribe(file);
            
            if (text == null || text.trim().isEmpty()) {
                log.warn("语音识别返回空文本");
                return ResponseEntity.ok(java.util.Map.of("text", ""));
            }

            log.info("语音识别成功, 文本长度: {}", text.length());
            return ResponseEntity.ok(java.util.Map.of("text", text));
            
        } catch (Exception e) {
            log.error("语音识别异常: {}", e.getMessage(), e);
            return ResponseEntity.internalServerError().body(java.util.Map.of("text", "", "error", e.getMessage()));
        }
    }

    @Operation(summary = "语音识别并保存", description = "将音频文件转换为文本，同时保存原始音频到OSS，返回文本和音频URL")
    @PostMapping(value = "/transcribe-with-url", consumes = MediaType.MULTIPART_FORM_DATA_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<java.util.Map<String, String>> transcribeWithUrl(
            @Parameter(description = "音频文件", required = true)
            @RequestParam("file") MultipartFile file) {
        
        log.info("收到语音识别并保存请求, 文件名: {}, 大小: {} bytes", 
                file.getOriginalFilename(), file.getSize());

        if (file == null || file.isEmpty()) {
            log.warn("音频文件为空");
            return ResponseEntity.badRequest().body(java.util.Map.of("text", "", "audioUrl", ""));
        }

        try {
            java.util.Map<String, String> result = voiceService.transcribeWithUrl(file);
            log.info("语音识别并保存成功, 文本长度: {}, 音频URL: {}", 
                    result.get("text") != null ? result.get("text").length() : 0, 
                    result.get("audioUrl"));
            return ResponseEntity.ok(result);
            
        } catch (Exception e) {
            log.error("语音识别并保存异常: {}", e.getMessage(), e);
            return ResponseEntity.internalServerError().body(java.util.Map.of("text", "", "audioUrl", "", "error", e.getMessage()));
        }
    }

    @Operation(summary = "语音合成并保存", description = "将文本转换为语音，保存到OSS并返回音频URL")
    @PostMapping(value = "/synthesize-with-url", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<java.util.Map<String, String>> synthesizeWithUrl(
            @Parameter(description = "要合成的文本内容", required = true)
            @RequestBody java.util.Map<String, String> request) {
        
        String text = request.get("text");
        log.info("收到语音合成并保存请求, 文本长度: {}", text != null ? text.length() : 0);
        
        if (text == null || text.trim().isEmpty()) {
            log.warn("文本内容为空");
            return ResponseEntity.badRequest().body(java.util.Map.of("audioUrl", ""));
        }

        try {
            java.util.Map<String, String> result = voiceService.synthesizeWithUrl(text);
            log.info("语音合成并保存成功, 音频URL: {}", result.get("audioUrl"));
            return ResponseEntity.ok(result);
            
        } catch (Exception e) {
            log.error("语音合成并保存异常: {}", e.getMessage(), e);
            return ResponseEntity.internalServerError().body(java.util.Map.of("audioUrl", "", "error", e.getMessage()));
        }
    }
}
