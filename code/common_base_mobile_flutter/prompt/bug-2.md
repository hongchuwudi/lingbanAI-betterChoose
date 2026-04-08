2026-04-04T19:20:20.367+08:00  INFO 11964 --- [关爱老年人] [io-15555-exec-1] c.h.c.s.impl.ai.HealthParseServiceImpl   : PDF转换完成，共4页图片
2026-04-04T19:20:20.367+08:00  INFO 11964 --- [关爱老年人] [io-15555-exec-1] c.h.c.s.impl.ai.HealthParseServiceImpl   : 第1页图片大小: 78375 bytes
2026-04-04T19:20:20.367+08:00  INFO 11964 --- [关爱老年人] [io-15555-exec-1] c.h.c.s.impl.ai.HealthParseServiceImpl   : 第2页图片大小: 109370 bytes
2026-04-04T19:20:20.367+08:00  INFO 11964 --- [关爱老年人] [io-15555-exec-1] c.h.c.s.impl.ai.HealthParseServiceImpl   : 第3页图片大小: 153864 bytes
2026-04-04T19:20:20.367+08:00  INFO 11964 --- [关爱老年人] [io-15555-exec-1] c.h.c.s.impl.ai.HealthParseServiceImpl   : 第4页图片大小: 93352 bytes
2026-04-04T19:20:20.367+08:00  INFO 11964 --- [关爱老年人] [io-15555-exec-1] c.h.c.s.impl.ai.HealthParseServiceImpl   : 创建Media对象，图片数量: 4, 原始类型: application/pdf
2026-04-04T19:20:20.367+08:00  INFO 11964 --- [关爱老年人] [io-15555-exec-1] c.h.c.s.impl.ai.HealthParseServiceImpl   : 创建Media[0]: mimeType=image/png, size=78375 bytes
2026-04-04T19:20:20.367+08:00  INFO 11964 --- [关爱老年人] [io-15555-exec-1] c.h.c.s.impl.ai.HealthParseServiceImpl   : 创建Media[1]: mimeType=image/png, size=109370 bytes
2026-04-04T19:20:20.367+08:00  INFO 11964 --- [关爱老年人] [io-15555-exec-1] c.h.c.s.impl.ai.HealthParseServiceImpl   : 创建Media[2]: mimeType=image/png, size=153864 bytes
2026-04-04T19:20:20.367+08:00  INFO 11964 --- [关爱老年人] [io-15555-exec-1] c.h.c.s.impl.ai.HealthParseServiceImpl   : 创建Media[3]: mimeType=image/png, size=93352 bytes
2026-04-04T19:20:20.368+08:00  INFO 11964 --- [关爱老年人] [io-15555-exec-1] c.h.c.s.impl.ai.HealthParseServiceImpl   : 准备调用AI，图片数量: 4
2026-04-04T19:20:49.080+08:00  INFO 11964 --- [关爱老年人] [io-15555-exec-1] c.h.c.s.impl.ai.HealthParseServiceImpl   : AI响应内容: ```json
[
  {
    "indicatorCode": "bp_systolic",
    "value": 145,
    "unit": "mmHg",
    "recordTime": "2025-03-15T00:00:00Z"
  },
  {
    "indicatorCode": "bp_diastolic",
    "value": 92,
    "unit": "mmHg",
    "recordTime": "2025-03-15T00:00:00Z"
  },
  {
    "indicatorCode": "pulse",
    "value": 72,
    "unit": "次/分",
    "recordTime": "2025-03-15T00:00:00Z"
  },
  {
    "indicatorCode": "weight",
    "value": 68,
    "unit": "kg",
    "recordTime": "2025-03-15T00:00:00Z"
  },
  {
    "indicatorCode": "total_cholesterol",
    "value": 6.2,
    "unit": "mmol/L",
    "recordTime": "2025-03-15T00:00:00Z"
  },
  {
    "indicatorCode": "triglyceride",
    "value": 1.7,
    "unit": "mmol/L",
    "recordTime": "2025-03-15T00:00:00Z"
  },
  {
    "indicatorCode": "hdl_cholesterol",
    "value": 1.0,
    "unit": "mmol/L",
    "recordTime": "2025-03-15T00:00:00Z"
  },
  {
    "indicatorCode": "ldl_cholesterol",
    "value": 3.8,
    "unit": "mmol/L",
    "recordTime": "2025-03-15T00:00:00Z"
  },
  {
    "indicatorCode": "glucose_fasting",
    "value": 6.8,
    "unit": "mmol/L",
    "type": "fasting",
    "recordTime": "2025-03-15T00:00:00Z"
  },
  {
    "indicatorCode": "creatinine",
    "value": 78,
    "unit": "μmol/L",
    "recordTime": "2025-03-15T00:00:00Z"
  },
  {
    "indicatorCode": "uric_acid",
    "value": 360,
    "unit": "μmol/L",
    "recordTime": "2025-03-15T00:00:00Z"
  },
  {
    "indicatorCode": "alt",
    "value": 28,
    "unit": "U/L",
    "recordTime": "2025-03-15T00:00:00Z"
  },
  {
    "indicatorCode": "ast",
    "value": 32,
    "unit": "U/L",
    "recordTime": "2025-03-15T00:00:00Z"
  }
]
```
2026-04-04T19:20:49.272+08:00 ERROR 11964 --- [关爱老年人] [io-15555-exec-1] c.h.c.c.ai.HealthParseController         : AI解析失败: 
### Error updating database.  Cause: org.postgresql.util.PSQLException: ERROR: null value in column "systolic" of relation "blood_pressure_record" violates not-null constraint
  详细：Failing row contains (6, 2016856424387563521, null, 92, 72, 2026-04-04 19:20:49.082781, 文档解析, null, null, null).
### The error may exist in com/hongchu/cbservice/mapper/health/BloodPressureRecordMapper.java (best guess)
### The error may involve com.hongchu.cbservice.mapper.health.BloodPressureRecordMapper.insert-Inline
### The error occurred while setting parameters
### SQL: INSERT INTO blood_pressure_record  ( user_id,  diastolic, pulse, record_time, source,  created_at, updated_at )  VALUES (  ?,  ?, ?, ?, ?,  ?, ?  )
### Cause: org.postgresql.util.PSQLException: ERROR: null value in column "systolic" of relation "blood_pressure_record" violates not-null constraint
  详细：Failing row contains (6, 2016856424387563521, null, 92, 72, 2026-04-04 19:20:49.082781, 文档解析, null, null, null).
; ERROR: null value in column "systolic" of relation "blood_pressure_record" violates not-null constraint
  详细：Failing row contains (6, 2016856424387563521, null, 92, 72, 2026-04-04 19:20:49.082781, 文档解析, null, null, null).

org.springframework.dao.DataIntegrityViolationException: 
### Error updating database.  Cause: org.postgresql.util.PSQLException: ERROR: null value in column "systolic" of relation "blood_pressure_record" violates not-null constraint
  详细：Failing row contains (6, 2016856424387563521, null, 92, 72, 2026-04-04 19:20:49.082781, 文档解析, null, null, null).
### The error may exist in com/hongchu/cbservice/mapper/health/BloodPressureRecordMapper.java (best guess)
### The error may involve com.hongchu.cbservice.mapper.health.BloodPressureRecordMapper.insert-Inline
### The error occurred while setting parameters
### SQL: INSERT INTO blood_pressure_record  ( user_id,  diastolic, pulse, record_time, source,  created_at, updated_at )  VALUES (  ?,  ?, ?, ?, ?,  ?, ?  )
### Cause: org.postgresql.util.PSQLException: ERROR: null value in column "systolic" of relation "blood_pressure_record" violates not-null constraint
  详细：Failing row contains (6, 2016856424387563521, null, 92, 72, 2026-04-04 19:20:49.082781, 文档解析, null, null, null).
; ERROR: null value in column "systolic" of relation "blood_pressure_record" violates not-null constraint
  详细：Failing row contains (6, 2016