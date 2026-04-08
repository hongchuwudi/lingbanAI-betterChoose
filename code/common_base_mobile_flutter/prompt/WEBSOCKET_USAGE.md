# WebSocket 使用指南

## 前端使用

### 1. 登录后自动连接

登录成功后，WebSocket 会自动连接：

```dart
// 在 login_screen.dart 中
WebSocketService().connect().catchError((error) {
  print('WebSocket 连接失败，但不影响登录: $error');
});
```

### 2. 监听连接状态

```dart
// 添加连接状态监听
WebSocketService().addConnectionCallback((state) {
  switch (state) {
    case WebSocketConnectionState.connecting:
      print('正在连接 WebSocket...');
      break;
    case WebSocketConnectionState.connected:
      print('WebSocket 已连接');
      break;
    case WebSocketConnectionState.reconnecting:
      print('WebSocket 正在重连...');
      break;
    case WebSocketConnectionState.disconnected:
      print('WebSocket 已断开');
      break;
  }
});
```

### 3. 监听消息

```dart
// 添加消息监听
WebSocketService().addMessageCallback((message) {
  final type = message['type'];
  final data = message['data'];

  switch (type) {
    case 'system_notification':
      // 处理系统通知
      break;
    case 'chat_message':
      // 处理聊天消息
      break;
    case 'health_reminder':
      // 处理健康提醒
      break;
    case 'medication_reminder':
      // 处理用药提醒
      break;
  }
});
```

### 4. 发送消息

```dart
// 发送聊天消息
WebSocketService().sendMessage({
  'type': 'chat_message',
  'data': {
    'content': '你好'
  }
});
```

### 5. 刷新连接

```dart
// 刷新 WebSocket 连接
WebSocketService().refreshConnection();
```

### 6. 断开连接

```dart
// 断开 WebSocket 连接
WebSocketService().disconnect();
```

## 后端使用

### 1. 发送系统通知

```java
// 发送给单个用户
WebSocketUtil.sendSystemNotification(userId, "系统通知", "您的账户信息已更新");

// 发送给多个用户
List<String> userIds = Arrays.asList("123", "456", "789");
WebSocketUtil.sendSystemNotification(userIds, "系统通知", "系统维护通知");
```

### 2. 发送聊天消息

```java
WebSocketUtil.sendChatMessage(fromUserId, toUserId, "你好");
```

### 3. 发送健康提醒

```java
WebSocketUtil.sendHealthReminder(userId, "exercise", "该进行适量运动了");
```

### 4. 发送用药提醒

```java
WebSocketUtil.sendMedicationReminder(userId, "阿司匹林", "100mg", "08:00");
```

### 5. 发送连接成功消息

```java
WebSocketUtil.sendConnectedMessage(userId, username);
```

### 6. 发送心跳响应

```java
WebSocketUtil.sendPongMessage(userId);
```

### 7. 发送错误消息

```java
WebSocketUtil.sendErrorMessage(userId, "操作失败");
```

### 8. 广播消息

```java
// 广播给所有在线用户
WebSocketMessage message = WebSocketMessage.systemNotification("系统广播", "系统将在10分钟后维护", "warning");
WebSocketUtil.broadcast(message);
```

## 消息格式

### 系统通知
```json
{
  "type": "system_notification",
  "data": {
    "title": "系统通知",
    "content": "您的账户信息已更新",
    "level": "info"
  },
  "timestamp": 1711234567890
}
```

### 聊天消息
```json
{
  "type": "chat_message",
  "fromUserId": "123",
  "toUserId": "456",
  "data": {
    "content": "你好"
  },
  "timestamp": 1711234567890
}
```

### 健康提醒
```json
{
  "type": "health_reminder",
  "data": {
    "reminderType": "exercise",
    "message": "该进行适量运动了",
    "level": "warning"
  },
  "timestamp": 1711234567890
}
```

### 用药提醒
```json
{
  "type": "medication_reminder",
  "data": {
    "medicineName": "阿司匹林",
    "dosage": "100mg",
    "time": "08:00",
    "level": "important"
  },
  "timestamp": 1711234567890
}
```

## 测试步骤

### 1. 测试后端连接

打开 `websocket_test.html` 文件，输入：
- WebSocket URL: `ws://127.0.0.1:15555/ws`
- Token: 登录后获取的 token

点击"连接"按钮测试连接。

### 2. 测试前端连接

1. 登录应用
2. 检查控制台日志，应该看到：
   - `正在连接 WebSocket: ws://127.0.0.1:15555/ws`
   - `WebSocket 连接成功`
3. 如果连接失败，会自动重连（最多5次）
4. 如果需要刷新，调用 `WebSocketService().refreshConnection()`

## 特性说明

### 自动重连
- 连接失败后自动重连
- 最多重连 5 次
- 重连间隔 3 秒
- 达到重连上限后停止

### 心跳保持
- 每 30 秒发送一次心跳
- 收到 `pong` 响应表示连接正常

### 消息处理
- 支持多种消息类型
- 自动解析 JSON 格式消息
- 提供回调机制处理消息

### 连接状态
- 提供 4 种连接状态：
  - `disconnected`: 已断开
  - `connecting`: 正在连接
  - `connected`: 已连接
  - `reconnecting`: 正在重连
- 可以通过回调监听状态变化

## 注意事项

1. **Token 验证**: WebSocket 连接需要有效的 JWT token
2. **网络环境**: 确保前端可以访问后端服务
3. **防火墙**: 检查防火墙是否阻止 WebSocket 连接
4. **后端服务**: 确保后端服务正在运行
5. **连接数**: 每个用户只能有一个 WebSocket 连接