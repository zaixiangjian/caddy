# --- 第一阶段：编译 ---
FROM caddy:2.8-builder AS builder

ENV GOTOOLCHAIN=auto

# 1. 下载你的插件源码到 /plugins
WORKDIR /plugins
RUN git clone https://github.com/zaixiangjian/cloudflare.git cloudflare-src

# 2. 进入主程序目录，使用你仓库里的 Caddy 源码
WORKDIR /app
COPY . .

# 3. 执行编译
# 这里我们将 github.com/caddy-dns/cloudflare 映射到你本地克隆的路径
# 将 github.com/caddyserver/caddy/v2 映射到当前目录 (.)
RUN xcaddy build \
    --with github.com/caddyserver/caddy/v2=. \
    --with github.com/caddy-dns/cloudflare=/plugins/cloudflare-src

# --- 第二阶段：运行 ---
FROM caddy:2.8-alpine

COPY --from=builder /app/caddy /usr/bin/caddy

# 验证注入是否成功
RUN caddy list-modules | grep -q "dns.providers.cloudflare" && echo "✅ 你的定制插件集成成功" || (echo "❌ 插件集成失败" && exit 1)

RUN caddy version
