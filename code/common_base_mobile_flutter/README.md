# 灵伴-AI 老年健康管理平台

## 项目介绍

**灵伴-AI 守护你的健康**是一个专为老年人设计的健康管理移动应用，采用Flutter框架开发，支持Android和iOS双平台。

### 核心功能
- 🔐 **智能认证系统**：支持手机号验证码登录和账号密码登录
- 👵 **老年友好界面**：大字体、高对比度、简洁操作
- 💾 **本地数据存储**：自动保存登录状态，无需重复登录
- 🌐 **后端API集成**：与Java Spring Boot后端无缝对接
- 🎨 **闲鱼风格设计**：简洁清爽的UI界面，圆角设计

### 应用场景
- 老年人健康数据监测
- 用药提醒管理
- 家人远程关怀
- 健康咨询交流

## 项目文件树

```
common_base_mobile_flutter/
├── lib/                           # Dart源代码目录
│   ├── config/                    # 应用配置
│   │   └── app_config.dart        # 应用配置常量
│   ├── routes/                    # 路由管理
│   │   └── app_router.dart        # 应用路由配置
│   ├── screens/                   # 页面组件
│   │   ├── splash_screen.dart     # 启动页
│   │   ├── login_screen.dart      # 登录页
│   │   ├── register_screen.dart   # 注册页
│   │   ├── home_screen.dart       # 首页
│   │   └── welcome_screen.dart    # 欢迎页
│   ├── services/                  # 服务层
│   │   └── auth_service.dart      # 认证服务
│   └── main.dart                  # 应用入口文件
├── android/                       # Android平台相关代码
├── ios/                           # iOS平台相关代码
├── web/                           # Web平台相关代码
├── test/                          # 测试代码
├── pubspec.yaml                   # 项目依赖配置
└── README.md                      # 项目说明文档
```

## 技术框架介绍

### 核心技术栈

#### 1. Flutter框架
- **版本**: 3.x
- **特点**: Google开发的跨平台UI框架
- **优势**: 一套代码，多端运行（Android/iOS/Web）

#### 2. Dart语言
- **版本**: 3.x
- **特点**: 强类型、面向对象、异步编程
- **优势**: 高性能、易于学习、与Flutter完美集成

### 核心依赖包

```yaml
dependencies:
  # Flutter核心框架
  flutter:
    sdk: flutter
  
  # HTTP网络请求
  http: ^1.1.0
  
  # 本地数据存储
  shared_preferences: ^2.2.2
  
  # 路由管理
  go_router: ^13.0.1
  
  # 状态管理
  provider: ^6.1.1
  
  # 表单验证
  form_validator: ^2.1.1
  
  # 加载动画
  flutter_spinkit: ^5.2.0
  
  # 图标库
  font_awesome_flutter: ^10.7.0
  
  # 吐司提示
  fluttertoast: ^8.2.4
```

### 架构设计

#### 1. 分层架构
```
UI层 (Screens) → 服务层 (Services) → 数据层 (Local Storage/API)
```

#### 2. 状态管理
- **Provider模式**: 轻量级状态管理
- **单例模式**: 认证服务全局唯一实例
- **本地状态**: 页面级别的状态管理

#### 3. 路由管理
- **命名路由**: 清晰的页面导航
- **页面替换**: 避免页面堆栈过深
- **路由守卫**: 登录状态检查

### 核心功能模块

#### 1. 认证模块 (AuthService)
- **功能**: 用户登录、注册、退出
- **技术**: HTTP请求、本地存储、异步编程
- **特点**: 支持多种登录方式、自动保存状态

#### 2. 启动模块 (SplashScreen)
- **功能**: 应用启动、登录状态检查
- **技术**: 生命周期管理、页面跳转
- **特点**: 优雅的启动体验、智能路由

#### 3. 界面模块 (Screens)
- **设计**: Material Design + 闲鱼风格
- **特点**: 响应式布局、老年友好设计
- **交互**: 表单验证、加载状态、错误处理

### 开发规范

#### 1. 代码规范
- **命名规范**: 驼峰命名法
- **注释规范**: 详细的文档注释
- **文件组织**: 按功能模块分组

#### 2. 错误处理
- **网络异常**: 友好的错误提示
- **表单验证**: 实时验证反馈
- **异步处理**: 完善的异常捕获

#### 3. 性能优化
- **内存管理**: 及时释放资源
- **图片优化**: 合适的图片尺寸
- **代码分割**: 按需加载模块

## 快速开始

### 环境要求
- Flutter SDK 3.0+
- Dart SDK 3.0+
- Android Studio / VS Code

### 运行步骤

1. **克隆项目**
```bash
git clone <项目地址>
cd common_base_mobile_flutter
```

2. **安装依赖**
```bash
flutter pub get
```

3. **运行应用**
```bash
# 运行在Chrome浏览器
flutter run -d chrome

# 运行在Android模拟器
flutter run -d emulator

# 运行在iOS模拟器
flutter run -d simulator
```

4. **构建发布版本**
```bash
# 构建APK
flutter build apk

# 构建iOS应用
flutter build ios

# 构建Web应用
flutter build web
```

### 测试账号
- **手机号/用户名**: `hongchu123`
- **密码/验证码**: `hongchu123`

## 项目特色

### 1. 老年友好设计
- 大字体、高对比度界面
- 简洁直观的操作流程
- 语音提示和震动反馈支持

### 2. 技术先进性
- 现代化的Flutter框架
- 完善的错误处理机制
- 优秀的性能表现

### 3. 可扩展性
- 模块化架构设计
- 清晰的代码结构
- 易于维护和扩展

## 开发团队

本项目由灵伴-AI技术团队开发，专注于为老年人提供智能健康管理解决方案。

## 许可证

本项目采用MIT许可证，详情请查看LICENSE文件。

---

**灵伴-AI 守护你的健康** - 让科技温暖每一个家庭