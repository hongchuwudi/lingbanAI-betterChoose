package com.hongchu.cbservice;

import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.mybatis.spring.annotation.MapperScan;
import org.springframework.context.annotation.EnableAspectJAutoProxy;
import org.springframework.scheduling.annotation.EnableAsync;

@Slf4j
@EnableAsync
@EnableAspectJAutoProxy
@SpringBootApplication(scanBasePackages = {"com.hongchu"})
@MapperScan({"com.hongchu.cbservice.mapper"})
public class ServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(ServiceApplication.class, args);
        log.info("!!!springboot3.x-common-base 启动成功!!!");
    }
}
