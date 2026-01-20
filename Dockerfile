# --- 第一阶段：编译 ---
FROM golang:1.21-alpine AS builder

# 安装编译 caddy 所需的依赖
RUN apk add --no-cache git gcc musl-dev

# 设置工作目录
WORKDIR /app

# 先拷贝依赖文件（利用 Docker 缓存）
COPY go.mod go.sum ./
RUN go mod download

# 拷贝所有源码
COPY . .

# 执行纯源码编译
# Caddy 的入口点通常在 cmd/caddy/main.go
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o caddy ./cmd/caddy/main.go

# --- 第二阶段：运行 ---
FROM alpine:latest

# 安装基础运行环境
RUN apk add --no-cache ca-certificates tzdata

# 从编译阶段拷贝二进制文件
COPY --from=builder /app/caddy /usr/bin/caddy

# 验证安装
RUN caddy version

# 运行指令
CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
