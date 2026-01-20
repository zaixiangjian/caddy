# --- 第一阶段：编译 ---
# 使用最新的 alpine 版本的 golang 镜像
FROM golang:1.24-alpine AS builder

# 强制 Go 即使在版本不匹配时也尝试下载需要的工具链
ENV GOTOOLCHAIN=auto

# 安装编译 caddy 所需的依赖
RUN apk add --no-cache git gcc musl-dev

# 设置工作目录
WORKDIR /app

# 拷贝依赖文件
COPY go.mod go.sum ./
RUN go mod download

# 拷贝所有源码
COPY . .

# 执行纯源码编译
# LD_FLAGS 用于减小二进制体积
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o caddy ./cmd/caddy/main.go

# --- 第二阶段：运行 ---
FROM alpine:latest

RUN apk add --no-cache ca-certificates tzdata

# 从编译阶段拷贝二进制文件
COPY --from=builder /app/caddy /usr/bin/caddy

# 验证安装
RUN caddy version

# 运行指令
CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
