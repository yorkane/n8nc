# n8n Docker Compose 部署说明

本文档基于当前目录下的 `docker-compose.yml` 与 `Caddyfile`，用于快速部署一个包含以下组件的 n8n 环境：

- `n8n` 主服务（Web UI + API）
- `task-runners` 外部任务执行器
- `caddy` 反向代理（自动 HTTPS）

## 1. 前置条件

- 已安装 Docker 与 Docker Compose（`docker compose` 命令可用）
- 服务器已开放 `80` 与 `443` 端口
- 域名已在 DNS 服务商处绑定服务器公网 IP（A 记录/AAAA 记录）
- 域名已解析到部署服务器（示例：`n8n.example.com`）
- 建议先用 `dig` 或 `nslookup` 验证解析结果后再启动容器

## 2. 部署前配置（必须）

请先修改以下配置项，再启动服务。

### 2.1 修改 `Caddyfile`

文件：`Caddyfile`

将域名从示例值改为真实域名：

```caddy
n8n.example.com {
    reverse_proxy n8n-main:5678
}
```

### 2.2 修改 `docker-compose.yml`

文件：`docker-compose.yml`

重点检查并替换：

- `N8N_HOST=n8n.example.com`
  改成你的真实域名（与 `Caddyfile` 一致）
- `WEBHOOK_URL=https://n8n.example.com/`
  改成真实 Webhook 地址（建议与域名一致）
- `N8N_RUNNERS_AUTH_TOKEN=...`（`n8n` 与 `task-runners` 两处）
  两处必须完全一致，建议重新生成：

```bash
openssl rand -hex 32
```

### 2.3 环境定位说明（建议确认）

当前配置中包含：

- `NODE_ENV=development`
- `N8N_ENTERPRISE_MOCK=true`

如果用于生产环境，建议改为：

- `NODE_ENV=production`
- 关闭 mock 配置（按你的许可证/环境策略处理）

## 3. 启动服务

在当前目录执行：

```bash
docker compose up -d
```

查看状态：

```bash
docker compose ps
```

查看日志（按需）：

```bash
docker compose logs -f n8n
docker compose logs -f caddy
docker compose logs -f task-runners
```

## 4. 验证部署

- 浏览器访问：`https://你的域名`
- n8n 页面可正常打开并登录
- 创建一个简单工作流并手动执行
- 测试含代码/任务执行节点，确认 `task-runners` 正常工作

## 5. 常见运维命令

停止服务：

```bash
docker compose down
```

重启服务：

```bash
docker compose restart
```

更新镜像并重建：

```bash
docker compose pull
docker compose up -d
```

## 6. 数据与持久化

当前 compose 使用了以下命名卷：

- `n8n_data`：n8n 数据目录（`/home/node/.n8n`）
- `caddy_data`：Caddy 证书与状态数据
- `caddy_config`：Caddy 配置数据

删除容器不会清除命名卷；如需彻底清理，请谨慎执行：

```bash
docker compose down -v
```

## 7. 安全建议

- 不要在仓库中明文保存真实 `N8N_RUNNERS_AUTH_TOKEN`
- 建议通过 `.env` 文件或密钥管理系统注入敏感变量
- 首次上线后，检查是否能直接从公网访问不必要端口（仅保留 `80/443` 对外）

