# n8nc 合并上游指南 (Merge Guide)

本文档说明如何从上游仓库 (`deluxebear/n8n:chs`) 合并代码到本地 (`yorkane/n8nc:chs`)，以及如何 **避免反复出现合并冲突**。

---

## 一、合并步骤

```bash
# 1. 添加上游远程仓库（只需执行一次）
git remote add upstream https://github.com/deluxebear/n8n.git

# 2. 拉取上游最新代码
git fetch upstream chs

# 3. 合并上游分支
git merge upstream/chs

# 4. 如果有冲突，解决后提交
git add .
git commit

# 5. 推送到自己的远程仓库
git push origin chs
```

---

## 二、避免合并冲突的核心原则

> **不要修改上游管理的文件。** 所有本地定制都通过 **环境变量** 或 **不被 Git 追踪的文件** 来实现。

### 2.1 `.gitignore` — 使用 `.git/info/exclude`

| ❌ 错误做法 | ✅ 正确做法 |
|---|---|
| 直接编辑 `.gitignore` 添加本地忽略项 | 将本地忽略项写入 `.git/info/exclude` |

`.git/info/exclude` 的语法与 `.gitignore` 完全一致，但它 **不会被 Git 追踪**，因此永远不会产生合并冲突。

```bash
# 示例：忽略本地的自定义文件
echo "my-local-tool/" >> .git/info/exclude
echo ".env.local" >> .git/info/exclude
```

### 2.2 `license-mock-enterprise.ts` — 使用环境变量

| ❌ 错误做法 | ✅ 正确做法 |
|---|---|
| 修改 `console.log` → `console.debug` 等代码 | 通过环境变量 `N8N_ENTERPRISE_MOCK=true` 控制行为 |

该文件已有 `isDevelopmentEnvironment()` 方法，支持通过环境变量开关。在 `.env` 或启动脚本中设置：

```bash
export N8N_ENTERPRISE_MOCK=true
```

### 2.3 TypeScript 类型兼容性问题

上游依赖升级可能引入 **类型定义变更**，导致构建失败。常见情况及修复模板：

#### luxon `DateTime.toISO()` 返回 `string | null`

```typescript
// ❌ 编译失败
currentDate = dateTime.toISO();

// ✅ 添加类型断言
currentDate = dateTime.toISO() as string;
```

#### pg `Pool` 类型不兼容 (`@langchain/community`)

```typescript
// ❌ 编译失败
const config = { pool, tableName };

// ✅ 添加类型断言
const config = { pool: pool as any, tableName };
```

**通用修复策略**：当第三方库的类型定义发生变化时，使用 `as string`、`as any` 等类型断言来桥接不兼容的类型。这些修改是本地适配，不会与上游冲突。

---

## 三、合并后构建验证

```bash
# 完整构建（推荐合并后执行）
pnpm build

# 只验证 TypeScript 编译（更快）
cd packages/nodes-base && npx tsc --build tsconfig.build.cjs.json
cd packages/@n8n/nodes-langchain && npx tsc --build tsconfig.build.json
```

---

## 四、已知冲突文件清单

| 文件 | 冲突原因 | 解决方案 |
|---|---|---|
| `.gitignore` | 本地添加了忽略项 | 改用 `.git/info/exclude` |
| `packages/cli/src/license-mock-enterprise.ts` | 本地修改了日志级别 | 改用环境变量 `N8N_ENTERPRISE_MOCK` |
| `packages/nodes-base/nodes/*/GenericFunctions.ts` 等 | luxon 类型变更 | `toISO() as string` |
| `packages/@n8n/nodes-langchain/nodes/*/` | pg Pool 类型变更 | `pool as any` |

---

## 五、总结

1. **永远不要直接修改上游追踪的文件** — 用环境变量和 exclude 文件替代
2. **合并冲突时优先使用 `--theirs`** — 保持与上游一致
3. **TypeScript 类型报错用断言修复** — 这些修改不会与上游产生冲突
4. **合并后务必运行 `pnpm build`** — 及时发现并修复新的类型问题
