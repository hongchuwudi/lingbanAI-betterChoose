package com.hongchu.cbservice.service.interfaces.ai;

import org.springframework.web.multipart.MultipartFile;

import java.io.OutputStream;
import java.util.Map;

/**
 * 语音服务接口
 * 提供语音合成(TTS)和语音识别(ASR)能力
 */
public interface IVoiceService {

    /**
     * 语音合成 - 将文本转换为语音
     *
     * @param text 要合成的文本内容
     * @return 音频字节数组 (MP3格式)
     */
    byte[] synthesize(String text);

    /**
     * 流式语音合成 - 将文本转换为语音，边生成边输出
     *
     * @param text 要合成的文本内容
     * @param outputStream 输出流
     */
    void synthesizeStream(String text, OutputStream outputStream);

    /**
     * 语音合成并保存到OSS - 返回音频URL
     *
     * @param text 要合成的文本内容
     * @return 包含音频URL的Map
     */
    Map<String, String> synthesizeWithUrl(String text);

    /**
     * 语音识别 - 将音频转换为文本
     *
     * @param audioFile 音频文件
     *                  推荐格式: 16kHz采样率、单声道、WAV格式
     *                  支持格式: wav, mp3, pcm, opus, speex, amr等
     * @return 识别出的文本内容
     */
    String transcribe(MultipartFile audioFile);

    /**
     * 语音识别并保存原始音频到OSS - 返回文本和音频URL
     *
     * @param audioFile 音频文件
     * @return 包含text和audioUrl的Map
     */
    Map<String, String> transcribeWithUrl(MultipartFile audioFile);
}
