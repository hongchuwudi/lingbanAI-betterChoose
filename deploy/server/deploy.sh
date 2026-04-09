#!/bin/bash

# ============================================================
# 灵伴AI 后端自动化部署脚本
# 工作目录: /home/hongchu/lingban
# ============================================================

set -e

# 切换到工作目录
cd /home/hongchu/lingban

# 配置变量
IMAGE_NAME="lingban/backend"
CONTAINER_NAME="lingban-backend"
PORT="15555"
JAR_FILE="./server/cb-service.jar"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查 jar 包是否存在
check_jar() {
    if [ ! -f "$JAR_FILE" ]; then
        log_error "未找到 jar 包，请先将 jar 包上传到 $JAR_FILE"
        exit 1
    fi
    log_info "找到 jar 包: $JAR_FILE"
}

# 停止并删除旧容器
stop_and_remove_container() {
    if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        log_info "停止并删除旧容器: $CONTAINER_NAME"
        docker stop $CONTAINER_NAME 2>/dev/null || true
        docker rm $CONTAINER_NAME 2>/dev/null || true
    else
        log_info "容器 $CONTAINER_NAME 不存在，跳过"
    fi
}

# 删除旧镜像
remove_old_image() {
    if docker images --format '{{.Repository}}' | grep -q "^${IMAGE_NAME}$"; then
        log_info "删除旧镜像: $IMAGE_NAME"
        docker rmi $IMAGE_NAME 2>/dev/null || true
    else
        log_info "镜像 $IMAGE_NAME 不存在，跳过"
    fi
}

# 构建新镜像
build_image() {
    log_info "构建新镜像: $IMAGE_NAME"
    docker build -t $IMAGE_NAME .
    log_info "镜像构建成功"
}

# 启动新容器
run_container() {
    log_info "启动新容器: $CONTAINER_NAME"
    docker run -d \
        --name $CONTAINER_NAME \
        --restart=always \
        -p $PORT:15555 \
        -e TZ=Asia/Shanghai \
        $IMAGE_NAME
    
    log_info "容器启动成功"
}

# 等待服务启动
wait_for_service() {
    log_info "等待服务启动（最多 60 秒）..."
    for i in {1..60}; do
        if docker logs $CONTAINER_NAME 2>&1 | grep -q "Started" 2>/dev/null; then
            log_info "服务已启动"
            return 0
        fi
        sleep 1
    done
    log_warn "服务启动超时，请手动检查日志"
}

# 显示日志
show_logs() {
    log_info "最近日志:"
    docker logs --tail 20 $CONTAINER_NAME
}

# 删除 jar 包
clean_jar() {
    if [ -f "$JAR_FILE" ]; then
        rm -f $JAR_FILE
        log_info "已删除 jar 包: $JAR_FILE"
    fi
}

# 主函数
main() {
    log_info "========== 开始部署灵伴AI后端 =========="
    log_info "工作目录: /home/hongchu/lingban"
    
    check_jar
    stop_and_remove_container
    remove_old_image
    build_image
    run_container
    wait_for_service
    show_logs
    clean_jar
    
    log_info "========== 部署完成 =========="
    log_info "服务地址: http://$(hostname -I | awk '{print $1}'):$PORT"
    log_info "查看日志: docker logs -f $CONTAINER_NAME"
}

# 执行主函数
main