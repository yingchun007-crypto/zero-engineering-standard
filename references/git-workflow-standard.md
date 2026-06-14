# Git Workflow Standard


## 目录

- [分支与 PR 规范](#分支与-pr-规范)
- [Git 提交规范](#git-提交规范)
  - [基本格式](#基本格式)
  - [常用 type](#常用-type)
  - [scope 规范](#scope-规范)
  - [破坏性变更](#破坏性变更)
  - [正文和脚注](#正文和脚注)
  - [禁止的提交信息](#禁止的提交信息)
  - [提交前检查](#提交前检查)

本文件是 Git 分支、PR / MR 和提交信息规范的唯一维护位置。提交信息必须遵循 Conventional Commits 1.0.0。

## 分支与 PR 规范

项目应使用清晰的分支模型管理开发、测试和发布。

推荐分支：

- `main`：生产稳定分支，只保存可发布代码。
- `develop`：日常集成分支，用于功能合并和测试环境发布。
- `feature/<name>`：功能开发分支，例如 `feature/user-profile`。
- `fix/<name>`：普通缺陷修复分支，例如 `fix/user-query-condition`。
- `hotfix/<name>`：生产紧急修复分支，例如 `hotfix/login-error`。
- `release/<version>`：发布准备分支，例如 `release/1.2.0`。

分支要求：

- 禁止直接向 `main` 推送代码。
- 功能开发必须从最新 `develop` 拉取分支。
- 生产紧急修复从 `main` 拉取 `hotfix` 分支，修复后同时合并回 `main` 和 `develop`。
- 分支命名必须小写，单词使用中划线。
- 分支应聚焦单一任务，避免长期堆积无关变更。
- 合并前必须同步目标分支最新代码并解决冲突。

PR / MR 要求：

- 合并代码必须通过 PR / MR。
- PR 标题建议遵守 Conventional Commits，例如 `feat(user): add user profile api`。
- PR 描述必须说明变更内容、影响范围、测试结果和风险点。
- 涉及接口变更必须说明兼容性。
- 涉及数据库变更必须说明迁移脚本、回滚方案和影响表。
- 涉及新增依赖必须说明依赖用途、License 和版本管理位置。
- 至少经过一名代码 Review 后再合并。
- CI、测试或静态检查未通过时禁止合并。

PR 描述模板：

```text
变更内容：
- 

影响范围：
- 

测试结果：
- 

风险与回滚：
- 
```

## Git 提交规范

Git commit message 必须严格遵循 Conventional Commits 1.0.0 规范。

官方规范地址：

```text
https://www.conventionalcommits.org/zh-hans/v1.0.0/
```

### 基本格式

提交信息格式：

```text
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

要求：

- `type` 必填。
- `description` 必填。
- `scope` 可选，用小括号包裹。
- `type` 和 `description` 之间必须使用英文冒号加空格 `: `。
- `description` 使用简短明确的提交说明。
- 正文 `body` 可选，用于说明本次修改的动机、背景和细节。
- 脚注 `footer` 可选，用于填写破坏性变更、issue 关联等元信息。

### 常用 type

必须优先使用以下类型：

- `feat`：新增功能，对应语义化版本的 MINOR。
- `fix`：修复缺陷，对应语义化版本的 PATCH。
- `docs`：仅文档变更。
- `style`：代码格式、空格、缩进等不影响逻辑的变更。
- `refactor`：重构代码，不新增功能也不修复缺陷。
- `perf`：性能优化。
- `test`：新增或修改测试。
- `build`：构建系统或外部依赖变更。
- `ci`：CI/CD 配置变更。
- `chore`：其他不修改业务代码的杂项变更。
- `revert`：回滚提交。

示例：

```text
feat(user): add user creation api
fix(order): correct order status validation
docs: update springboot development standard
refactor(auth): simplify token parsing
test(user): add user service tests
```

### scope 规范

`scope` 用于说明本次提交影响的模块或范围。

推荐使用：

- 业务模块名：`user`、`order`、`product`、`auth`。
- 技术模块名：`api`、`db`、`config`、`security`、`swagger`。
- 跨模块修改可省略 scope，或使用更准确的公共范围，如 `common`。

示例：

```text
feat(user): support user status update
fix(common): handle validation error message
chore(config): update springdoc config
```

### 破坏性变更

如果提交包含破坏性变更，必须明确标记。

方式一：在 `type` 或 `scope` 后添加 `!`：

```text
feat(api)!: change user response structure
```

方式二：在脚注中添加 `BREAKING CHANGE:`：

```text
feat(api): change user response structure

BREAKING CHANGE: user detail api now returns profile field instead of userInfo.
```

要求：

- `BREAKING CHANGE` 必须使用大写。
- 破坏性变更必须说明影响范围和迁移方式。
- 包含破坏性变更时，对应语义化版本的 MAJOR。

### 正文和脚注

正文用于解释为什么修改，而不只是重复修改了什么。

推荐正文示例：

```text
fix(user): reject duplicate mobile numbers

The previous implementation only checked username uniqueness.
This change adds mobile uniqueness validation before creating users.
```

脚注可用于关联 issue：

```text
fix(user): reject duplicate mobile numbers

Refs: #123
```

多个脚注示例：

```text
feat(order): add order cancellation api

Refs: #123
Reviewed-by: zhangsan
```

### 禁止的提交信息

禁止使用含糊、不符合格式的提交信息：

```text
update code
fix bug
提交代码
修改了一下
user api
wip
```

应改为：

```text
fix(user): correct user query condition
feat(user): add user detail api
docs: update api response standard
```

### 提交前检查

每次提交前必须确认：

- commit message 是否符合 `<type>[optional scope]: <description>`。
- 是否使用了准确的 `type`。
- 是否需要填写 `scope`。
- 是否存在破坏性变更，若存在是否使用 `!` 或 `BREAKING CHANGE:`。
- 是否关联了必要的 issue、需求单或任务编号。
- 本次提交是否聚焦单一目的，避免把无关修改混在一起。


