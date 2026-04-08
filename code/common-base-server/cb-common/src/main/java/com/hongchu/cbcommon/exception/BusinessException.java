// BusinessException.java
package com.hongchu.cbcommon.exception;

public class BusinessException extends RuntimeException {
    public BusinessException(String message) {
        super(message);
    }
}