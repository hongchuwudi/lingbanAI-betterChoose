package com.hongchu.cbcommon.properties;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Data
@Configuration
@ConfigurationProperties(prefix = "my-jwt")
public class JwtProperties {
    private String secret;                                  //  Token密钥
    private Long  expiration;                               //  Token过期时间
    private Long  refreshTokenExpiration;                   //  Refresh Token过期时间
    private String tokenHeader = "Authorization";           //  Token请求头名称
    private String refreshTokenHeader = "Refresh-Token";    //   Refresh Token请求头名称
}