## 提示词：实现健康指标文档解析助手（PDF/图片 → 结构化JSON → 数据库）

请帮我基于 Spring Boot + Spring AI 实现一个后端服务，功能如下：

### 1. 接口定义
- **URL**: `POST /api/health/parse-document`
- **请求**: `multipart/form-data`，包含一个文件（`file`），仅支持 PDF 或图片（jpg/png）。
- **响应**: 返回解析出的健康指标 JSON 数组，同时已将数据存入数据库。

### 2. 处理流程
1. **文件接收**：校验文件类型，限制大小（如 10MB）。
2. **PDF 分片处理**：
   - 如果是 PDF，使用 Apache PDFBox 或 pdfbox 将每一页转换为图片（或提取文本，但推荐转图片保留布局）。
   - 如果是图片，直接使用原图。
   - 将所有图片（每页一张）准备传给多模态大模型。
3. **调用大模型**：
   - 使用你已配置的 `ChatClient`（阿里云 DashScope 兼容 OpenAI 接口，模型 `qwen-max-latest`）。
   - 系统提示词（System Prompt）：
     ```
     你是一位专业的老年健康体检报告解读助手。请分析上传的文档（可能是体检报告、化验单或手写记录），从中提取所有可识别的健康指标。
     
     提取规则：
     1. 只提取明确给出的指标数值和单位。
     2. 对于血压，需要同时提取收缩压、舒张压，以及脉搏（如果有）。
     3. 对于血糖，需要区分空腹/餐后（如果文档有标注）。
     4. 输出必须是严格的 JSON 数组，每个对象包含以下字段：
        - indicatorCode: 指标代码（使用预定义列表，见下方）
        - value: 数值（数字）
        - unit: 单位（字符串）
        - recordTime: 测量时间（ISO格式，如果文档没有则使用当前时间）
        - type: 仅血糖需要，值为 "fasting" 或 "postprandial"
     
     预定义指标代码：
     bp_systolic, bp_diastolic, pulse, glucose_fasting, glucose_postprandial, heart_rate, weight, spo2, steps, sleep_duration, total_cholesterol, triglyceride, hdl_cholesterol, ldl_cholesterol, creatinine, uric_acid, alt, ast, ...
     
     不要输出任何额外解释，只输出 JSON 数组。
     ```
   - 用户提示词：将每一页图片作为 media 传入，并附加文本 `"请分析这份文档，提取健康指标。"`
4. **结构化输出**：使用 Spring AI 的 `BeanOutputConverter` 或直接解析返回的 JSON 字符串，转换成 `List<ExtractedHealthIndicator>`。
5. **数据库存储**：
   - 根据 `indicatorCode` 判断存入哪张专用表（血压、血糖等）或通用表 `health_record`。
   - 血压：将收缩压和舒张压合并为一条记录（相同 recordTime）。
   - 其他指标：逐条插入对应的专用表或通用表。
   - 使用当前登录用户 ID（从 `BaseContext.getCurrentId()` 获取）。
6. **返回结果**：返回解析出的指标列表（包含识别后的值、单位、状态等）给前端。

### 3. 代码结构要求
- Controller: `HealthParseController`，接收文件，调用 Service。
- Service: `HealthParseService`，负责文件处理、AI 调用、数据存储。
- Util: `PdfUtil`（将 PDF 转为 List<byte[]> 图片）。
- DTO: `ExtractedHealthIndicator`（包含 indicatorCode, value, unit, recordTime, type）。
- 使用已有的 `HealthRecordService` 和专用表的 Mapper/Service。

### 4. 技术栈与配置
- Spring Boot 2.7+ / 3.x
- Spring AI 已配置（`ChatClient` Bean 可用）
- PDF 处理依赖：
  ```xml
  <dependency>
      <groupId>org.apache.pdfbox</groupId>
      <artifactId>pdfbox</artifactId>
      <version>2.0.29</version>
  </dependency>
  ```
- 图片处理：`ImageIO` 或直接使用 `MultipartFile.getBytes()`
- 数据库：PostgreSQL，已有 `health_record`、`blood_pressure_record`、`glucose_record` 等表。

### 5. 注意事项
- 大模型调用可能耗时，前端需显示 loading。
- 需要处理异常：文件解析失败、AI 返回非 JSON、数据库保存失败等，统一返回友好错误信息。
- 对于 PDF，只转换前 5 页（避免 token 超限）。
- 图片大小压缩：若图片过大，可等比缩放到 1024px 宽再传给模型。

### 6. 输出
请生成完整的 Java 代码：
- `HealthParseController.java`
- `HealthParseService.java`
- `PdfUtil.java`
- `ExtractedHealthIndicator.java`
- 以及在 `HealthRecordService` 中添加 `saveExtractedIndicators` 方法的实现片段。

确保代码可直接集成到现有项目（已有 Spring AI、MyBatis-Plus、BaseContext 等基础设施）。