# Spring Boot Development Standard

## 目录

- [定位](#定位)
- [必须同时参考](#必须同时参考)
- [项目优先级](#项目优先级)
- [分层与目录](#分层与目录)
- [Controller](#controller)
- [DTO / VO / Entity](#dto--vo--entity)
- [Service 与事务](#service-与事务)
- [Sa-Token 权限](#sa-token-权限)
- [Mapper / MyBatis-Plus](#mapper--mybatis-plus)
- [异常与响应](#异常与响应)
- [日志与配置](#日志与配置)
- [代码风格](#代码风格)
- [交付清单](#交付清单)
- [可选示例](#可选示例)

本文件只维护 Spring Boot 实现层面的核心规则。API 设计、安全、测试、数据库、依赖和 Git 规则不在本文重复展开。

## 必须同时参考

- API 新增 / 修改：`references/api-design-standard.md`
- 安全、鉴权、敏感数据、文件、外部 URL：`references/security-development-standard.md`
- 数据库表结构、索引、迁移：`references/database-design-standard.md`
- 新增 / 升级依赖：`references/dependency-management-standard.md`
- 测试：`references/testing-standard.md`
- Review：`references/code-review-standard.md`

## 项目优先级

- 以项目现有 Spring Boot 版本、包结构、基础类、统一响应、异常、权限和测试命令为准。
- 不为了套用本文示例而新增框架、移动目录或重写基础设施。
- 新建且无约束项目可参考：Java 17+、Spring Boot 3.x、Maven / Gradle、Spring Validation、MyBatis-Plus、springdoc-openapi、Lombok。
- 项目已使用或允许使用 Lombok 时，优先使用 Lombok 减少样板代码；不要在局部代码中混用大量手写 getter/setter/构造器。
- 涉及登录、认证、鉴权、角色、权限点时，Spring Boot 项目优先使用项目统一的 Sa-Token 方案；新增依赖和版本管理遵守依赖规范。

## 分层与目录

推荐职责：

- `controller`：HTTP 入参、校验、文档注解、响应封装；不写复杂业务。
- `service`：业务流程、事务、领域校验、业务断言。
- `mapper`：数据库访问；复杂 SQL 必须可读、可测、参数化。
- `entity`：数据库结构映射；业务表默认继承项目基础实体。
- `dto`：请求对象；`vo`：响应对象；`convert`：对象转换。
- `common` / `config`：公共能力和项目配置。
- 依赖注入优先使用构造器注入：字段声明为 `private final`，类上使用 Lombok `@RequiredArgsConstructor`。

目录必须跟随项目现有结构。新增模块优先参考同类模块。

## Controller

- Controller 返回项目统一响应结构；特殊接口如文件、流式、Actuator、Webhook 可按协议返回。
- Controller 使用 `@RequiredArgsConstructor` + `private final` 注入 Service，避免字段注入。
- 请求体使用 `@Valid` / `@Validated`；路径和查询参数按项目方式启用校验。
- 不在 Controller 中写复杂业务、事务、SQL、对象拼装和通用 try-catch。
- 不直接返回 Entity、异常堆栈、SQL、内部类名、密钥或 Token。
- 路径遵循 API 设计规范；Java 侧路径变量使用清晰命名，如 `{userId}`。
- OpenAPI 注解应说明 summary、关键参数、响应和废弃状态。

## DTO / VO / Entity

- 请求 DTO 与响应 VO 分离，不复用 Entity 作为接口模型。
- DTO、VO、Entity 在项目允许 Lombok 时优先使用 `@Data`；只读或不可变对象可按项目风格使用 `@Getter`、`@Builder` 等。
- 需要无参/全参构造时使用 Lombok `@NoArgsConstructor`、`@AllArgsConstructor`，避免手写重复构造器。
- DTO 必须声明类型、校验规则和关键字段说明。
- VO 必须过滤密码、盐值、密钥、内部权限表达式和敏感字段。
- Entity 字段与表结构一致；ID、时间、金额、状态字段遵守项目和数据库规范。
- DTO / VO / Entity 转换集中在转换类、组件或项目既有工具中，不散落在 Controller。
- 简单同名字段转换可复用项目已有工具；复杂转换必须显式写清业务语义。

## Service 与事务

- 业务规则、权限后置校验、状态机、幂等和事务编排放在 Service。
- ServiceImpl 使用 `@Service`、`@RequiredArgsConstructor` 和 `private final` 注入 Mapper、Repository、Client 等依赖。
- 写操作涉及多步骤、跨表、状态流转或外部副作用时必须明确事务边界。
- 事务范围尽量小，不在长事务中调用慢外部接口、上传文件或做大量循环。
- 不吞异常后返回成功；需要补偿时必须说明补偿策略。
- 可预期业务失败使用项目统一业务异常和错误码。
- 批量操作必须限制数量、校验权限，并明确部分成功 / 全部回滚策略。

## Sa-Token 权限

- Sa-Token 负责登录态、会话、Token、踢人下线、禁用账号等认证能力。
- 业务权限优先采用“角色-菜单-接口路由”动态模型，不优先在 Controller 大量硬编码 `@SaCheckPermission("xxx")`。
- 后端必须根据请求路由做权限校验，Service 层继续校验数据归属；前端菜单/按钮权限只负责展示控制。
- Sa-Token 异常和路由权限拒绝必须纳入统一异常处理。
- 初始化权限基础设施或需要详细模板时，读取 `references/examples/springboot-examples.md`。

## Mapper / MyBatis-Plus

- 优先使用类型安全查询能力；复杂 SQL 可使用 XML 或自定义 SQL，但必须参数化。
- 禁止拼接用户输入生成 SQL；排序、过滤、导出字段必须白名单。
- 分页接口不直接暴露 MyBatis-Plus `IPage`，统一转换为项目分页响应。
- 查询默认考虑逻辑删除、租户 / 数据归属、权限范围和索引可用性。
- 复杂查询、分页、排序、逻辑删除和历史兼容场景必须有测试或风险说明。

## 异常与响应

- 成功和失败响应结构遵守项目统一规范；错误码遵守 API 设计规范。
- 业务异常应使用明确错误码；避免把可预期业务失败归为系统异常。
- 全局异常处理器统一处理业务异常、参数校验异常和未知异常。
- 未知异常服务端记录必要日志，对外返回受控错误，不暴露内部细节。

## 日志与配置

- 使用 Slf4j / 项目统一日志框架，禁止 `System.out.println` 进入生产代码。
- 日志记录业务 ID、用户 ID、请求 ID、耗时和结果等必要上下文。
- 禁止打印密码、Token、密钥、完整手机号、身份证、完整请求 / 响应大对象。
- 配置集中管理，环境差异通过 profile、环境变量或配置中心处理。
- 生产敏感配置不得提交仓库。

## 代码风格

- 遵循项目 `.editorconfig`、Checkstyle、Spotless、IDEA Code Style 或现有风格。
- 不提交无关格式化、无关重构、无关目录移动。
- 类和方法职责单一；重复逻辑达到维护成本时再抽象。
- 常量、枚举、错误码集中管理，避免魔法数字和重复文案。
- 注释解释业务意图、边界和原因，不重复代码本身。

## 交付清单

- 是否读取同类模块并延续项目结构。
- 是否符合 API、安全、数据库、依赖和测试规范。
- Controller 是否轻薄，Service 是否承载业务和事务。
- DTO / VO / Entity 是否分离，是否过滤敏感字段。
- 是否使用统一响应、错误码、异常处理和分页结构。
- 涉及权限时，是否使用 Sa-Token 统一认证，是否按角色-菜单-接口路由动态校验权限，Service 是否校验数据归属。
- 是否存在 SQL 注入、越权、日志泄露、事务过大或数据不一致风险。
- 是否补充测试，或说明未补测试原因。
- 是否执行项目对应测试 / 构建 / 静态检查命令。

## 可选示例

需要完整 Controller、DTO、分页、异常、MyBatis-Plus、OpenAPI 或配置样例时，再读取：

- `references/examples/springboot-examples.md`
