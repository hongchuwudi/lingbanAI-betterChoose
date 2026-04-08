package com.hongchu.cbcommon.exception;

import com.hongchu.cbcommon.result.Result;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.jdbc.BadSqlGrammarException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.sql.SQLIntegrityConstraintViolationException;

/**
 * 全局异常处理器，处理项目中抛出的业务异常
 */
@RestControllerAdvice
@Slf4j
public class GlobalExceptionHandler {

    /**
     * 捕获业务异常
     */
    @ExceptionHandler(BusinessException.class)
    public Result<String> exceptionHandler(BusinessException ex){
        log.error("业务异常信息：{}", ex.getMessage());
        return Result.fail(ex.getMessage());
    }

    /**
     * 捕获SQL语法错误异常（新增 - 处理Unknown column错误）
     */
    @ExceptionHandler(BadSqlGrammarException.class)
    public Result<String> exceptionHandler(BadSqlGrammarException ex){
        log.error("SQL语法异常：{}", ex.getMessage());

        String message = ex.getMessage();
        if(message != null && message.contains("Unknown column")){
            return Result.fail("数据库字段不存在，请联系管理员");
        } else if(message != null && message.contains("Table") && message.contains("doesn't exist")){
            return Result.fail("数据库表不存在，请联系管理员");
        }

        return Result.fail("数据库操作异常");
    }

    /**
     * 捕获唯一约束异常（新增 - 处理DuplicateKeyException）
     */
    @ExceptionHandler(DuplicateKeyException.class)
    public Result<String> exceptionHandler(DuplicateKeyException ex){
        String message = ex.getMessage();
        log.error("唯一约束异常：{}", message);

        if(message != null && message.contains("Duplicate entry")){
            try{
                String[] split = message.split("'");
                if(split.length >= 2){
                    String username = split[1];
                    return Result.fail(username + "已存在");
                }
            } catch(Exception e){
                // 解析失败，返回通用提示
            }
        }
        return Result.fail("数据已存在，请勿重复添加");
    }

    /**
     * 捕获SQL唯一约束异常（原逻辑保留）
     */
    @ExceptionHandler(SQLIntegrityConstraintViolationException.class)
    public Result<String> exceptionHandler(SQLIntegrityConstraintViolationException ex){
        String message = ex.getMessage();
        log.error("SQL完整性约束异常：{}", message);

        if(message != null && message.contains("Duplicate entry")){
            try{
                String[] split = message.split("'");
                if(split.length >= 2){
                    String value = split[1];
                    return Result.fail(value + "早已存在");
                }
            } catch(Exception e){
                // 解析失败，返回通用提示
            }
        } else if(message != null && message.contains("foreign key constraint fails")){
            return Result.fail("存在关联数据，无法删除");
        } else if(message != null && message.contains("cannot be null")){
            return Result.fail("必填字段不能为空");
        }

        return Result.fail("数据库操作失败");
    }

    /**
     * 捕获参数验证异常
     */
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public Result<String> exceptionHandler(MethodArgumentNotValidException ex){
        String message = ex.getBindingResult().getFieldError().getDefaultMessage();
        log.error("参数验证异常：{}", message);
        return Result.fail("参数错误：" + message);
    }

    /**
     * 捕获所有其他异常
     */
    @ExceptionHandler(Exception.class)
    public Result<String> exceptionHandler(Exception ex){
        log.error("系统异常信息：", ex);
        return Result.fail("系统繁忙，请稍后重试");
    }
}