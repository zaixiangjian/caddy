# --- 使用官方 builder 镜像，它内部已经配置好了 Go 环境 ---
FROM caddy:2.8-builder AS builder

# 1. 设置代理（非常重要，保证拉取插件不超时）
ENV GOPROXY=https://goproxy.cn,direct
ENV GOTOOLCHAIN=auto

# 2. 拷贝你的 Caddy 核心源码（如果你想用自己的核心）
WORKDIR /app
COPY . .

# 3. 模仿一键脚本的编译逻辑
# 指向你的 caddy 源码 (.) 并注入官方 cloudflare 插件
RUN xcaddy build \
    --with github.com/caddyserver/caddy/v2=. \
    --with github.com/caddy-dns/cloudflare

# --- 运行阶段 ---
FROM caddy:2.8-alpine

COPY --from=builder /app/caddy /usr/bin/caddy

# 验证模块
RUN caddy list-modules | grep -q "dns.providers.cloudflare" && echo "✅ 模块集成成功"
