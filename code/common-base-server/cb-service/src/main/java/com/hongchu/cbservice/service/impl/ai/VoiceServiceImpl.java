package com.hongchu.cbservice.service.impl.ai;

import com.alibaba.dashscope.audio.asr.transcription.*;
import com.alibaba.dashscope.audio.tts.SpeechSynthesisResult;
import com.alibaba.dashscope.audio.ttsv2.SpeechSynthesisParam;
import com.alibaba.dashscope.audio.ttsv2.SpeechSynthesizer;
import com.alibaba.dashscope.common.ResultCallback;
import com.alibaba.dashscope.common.TaskStatus;
import com.hongchu.cbcommon.exception.VoiceServiceException;
import com.hongchu.cbcommon.util.AliyunOSSOperator;
import com.hongchu.cbservice.service.interfaces.ai.IVoiceService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.ByteArrayOutputStream;
import java.io.OutputStream;
import java.nio.ByteBuffer;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;

@Service
@Slf4j
public class VoiceServiceImpl implements IVoiceService {

    @Value("${hcprop.ai.dashscope.api-key}")
    private String apiKey;

    @Autowired
    private AliyunOSSOperator aliyunOSSOperator;

    private static final String TTS_MODEL = "cosyvoice-v1";
    private static final String TTS_VOICE = "longhua";
    private static final String ASR_MODEL = "paraformer-v2";

    @Override
    public byte[] synthesize(String text) {
        log.info("开始语音合成, 文本长度: {}", text.length());
        long startTime = System.currentTimeMillis();

        try {
            SpeechSynthesisParam param = SpeechSynthesisParam.builder()
                    .apiKey(apiKey)
                    .model(TTS_MODEL)
                    .voice(TTS_VOICE)
                    .build();

            SpeechSynthesizer synthesizer = new SpeechSynthesizer(param, null);
            ByteBuffer audioBuffer = synthesizer.call(text);
            synthesizer.getDuplexApi().close(1000, "completed");

            if (audioBuffer == null) {
                log.error("语音合成返回空数据");
                throw new VoiceServiceException("语音合成返回空数据");
            }

            byte[] audioData = new byte[audioBuffer.remaining()];
            audioBuffer.get(audioData);

            long costTime = System.currentTimeMillis() - startTime;
            log.info("语音合成完成, 音频大小: {} bytes, 耗时: {} ms", audioData.length, costTime);

            return audioData;
        } catch (Exception e) {
            log.error("语音合成失败: {}", e.getMessage(), e);
            throw new VoiceServiceException("语音合成失败: " + e.getMessage(), e);
        }
    }

    @Override
    public void synthesizeStream(String text, OutputStream outputStream) {
        log.info("开始流式语音合成, 文本长度: {}", text.length());
        long startTime = System.currentTimeMillis();

        CountDownLatch latch = new CountDownLatch(1);
        final int[] totalBytes = {0};
        final Throwable[] error = {null};

        ResultCallback<SpeechSynthesisResult> callback = new ResultCallback<SpeechSynthesisResult>() {
            @Override
            public void onEvent(SpeechSynthesisResult result) {
                try {
                    if (result.getAudioFrame() != null) {
                        ByteBuffer audioFrame = result.getAudioFrame();
                        byte[] chunk = new byte[audioFrame.remaining()];
                        audioFrame.get(chunk);
                        outputStream.write(chunk);
                        outputStream.flush();
                        totalBytes[0] += chunk.length;
                        log.debug("收到音频数据块: {} bytes", chunk.length);
                    }
                } catch (Exception e) {
                    log.error("写入音频数据失败: {}", e.getMessage());
                    error[0] = e;
                    latch.countDown();
                }
            }

            @Override
            public void onComplete() {
                log.debug("TTS合成完成");
                latch.countDown();
            }

            @Override
            public void onError(Exception e) {
                log.error("TTS合成错误: {}", e.getMessage());
                error[0] = e;
                latch.countDown();
            }
        };

        try {
            SpeechSynthesisParam param = SpeechSynthesisParam.builder()
                    .apiKey(apiKey)
                    .model(TTS_MODEL)
                    .voice(TTS_VOICE)
                    .build();

            SpeechSynthesizer synthesizer = new SpeechSynthesizer(param, callback);
            synthesizer.streamingCall(text);
            synthesizer.streamingComplete();

            if (!latch.await(60, TimeUnit.SECONDS)) {
                throw new VoiceServiceException("流式语音合成超时");
            }

            if (error[0] != null) {
                throw new VoiceServiceException("流式语音合成失败: " + error[0].getMessage(), error[0]);
            }

            synthesizer.getDuplexApi().close(1000, "completed");

            long costTime = System.currentTimeMillis() - startTime;
            log.info("流式语音合成完成, 总大小: {} bytes, 耗时: {} ms", totalBytes[0], costTime);

        } catch (VoiceServiceException e) {
            throw e;
        } catch (Exception e) {
            log.error("流式语音合成失败: {}", e.getMessage(), e);
            throw new VoiceServiceException("流式语音合成失败: " + e.getMessage(), e);
        }
    }

    @Override
    public Map<String, String> synthesizeWithUrl(String text) {
        log.info("开始语音合成并保存, 文本长度: {}", text.length());
        long startTime = System.currentTimeMillis();

        try {
            byte[] audioData = synthesize(text);
            
            if (audioData == null || audioData.length == 0) {
                throw new VoiceServiceException("语音合成返回空数据");
            }

            String fileName = "tts_" + System.currentTimeMillis() + ".mp3";
            String audioUrl = aliyunOSSOperator.upload(audioData, fileName, "voice/tts");

            long costTime = System.currentTimeMillis() - startTime;
            log.info("语音合成并保存完成, 音频大小: {} bytes, URL: {}, 耗时: {} ms", 
                    audioData.length, audioUrl, costTime);

            Map<String, String> result = new HashMap<>();
            result.put("audioUrl", audioUrl);
            return result;
        } catch (VoiceServiceException e) {
            throw e;
        } catch (Exception e) {
            log.error("语音合成并保存失败: {}", e.getMessage(), e);
            throw new VoiceServiceException("语音合成并保存失败: " + e.getMessage(), e);
        }
    }

    @Override
    public String transcribe(MultipartFile audioFile) {
        log.info("开始语音识别, 文件名: {}, 大小: {} bytes", 
                audioFile.getOriginalFilename(), audioFile.getSize());
        long startTime = System.currentTimeMillis();

        try {
            byte[] fileBytes = audioFile.getBytes();
            String httpUrl = aliyunOSSOperator.upload(fileBytes, audioFile.getOriginalFilename(), "voice");
            log.info("音频文件上传到OSS成功, HTTP URL: {}", httpUrl);

            TranscriptionParam param = TranscriptionParam.builder()
                    .apiKey(apiKey)
                    .model(ASR_MODEL)
                    .parameter("language_hints", new String[]{"zh", "en"})
                    .fileUrls(Collections.singletonList(httpUrl))
                    .build();

            Transcription transcription = new Transcription();
            TranscriptionResult result = transcription.asyncCall(param);
            log.info("语音识别任务已提交, taskId: {}", result.getTaskId());

            result = transcription.wait(TranscriptionQueryParam.FromTranscriptionParam(param, result.getTaskId()));

            TaskStatus taskStatus = result.getTaskStatus();
            log.info("语音识别任务状态: {}", taskStatus);

            if (taskStatus != TaskStatus.SUCCEEDED) {
                String errorMsg = "语音识别任务失败: " + taskStatus;
                if (result.getResults() != null && !result.getResults().isEmpty()) {
                    TranscriptionTaskResult taskResult = result.getResults().get(0);
                    if (taskResult.getMessage() != null) {
                        errorMsg += ", 原因: " + taskResult.getMessage();
                        log.error("语音识别失败详情: {}", taskResult.getMessage());
                    }
                }
                throw new VoiceServiceException(errorMsg);
            }

            String text = extractTranscriptionText(result);
            
            long costTime = System.currentTimeMillis() - startTime;
            log.info("语音识别完成, 文本长度: {}, 耗时: {} ms", 
                    text != null ? text.length() : 0, costTime);

            return text;
        } catch (VoiceServiceException e) {
            throw e;
        } catch (Exception e) {
            log.error("语音识别失败: {}", e.getMessage(), e);
            throw new VoiceServiceException("语音识别失败: " + e.getMessage(), e);
        }
    }

    @Override
    public Map<String, String> transcribeWithUrl(MultipartFile audioFile) {
        log.info("开始语音识别并保存, 文件名: {}, 大小: {} bytes", 
                audioFile.getOriginalFilename(), audioFile.getSize());
        long startTime = System.currentTimeMillis();

        try {
            byte[] fileBytes = audioFile.getBytes();
            String originalFileName = audioFile.getOriginalFilename();
            String extension = "m4a";
            if (originalFileName != null && originalFileName.contains(".")) {
                extension = originalFileName.substring(originalFileName.lastIndexOf(".") + 1);
            }
            
            String fileName = "asr_" + System.currentTimeMillis() + "." + extension;
            String audioUrl = aliyunOSSOperator.upload(fileBytes, fileName, "voice/asr");
            log.info("音频文件上传到OSS成功, HTTP URL: {}", audioUrl);

            TranscriptionParam param = TranscriptionParam.builder()
                    .apiKey(apiKey)
                    .model(ASR_MODEL)
                    .parameter("language_hints", new String[]{"zh", "en"})
                    .fileUrls(Collections.singletonList(audioUrl))
                    .build();

            Transcription transcription = new Transcription();
            TranscriptionResult result = transcription.asyncCall(param);
            log.info("语音识别任务已提交, taskId: {}", result.getTaskId());

            result = transcription.wait(TranscriptionQueryParam.FromTranscriptionParam(param, result.getTaskId()));

            TaskStatus taskStatus = result.getTaskStatus();
            log.info("语音识别任务状态: {}", taskStatus);

            if (taskStatus != TaskStatus.SUCCEEDED) {
                String errorMsg = "语音识别任务失败: " + taskStatus;
                if (result.getResults() != null && !result.getResults().isEmpty()) {
                    TranscriptionTaskResult taskResult = result.getResults().get(0);
                    if (taskResult.getMessage() != null) {
                        errorMsg += ", 原因: " + taskResult.getMessage();
                        log.error("语音识别失败详情: {}", taskResult.getMessage());
                    }
                }
                throw new VoiceServiceException(errorMsg);
            }

            String text = extractTranscriptionText(result);
            
            long costTime = System.currentTimeMillis() - startTime;
            log.info("语音识别并保存完成, 文本长度: {}, 耗时: {} ms", 
                    text != null ? text.length() : 0, costTime);

            Map<String, String> resultMap = new HashMap<>();
            resultMap.put("text", text != null ? text : "");
            resultMap.put("audioUrl", audioUrl);
            return resultMap;
        } catch (VoiceServiceException e) {
            throw e;
        } catch (Exception e) {
            log.error("语音识别并保存失败: {}", e.getMessage(), e);
            throw new VoiceServiceException("语音识别并保存失败: " + e.getMessage(), e);
        }
    }

    private String extractTranscriptionText(TranscriptionResult result) {
        try {
            java.util.List<TranscriptionTaskResult> results = result.getResults();
            if (results != null && !results.isEmpty()) {
                TranscriptionTaskResult taskResult = results.get(0);
                String transcriptionUrl = taskResult.getTranscriptionUrl();
                
                log.info("转录结果URL: {}", transcriptionUrl);
                
                if (transcriptionUrl != null) {
                    java.net.URL url = new java.net.URL(transcriptionUrl);
                    java.io.BufferedReader reader = new java.io.BufferedReader(
                            new java.io.InputStreamReader(url.openStream()));
                    StringBuilder jsonBuilder = new StringBuilder();
                    String line;
                    while ((line = reader.readLine()) != null) {
                        jsonBuilder.append(line);
                    }
                    reader.close();
                    
                    String jsonStr = jsonBuilder.toString();
                    log.debug("转录结果JSON: {}", jsonStr);
                    
                    org.json.JSONObject transcriptionJson = new org.json.JSONObject(jsonStr);
                    if (transcriptionJson.has("transcripts")) {
                        org.json.JSONArray transcripts = transcriptionJson.getJSONArray("transcripts");
                        StringBuilder textBuilder = new StringBuilder();
                        for (int i = 0; i < transcripts.length(); i++) {
                            org.json.JSONObject transcript = transcripts.getJSONObject(i);
                            textBuilder.append(transcript.getString("text"));
                        }
                        return textBuilder.toString();
                    }
                }
            }
            return "";
        } catch (Exception e) {
            log.error("解析语音识别结果失败: {}", e.getMessage(), e);
            return "";
        }
    }
}
