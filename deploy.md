# n8n 部署指南 (Deployment Guide)

本指南介绍如何将开发好的 n8n 环境（包含自定义节点）打包并发布到目标机器上运行。

## 流程概览

1.  **编译 (Build)**: 在开发环境编译代码。
2.  **打包 (Package)**: 生成发布包（轻量版/全量版）。
3.  **发布 (Publish)**: 将压缩包复制到目标环境。
4.  **运行 (Run)**: 解压并启动服务。

---

## 1. 编译 (Build)

在开发机器上，确保所有代码（包括自定义节点）已正确编译。

```powershell
# 在 n8n 根目录执行
pnpm install
pnpm build
```

## 2. 打包 (Package)

运行打包脚本，生成两种版本的发布包：

```powershell
# 在 n8n 根目录执行
powershell -ExecutionPolicy Bypass -File scripts/package_release_tgz.ps1
```

脚本运行后会生成两个文件：

*   **`n8n-release-light-*.tgz` (轻量版)**:
    *   **特点**: 体积小，不含依赖。
    *   **适用**: 跨环境部署，网络较好，目标机器可以运行 `pnpm install`。
    *   **推荐**: 生产环境部署推荐使用此版本。
*   **`n8n-release-full-*.tgz` (全量版)**:
    *   **特点**: 体积大，包含 `node_modules`。
    *   **适用**: 离线环境，且目标机器操作系统/架构与开发机**完全一致**（如都是 Windows x64）。
    *   **⚠️注意**: 如果跨操作系统（如 Windows -> Linux），全量版**不可用**，因为包含的原生模块（如 sqlite3）无法运行。

## 3. 发布与解压 (Publish & Unpack)

将选定的 `.tgz` 文件传输到目标机器。

### 在目标机器上：

1.  **创建目录**:
    ```bash
    mkdir n8n-deploy
    cd n8n-deploy
    ```

2.  **解压文件**:
    ```bash
    tar -xzf n8n-release-*.tgz
    ```

## 4. 运行 (Run)

### 配置环境 (Configuration) -- **新增/IMPORTANT**

在启动前，建议配置环境变量（如数据库、端口、时区等）。

1.  进入解压目录。
2.  将 `.env.example` 复制为 `.env`。
    ```bash
    cp .env.example .env
    # Windows: copy .env.example .env
    ```
3.  编辑 `.env` 文件，根据实际环境修改配置。

### 方案 A: 使用轻量版 (Light Package) - 推荐

需要安装依赖。

1.  **安装依赖**:
    ```bash
    # 使用 --no-frozen-lockfile 以允许 lockfile 更新
    pnpm install --no-frozen-lockfile
    ```

2.  **启动**:

    *   **通用方式**:
        ```bash
        pnpm start
        ```
    *   **快捷脚本**:
        *   Windows: 双击 `start.bat` 或运行 `.\start.bat`
        *   Linux/Mac: 运行 `./start.sh` (需先 `chmod +x start.sh`)

### 方案 B: 使用全量版 (Full Package)

无需安装依赖（仅限相同系统环境）。

1.  **直接启动**:
    同上，使用 `pnpm start` 或启动脚本。

---

## 常见问题

- **Node.js 版本**: 确保目标机器安装了 Node.js >= 20.19 (推荐 22.x)。
- **全量版启动报错**: 如果遇到 `Module not found` 或 `Invalid ELF header` 等错误，说明原生依赖不兼容。请改用**轻量版**并在目标机器重新 `pnpm install`。
