# FastAPI Development Standard

## 目录

- [定位](#定位)
- [必须同时参考](#必须同时参考)
- [项目优先级](#项目优先级)
- [分层与目录](#分层与目录)
- [Router](#router)
- [Schema / Model / Converter](#schema--model--converter)
- [Service / Repository / 事务](#service--repository--事务)
- [响应与异常](#响应与异常)
- [异步与外部调用](#异步与外部调用)
- [注释规范](#注释规范)
- [配置、日志和风格](#配置日志和风格)
- [交付清单](#交付清单)
- [可选示例](#可选示例)

本文件只维护 FastAPI 实现层面的核心规则。API 设计、安全、测试、数据库、依赖和 Git 规则不在本文重复展开。

## 必须同时参考

- API 新增 / 修改：`references/api-design-standard.md`
- 安全、鉴权、敏感数据、文件、外部 URL：`references/security-development-standard.md`
- 数据库表结构、索引、迁移：`references/database-design-standard.md`
- 新增 / 升级依赖：`references/dependency-management-standard.md`
- 测试：`references/testing-standard.md`
- 注释、docstring、字段说明：`references/comment-standard.md`
- Review：`references/code-review-standard.md`

## 项目优先级

- 以项目现有 Python 版本、包管理、目录结构、响应、异常、ORM、迁移工具和测试命令为准。
- 不为了套用本文示例而更换包管理器、ORM、路由结构或基础设施。
- 新建且无约束项目可参考：Python 3.11+、FastAPI、Pydantic v2、SQLAlchemy 2.x、Alembic、httpx、pytest、Ruff。

## 分层与目录

推荐职责：

- `api` / `endpoints`：路由、入参、依赖注入、文档和响应封装；不写复杂业务。
- `service`：业务流程、事务编排、领域校验、幂等和权限后置校验。
- `repository`：数据库访问，不写业务规则。
- `schema`：Pydantic 请求和响应模型。
- `model`：ORM 模型，字段与表结构一致。
- `converter`：Model、Schema、DTO、Response 转换。
- `core` / `common`：配置、日志、安全、异常、响应、分页、枚举等公共能力。

目录必须跟随项目现有结构。新增模块优先参考同类模块。

## Router

- Router 只负责 HTTP 路由、参数校验、Depends、OpenAPI 文档、调用 Service 和返回统一响应。
- 不在 Router 中写复杂业务、事务编排、SQL、对象转换和通用 try-except。
- 业务 JSON 接口使用统一响应；健康检查、文件、流式、Webhook、metrics 等特殊接口可按协议返回。
- 不返回裸 dict、ORM Model、内部异常、SQL、堆栈、密钥或 Token。
- `response_model`、`summary`、关键参数说明必须清晰。

## Schema / Model / Converter

- 请求 Schema 与响应 Schema 分离，不直接把 ORM Model 作为接口响应。
- Schema 字段必须有明确类型；关键字段写 description、长度、范围、枚举和示例。
- 可选字段使用 `T | None` 并明确默认值。
- 金额使用 `Decimal`，时间使用 `datetime` / `date` / `time`，ID 类型与数据库一致。
- 响应 Schema 过滤密码、盐值、密钥、内部权限表达式和敏感字段。
- 转换逻辑集中到 Converter 或项目既有模式，不散落在 Router。

## Service / Repository / 事务

- 业务规则、权限后置校验、状态机、幂等和事务编排放在 Service。
- Repository 只负责数据库访问；复杂查询必须可读、可测、参数化。
- 写操作涉及多步骤、跨表、状态流转或外部副作用时必须明确事务边界和 rollback。
- 不吞异常后返回成功；需要补偿时必须说明补偿策略。
- 不在长事务中调用慢外部接口、上传文件或执行大量循环。
- 查询默认考虑逻辑删除、租户 / 数据归属、权限范围和索引可用性。

## 响应与异常

- 成功和失败响应结构遵守项目统一规范；错误码遵守 API 设计规范。
- 可预期业务失败抛出项目统一业务异常，并使用稳定错误码。
- 参数校验异常、业务异常和未知异常由全局异常处理器收口。
- 推荐 HTTP 状态码与错误语义一致；如团队统一 HTTP 200 承载业务错误码，必须保证调用方和监控都按该约定处理。
- 未知异常服务端记录必要日志，对外返回受控错误，不暴露内部细节。

## 异步与外部调用

- async 接口中避免直接调用阻塞 IO；数据库、HTTP、Redis 等 IO 优先使用异步客户端。
- CPU 密集型任务不得阻塞事件循环，应放入线程池、进程池或任务队列。
- 后台任务不得依赖请求生命周期内的 Session。
- 第三方调用必须设置连接 / 读取超时，处理超时、非 2xx、业务失败码和空响应。
- 非幂等第三方操作谨慎重试，必须有次数上限和退避策略。

## 注释规范

- 必须同时遵守 `references/comment-standard.md`。
- 公共模块、Service 类、Repository 复杂查询类和跨模块工具函数必须写 docstring，说明职责和适用边界。
- Service 公共方法必须写 docstring，包含方法用途、Args 参数语义、Returns 返回值语义、Raises 主要业务异常 / 错误码。
- Router 对外接口以 FastAPI `summary`、`description`、`response_model`、`Path`、`Query`、`Body` 文档为主；复杂限制可补充函数 docstring。
- Pydantic Schema 字段必须通过 `Field(description=..., examples=...)` 或项目约定说明关键字段含义。
- Repository 复杂查询方法必须说明过滤条件、排序、权限范围、逻辑删除和返回空值语义。
- 复杂异步流程、事务、补偿、权限和数据归属判断必须用短注释说明原因。
- 简单私有函数和显而易见的局部变量不机械补注释。

## 配置、日志和风格

- 配置集中管理；环境差异通过环境变量、`.env`、配置中心或项目既有方案注入。
- 生产敏感配置不得提交仓库。
- 使用 logging / structlog / 项目统一日志方案，禁止 `print()` 进入生产代码。
- 日志包含必要上下文，禁止打印密码、Token、密钥、完整手机号、身份证、完整请求 / 响应大对象。
- 遵循 Ruff、mypy、EditorConfig 或项目现有风格；不提交无关格式化。
- 公共函数和复杂业务方法必须有类型注解和必要 docstring。

## 交付清单

- 是否读取同类模块并延续项目结构。
- 是否符合 API、安全、数据库、依赖和测试规范。
- Router 是否轻薄，Service 是否承载业务和事务。
- Schema / Model / Converter 是否分离，是否过滤敏感字段。
- 是否使用统一响应、错误码、异常处理和分页结构。
- 公共类、Service 方法、复杂 Repository 和关键 Schema 字段是否补充必要注释。
- 是否存在阻塞 IO、SQL 注入、越权、日志泄露、事务过大或数据不一致风险。
- 是否补充测试，或说明未补测试原因。
- 是否执行项目对应 `ruff check`、`ruff format`、`pytest` 或既有检查命令。

## 可选示例

需要完整 Router、Schema、分页、异常、SQLAlchemy、事务或配置样例时，再读取：

- `references/examples/fastapi-examples.md`
