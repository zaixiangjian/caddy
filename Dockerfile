# 第一阶段：编译阶段
FROM caddy:2.7-builder AS builder

# 如果需要添加其他插件，可以在后面继续添加 --with 
RUN xcaddy build \
    --with github.com/caddy-dns/cloudflare

# 第二阶段：运行阶段
FROM caddy:2.7-alpine

# 从编译阶段拷贝编译好的二进制文件
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
