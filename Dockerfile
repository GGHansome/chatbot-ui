# 使用官方 Node.js 作为基础镜像
FROM node:20.13.1-slim AS deps

# 设置工作目录
WORKDIR /app

RUN npm config set registry https://registry.npmmirror.com

# 复制 package.json 和 package-lock.json
COPY package*.json ./

# 安装依赖
RUN (echo "start install deps" && npm install)

FROM node:20.13.1-slim AS builder

WORKDIR /app

# 复制依赖
COPY --from=deps /app/node_modules ./node_modules


# 复制源代码
COPY . .

# 构建项目
RUN (echo "start build" && npm run build)

# 安装 Nginx
FROM node:20.13.1-slim as runner

WORKDIR /app

# 设置生产环境
ENV NODE_ENV production

# 复制构建的文件到 Nginx 的 html 目录
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public

ENV PORT=3001
# 暴露端口
EXPOSE 3001

# 启动 Nginx
CMD ["node", "server.js"]