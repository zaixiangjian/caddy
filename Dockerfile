# --- 第一阶段：使用官方 builder 环境进行插件注入编译 ---
FROM caddy:2.8-builder AS builder

# 解决你源码中可能存在的 Go 1.25+ 版本要求问题
ENV GOTOOLCHAIN=auto

# 关键：xcaddy 构建指令
# 1. --with 后跟的是你的 Cloudflare 插件模块名
# 2. 第二个 --with 告诉编译器使用当前目录（/app）下的源码来编译 Caddy 核心
# 这样就能把你对 Caddy 源码的修改和 Cloudflare 插件合二为一
WORKDIR /app
COPY . .

RUN xcaddy build \
    --with github.com/caddy-dns/cloudflare \
    --with github.com/caddyserver/caddy/v2=.

# --- 第二阶段：生成极简运行镜像 ---
FROM caddy:2.8-alpine

# 从编译阶段拷贝成品二进制文件
COPY --from=builder /app/caddy /usr/bin/caddy

# 验证编译结果：显示版本并检查是否包含 cloudflare 模块
RUN caddy version && caddy list-modules | grep cloudflare
