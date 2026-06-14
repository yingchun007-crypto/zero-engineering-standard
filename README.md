# zero-engineering-standard

零维团队 Codex 工程开发规范 Skill。

这个仓库用于给 Codex 提供一套可复用的团队工程规范入口，覆盖代码实现、架构/方案设计、Spring Boot、FastAPI、Soybean Admin、API 设计、安全、测试、数据库变更、依赖管理、Git 工作流、代码审查、Bug 修复和重构等场景。

## 适用场景

当你希望 Codex 在零维团队项目中按照统一工程规范工作时，安装本 Skill。

典型场景：

- 新增或修改 Spring Boot / FastAPI 接口
- 开发 Soybean Admin 页面
- 设计 API、数据库表结构或迁移脚本
- 做代码审查、Bug 修复、重构
- 补测试、检查安全风险、评估接口兼容性
- 生成 Commit Message、PR / MR 描述
- 初始化 Spring Boot / FastAPI 项目的统一响应、分页、异常、断言等公共基础设施

## 目录结构

```text
zero-engineering-standard
├── SKILL.md
├── agents
│   └── openai.yaml
└── references
    ├── api-design-standard.md
    ├── code-review-standard.md
    ├── database-design-standard.md
    ├── dependency-management-standard.md
    ├── fastapi-development-standard.md
    ├── git-workflow-standard.md
    ├── security-development-standard.md
    ├── soybean-development-standard.md
    ├── springboot-development-standard.md
    ├── testing-standard.md
    └── examples
        ├── fastapi-examples.md
        └── springboot-examples.md
```

## 设计原则

- `SKILL.md` 只做入口路由和硬约束，保持轻量。
- `references/*-standard.md` 存放按领域拆分的规范。
- `references/examples/` 存放初始化项目或补齐公共基础设施时使用的稳定模板。
- 日常开发只读取命中的规范，避免无关内容占用上下文。
- 初始化项目时再读取 examples，保证 `ApiResult`、`PageResult`、异常、断言、基础实体等公共工具生成一致。

## 安装方式

### Windows

推荐在仓库根目录执行安装脚本：

```powershell
.\install.ps1
```

脚本会把整个 Skill 安装到：

```text
%USERPROFILE%\.codex\skills\zero-engineering-standard
```

如需覆盖旧版本且不保留备份：

```powershell
.\install.ps1 -NoBackup
```

也可以手动将整个仓库复制到 Codex skills 目录：

```powershell
$target = "$env:USERPROFILE\.codex\skills\zero-engineering-standard"
New-Item -ItemType Directory -Force -Path (Split-Path $target) | Out-Null
Copy-Item -Recurse -Force ".\zero-engineering-standard" $target
```

如果你已经在仓库目录内，也可以执行：

```powershell
$target = "$env:USERPROFILE\.codex\skills\zero-engineering-standard"
Remove-Item -Recurse -Force $target -ErrorAction SilentlyContinue
Copy-Item -Recurse -Force . $target
```

### macOS / Linux

推荐在仓库根目录执行安装脚本：

```bash
chmod +x ./install.sh
./install.sh
```

脚本会把整个 Skill 安装到：

```text
~/.codex/skills/zero-engineering-standard
```

如需覆盖旧版本且不保留备份：

```bash
NO_BACKUP=1 ./install.sh
```

也可以手动复制：

```bash
mkdir -p ~/.codex/skills
rm -rf ~/.codex/skills/zero-engineering-standard
cp -R ./zero-engineering-standard ~/.codex/skills/zero-engineering-standard
```

安装完成后，建议新开一个 Codex 线程，或重启/刷新 Codex，确保 Skill 被重新发现。

## 使用方式

在 Codex 中直接提出任务即可，例如：

```text
使用 zero-engineering-standard，帮我新增一个用户分页查询接口。
```

```text
按照零维工程规范 review 这个 PR 的改动。
```

```text
帮我初始化一个 Spring Boot 项目的统一响应、分页和异常处理基础设施。
```

Codex 会根据任务内容按需读取对应规范，例如：

- Spring Boot 任务读取 `references/springboot-development-standard.md`
- API 设计任务读取 `references/api-design-standard.md`
- 安全相关任务读取 `references/security-development-standard.md`
- 代码审查任务读取 `references/code-review-standard.md`
- 初始化 Spring Boot / FastAPI 公共基础设施时读取 `references/examples/`

## 更新方式

拉取最新仓库后，重新复制到本地 Codex skills 目录即可。

Windows 示例：

```powershell
$target = "$env:USERPROFILE\.codex\skills\zero-engineering-standard"
Remove-Item -Recurse -Force $target -ErrorAction SilentlyContinue
Copy-Item -Recurse -Force . $target
```

## 版本发布建议

建议使用 Git tag 和 GitHub Release 管理团队版本：

```bash
git tag v0.1.0
git push origin v0.1.0
```

发布时建议在 Release Notes 中说明：

- 新增了哪些规范
- 修改了哪些规则
- 是否影响已有项目生成风格
- 是否需要团队成员重新安装

## 维护建议

- 修改 `SKILL.md` 时保持入口轻量，不把详细规则塞回入口。
- 新增规范优先放到 `references/`。
- 新增完整代码模板优先放到 `references/examples/`。
- 避免同一规则在多个文件中重复维护。
- 重大规则变更应在 Release Notes 中说明迁移影响。

## 当前覆盖范围

- Spring Boot 开发规范
- FastAPI 开发规范
- Soybean Admin 前端规范
- API 设计规范
- 安全开发规范
- 测试规范
- 代码审查规范
- 数据库设计规范
- 依赖管理规范
- Git 工作流规范
- Spring Boot / FastAPI 初始化示例模板
