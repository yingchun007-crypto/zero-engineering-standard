---
name: zero-engineering-standard
description: 零维团队工程开发规范入口。用于零维团队项目中的代码实现、架构/方案设计、Spring Boot、FastAPI、Soybean Admin、API 设计、安全、测试、数据库变更、依赖变更、Git 分支/提交/PR/MR、代码审查、Bug 修复、重构和工程规范检查；根据当前技术栈和变更类型按需读取 references/ 下的相关规范。
---

# 零维团队工程开发规范

本 Skill 只做入口路由和硬约束。具体规范全部在 `references/` 中按需读取；不要为无关任务加载无关规范。

普通问答、纯概念解释、一次性命令、与零维项目无关的任务，不需要使用本 Skill。

## 执行流程

开发或审查前：

1. 读取任务相关上下文：`AGENTS.md`、README、需求 / 架构 / 设计文档、相关代码。简单局部修改只读直接相关上下文。
2. 明确现状：业务目标、现有实现、目录结构、类似实现、历史约定，以及是否涉及接口、数据库、依赖、安全或测试。
3. 按下方路由只读取命中的 `references/` 规范。
4. 复杂变更、跨模块变更、接口 / 数据库 / 依赖 / 架构变更前，先说明修改范围、实现方案、命中规范、兼容性、迁移、测试和风险。

## 规范路由

| 任务内容 | 必读规范 |
| --- | --- |
| Spring Boot、Java、Controller、Service、Mapper、Entity、DTO、VO、MyBatis-Plus、事务、日志、测试 | `references/springboot-development-standard.md` |
| FastAPI、Python、Router、Schema、Repository、Pydantic、SQLAlchemy、异步接口、事务、日志、测试 | `references/fastapi-development-standard.md` |
| Vue 3、TypeScript、Soybean Admin、页面、组件、Router、Pinia、Request、UnoCSS、I18n、权限、表单、表格 | `references/soybean-development-standard.md` |
| 表结构、字段、主键、索引、唯一约束、逻辑删除、审计字段、SQL、迁移、初始化、查询性能 | `references/database-design-standard.md` |
| 新增 / 修改接口、请求 / 响应、错误码、分页、排序、过滤、幂等、批量、文件接口、接口兼容性 | `references/api-design-standard.md` |
| 登录、认证、鉴权、数据归属、敏感信息、文件、外部 URL、Webhook、注入、CORS、CSRF、XSS、安全审查 | `references/security-development-standard.md` |
| 单元测试、集成测试、API 测试、前端测试、Bug 回归测试、测试数据、Mock、CI 测试、测试缺口评估 | `references/testing-standard.md` |
| Code Review、PR / MR 审查、安全、接口兼容、数据库、测试缺口、性能、事务、异常处理审查 | `references/code-review-standard.md` |
| Maven、Gradle、pnpm、Python 依赖、新增 / 升级 / 替换依赖、第三方 SDK、开源组件 | `references/dependency-management-standard.md` |
| 分支命名、Commit Message、Pull Request、Merge Request、变更说明、发版说明 | `references/git-workflow-standard.md` |

组合规则：

- API 实现：读 API 设计规范和对应后端规范。
- 安全实现 / 审查：读安全规范和对应技术栈规范。
- 数据库变更涉及后端代码：读数据库规范和对应后端规范。
- 测试实现：读测试规范和对应技术栈规范。
- Review：按 diff 内容读取 Code Review、安全、API、数据库、依赖、测试和技术栈规范。
- 新增依赖：说明必要性、替代方案、License、维护状态、安全风险、传递依赖和复杂度影响；大型、安全敏感或架构性依赖需显式确认。
- Commit Message：遵守 Conventional Commits。
- 初始化 Spring Boot / FastAPI 项目，或补齐统一响应、分页、异常、断言、基础实体等公共基础设施时，必须读取 `references/examples/` 下对应示例。

## 通用约束

- 已有项目以当前技术栈、架构、目录、依赖管理和 CI 配置为准；新建且无约束时再参考团队推荐技术栈。
- 优先复用现有实现，保持命名、目录、响应、异常、日志和权限模型一致。
- 不做无关重构、无关格式化、无关目录调整，不删除已有业务逻辑来绕过问题。
- 不擅自更换技术栈、整体架构、模块边界、接口语义、数据库核心结构或新增依赖。
- 不暴露密码、Token、密钥、SQL、堆栈和内部异常细节。
- 涉及安全、敏感数据、数据库破坏性变更、接口兼容性或生产风险时，必须说明影响并请求确认。

## 冲突优先级

1. 系统、平台和安全指令
2. 用户明确要求
3. `AGENTS.md`
4. 项目现有代码、目录结构和 CI 配置
5. 项目设计文档 / 本地规范
6. `references/` 详细规范
7. 本 Skill 入口规则
8. 通用最佳实践

发现冲突时，说明冲突点、影响和可选方案，不得静默覆盖现有实现。

## 交付要求

完成后按实际变更说明：

- 修改了哪些文件，实现了什么。
- 是否修改接口、数据库、依赖、路由 / 权限、配置或代码生成产物。
- 是否需要迁移、SQL 评审、代码生成或发布注意事项。
- 已执行或建议执行的测试 / 检查命令；未执行时说明原因。
- 剩余风险、安全点、兼容性点和测试缺口。

常用检查提示：前端页面 `pnpm gen-route`、`pnpm typecheck`、`pnpm lint`；FastAPI `ruff check .`、`ruff format .`、`pytest`；Spring Boot 执行项目对应测试命令。
