# 基础镜像
FROM openjdk:17-slim

# 设置工作目录
WORKDIR /app

# 设置时区
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 复制 jar 包
COPY server/cb-service.jar app.jar

# 暴露端口
EXPOSE 15555

# 启动命令
ENTRYPOINT ["java", "-jar", "app.jar"]