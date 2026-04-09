package com.hongchu.cbcommon.exception;

/**
 * 语音服务异常
 * 用于处理语音合成和语音识别过程中的异常
 */
public class VoiceServiceException extends RuntimeException {
    
    public VoiceServiceException(String message) {
        super(message);
    }
    
    public VoiceServiceException(String message, Throwable cause) {
        super(message, cause);
    }
}
