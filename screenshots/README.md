# 截图目录说明

本目录用于存放项目截图，用于 README.md 文档展示。

## 目录结构

```
screenshots/
├── mobile/          # 移动端截图
│   ├── splash.png   # 启动页
│   ├── login.png    # 登录页
│   ├── home.png     # 首页
│   ├── health.png   # 健康监测
│   ├── medication.png # 用药管理
│   ├── chat.png     # AI对话
│   ├── map.png      # 家园定位
│   ├── family.png   # 家庭绑定
│   └── profile.png  # 个人中心
│
└── web/             # Web管理端截图
    ├── login.png    # 登录页
    ├── dashboard.png # 数据看板
    └── users.png    # 用户管理
```

## 截图要求

### 格式要求
- **文件格式**：PNG（推荐）或 JPG
- **分辨率**：建议 1080x1920（移动端）或 1920x1080（Web端）
- **文件大小**：单个文件不超过 2MB

### 内容要求
- 清晰展示功能界面
- 避免包含敏感信息（真实用户数据、密码等）
- 使用测试账号或模拟数据
- 保持界面整洁、美观

### 命名规范
- 使用英文小写字母
- 多个单词用下划线连接
- 见名知意，如：`health_monitoring.png`

## 如何添加截图

1. **移动端截图**
   ```bash
   # Android 模拟器
   flutter run -d emulator
   # 使用模拟器截图功能或 adb shell screencap

   # iOS 模拟器
   flutter run -d simulator
   # 使用模拟器截图功能（Cmd + S）
   ```

2. **Web端截图**
   ```bash
   cd code/common-base-web-vue
   npm run dev
   # 浏览器打开 http://localhost:5173
   # 使用浏览器截图工具或系统截图
   ```

3. **放置截图**
   - 将截图保存到对应目录
   - 确保文件名与 README.md 中的引用一致

## 注意事项

- ✅ 截图已添加到 `.gitignore`（如果包含敏感信息）
- ✅ 建议使用测试数据，避免真实用户信息
- ✅ 定期更新截图，保持与最新版本一致
- ❌ 不要提交包含敏感信息的截图
