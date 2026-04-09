## Flutter 项目关键部署信息总结

---

## 一、项目基本信息

| 项目 | 值 |
|------|-----|
| **应用名称** | 灵伴AI |
| **包名 (Android)** | `com.example.common_base_mobile_flutter` |
| **版本号** | `1.0.0+1` |
| **最低 SDK** | Android 5.0 (API 21) |
| **目标 SDK** | Android 14 (API 34) |

---

## 二、签名信息（发布版）

| 项目 | 值 |
|------|-----|
| **密钥库文件** | `android/key.jks` |
| **密钥别名** | `hc-key` |
| **密钥库密码** | `hongchu` |
| **密钥密码** | `hongchu` |
| **发布版 SHA1** | `7F:6D:F0:34:EC:6E:B1:92:7E:C7:96:93:A8:AD:C1:1B:59:D8:1A:CD` |

---

## 三、百度地图 AK 安全码

| 类型 | 安全码 |
|------|--------|
| **开发版** | `FD:90:4D:72:D0:2D:34:2E:5F:04:B5:44:6B:4A:4F:47:2D:FA:7B:4A;com.example.common_base_mobile_flutter` |
| **发布版** | `7F:6D:F0:34:EC:6E:B1:92:7E:C7:96:93:A8:AD:C1:1B:59:D8:1A:CD;com.example.common_base_mobile_flutter` |

---

## 四、后端服务配置

| 服务 | 地址 | 端口 |
|------|------|------|
| **后端 API** | `172.17.0.1` 或 `localhost` | `15555` |
| **PostgreSQL** | `172.17.0.1` | `10020` |
| **Redis** | `172.17.0.1` | `10001` |
| **RabbitMQ** | `172.17.0.1` | `10030` |
| **MinIO** | `172.17.0.1` | `10040` |

---

## 五、关键依赖版本

| 依赖 | 版本 |
|------|------|
| **record** | `5.1.0`（锁定版本） |
| **dio** | `^5.4.0` |
| **flutter_baidu_mapapi_map** | `^5.1.0` |
| **url_launcher** | `^6.2.0` |

---

## 六、打包命令

```bash
# 调试版
flutter build apk --debug

# 正式版
flutter build apk --release

# 分架构打包（体积更小）
flutter build apk --release --split-per-abi

# App Bundle（Google Play）
flutter build appbundle --release
```

---

## 七、环境变量（构建时）

```bash
# 国内镜像加速
set PUB_HOSTED_URL=https://pub.flutter-io.cn
set FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
```

---

## 八、部署目录结构（服务器）

```
/home/hongchu/lingban/
├── deploy.sh                 # 自动化部署脚本
├── Dockerfile                # Docker 镜像构建文件
└── server/
    └── cb-service.jar        # Spring Boot jar 包
```

---

## 九、服务器容器列表

| 容器名 | 端口 | 用途 |
|--------|------|------|
| `postgres15-10020` | `10020` | PostgreSQL 数据库 |
| `redis-10001` | `10001` | Redis 缓存 |
| `rabbitmq-10030` | `10030/10031` | RabbitMQ 消息队列 |
| `minio-10040` | `10040/10041` | MinIO 对象存储 |
| `lingban-backend` | `15555` | 后端服务（待部署） |

---

## 十、注意事项

| 项目 | 注意事项 |
|------|----------|
| **包名** | 正式发布前建议改为 `com.hongchu.lingbanai` |
| **百度地图 AK** | 修改包名后需要重新生成安全码 |
| **record 版本** | 锁定 `5.1.0`，避免 `record_linux` 编译错误 |
| **定位权限** | 需要在 Android 模拟器手动设置位置 |
| **邮件发送** | 使用 QQ 邮箱授权码，非登录密码 |