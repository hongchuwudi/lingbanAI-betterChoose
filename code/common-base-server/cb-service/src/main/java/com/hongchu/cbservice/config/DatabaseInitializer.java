package com.hongchu.cbservice.config;

import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@RequiredArgsConstructor
public class DatabaseInitializer {

    private final JdbcTemplate jdbcTemplate;

    @PostConstruct
    public void init() {
        createFriendMessageTable();
    }

    private void createFriendMessageTable() {
        try {
            jdbcTemplate.execute("""
                CREATE TABLE IF NOT EXISTS friend_message (
                    id BIGSERIAL PRIMARY KEY,
                    from_user_id BIGINT NOT NULL,
                    to_user_id BIGINT NOT NULL,
                    content TEXT NOT NULL,
                    message_type VARCHAR(20) NOT NULL DEFAULT 'text',
                    status INTEGER NOT NULL DEFAULT 0,
                    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
                )
                """);
            jdbcTemplate.execute("""
                CREATE INDEX IF NOT EXISTS idx_fm_from
                ON friend_message(from_user_id, created_at DESC)
                """);
            jdbcTemplate.execute("""
                CREATE INDEX IF NOT EXISTS idx_fm_to
                ON friend_message(to_user_id, created_at DESC)
                """);
            log.info("friend_message 表初始化完成");
        } catch (Exception e) {
            log.warn("friend_message 表初始化失败（可能已存在）: {}", e.getMessage());
        }
    }
}
