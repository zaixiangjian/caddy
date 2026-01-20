# --- 第一阶段：编译 ---
FROM caddy:2.8-builder AS builder

# 启用 Go 工具链自动下载，解决版本依赖
ENV GOTOOLCHAIN=auto

# 创建插件目录
WORKDIR /plugins
# 克隆你的 Cloudflare 插件源码到 builder 内部
RUN git clone https://github.com/zaixiangjian/cloudflare.git cloudflare-src

# 进入主程序目录
WORKDIR /app
# 拷贝当前仓库（caddy 核心源码）
COPY . .

# 执行 xcaddy 编译
# 1. --with ...=. 指向当前目录，使用你仓库里的 Caddy 源码
# 2. --with ...=/plugins/cloudflare-src 指向你刚才克隆的插件源码
RUN xcaddy build \
    --with github.com/caddyserver/caddy/v2=. \
    --with github.com/caddy-dns/cloudflare=/plugins/cloudflare-src

# --- 第二阶段：运行 ---
FROM caddy:2.8-alpine

# 拷贝编译好的二进制文件
COPY --from=builder /app/caddy /usr/bin/caddy

# 【关键验证】构建时检查模块是否存在，不存在则构建失败
RUN caddy list-modules | grep -q "dns.providers.cloudflare" && echo "✅ 插件集成成功" || (echo "❌ 插件集成失败" && exit 1)

RUN caddy version
