# Dependency Management Standard


## 目录

- [通用依赖管理原则](#通用依赖管理原则)
- [Maven 依赖管理规范](#maven-依赖管理规范)
- [Gradle 依赖管理规范](#gradle-依赖管理规范)
- [Python 依赖管理规范](#python-依赖管理规范)
- [前端依赖管理规范](#前端依赖管理规范)
- [开源协议与依赖准入规范](#开源协议与依赖准入规范)

本文件是 Java、Python、前端依赖版本、包管理工具、开源协议和依赖准入规则的唯一维护位置。各技术栈开发规范和入口文件只引用本文件，不重复维护依赖细则。

## 通用依赖管理原则

- 单个项目必须统一包管理工具和依赖声明方式，禁止同一项目混用多个包管理器或多个 lockfile。
- 所有依赖版本必须集中维护，禁止在业务模块中随意散落声明版本号。
- 必须提交对应包管理器的 lockfile，保证本地、CI、测试、生产构建可复现。
- 不使用动态版本、范围版本或未固定版本，除非项目工具链明确支持并经过评审。
- 新增依赖前必须确认必要性、License、维护状态、安全风险和传递依赖影响。
- AI 编码或代码生成过程中新增依赖前，必须说明必要性、替代方案、版本管理位置和风险；用户未授权、项目已有可复用能力或风险不清晰时，不得新增。
- 能使用标准库、框架内置能力或项目已有依赖解决的问题，不优先新增依赖。
- 新增依赖必须说明用途、影响范围、版本管理位置和回退方案。

## Maven 依赖管理规范

使用 Maven 的项目必须遵守本节。

以下版本号仅作为集中管理写法示例，实际项目应以项目 BOM、lockfile、兼容性验证和安全扫描结果为准。

版本管理要求：

- 单模块项目：依赖版本统一维护在根 `pom.xml` 的 `<properties>` 或 `<dependencyManagement>` 中。
- 多模块项目：依赖版本统一维护在父工程 `pom.xml` 的 `<properties>` 和 `<dependencyManagement>` 中。
- 子模块只声明依赖坐标，不重复声明 `<version>`，除非该依赖未被父工程统一管理。
- Spring Boot 官方管理的依赖版本优先交给 `spring-boot-dependencies` 管理。
- MyBatis-Plus、Hutool、springdoc 等非 Spring Boot 托管依赖必须在统一位置声明版本。
- AI 编码或代码生成过程中新增依赖前，必须说明必要性、替代方案、版本管理位置和风险；用户未授权、项目已有可复用能力或风险不清晰时，不得新增。

父工程依赖管理示例：

```xml
<properties>
    <java.version>17</java.version>
    <mybatis-plus.version>3.5.7</mybatis-plus.version>
    <hutool.version>5.8.32</hutool.version>
    <springdoc.version>2.6.0</springdoc.version>
</properties>

<dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-dependencies</artifactId>
            <version>${spring-boot.version}</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>

        <dependency>
            <groupId>com.baomidou</groupId>
            <artifactId>mybatis-plus-spring-boot3-starter</artifactId>
            <version>${mybatis-plus.version}</version>
        </dependency>

        <dependency>
            <groupId>cn.hutool</groupId>
            <artifactId>hutool-core</artifactId>
            <version>${hutool.version}</version>
        </dependency>

        <dependency>
            <groupId>org.springdoc</groupId>
            <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
            <version>${springdoc.version}</version>
        </dependency>
    </dependencies>
</dependencyManagement>
```

子模块依赖声明示例：

```xml
<dependency>
    <groupId>cn.hutool</groupId>
    <artifactId>hutool-core</artifactId>
</dependency>
```

## Gradle 依赖管理规范

使用 Gradle 的项目必须遵守本节。推荐使用 Gradle Wrapper，禁止依赖开发者本机全局 Gradle 版本。

以下版本号仅作为 Version Catalog 写法示例，实际项目应以项目 BOM、lockfile、兼容性验证和安全扫描结果为准。

版本管理方式优先级：

- 推荐使用 Version Catalog：`gradle/libs.versions.toml`。
- 多模块项目可结合根工程 `dependencyResolutionManagement`、`pluginManagement` 和 convention plugin。
- Spring Boot 项目优先使用 Spring Boot Gradle Plugin 和 BOM 管理 Spring 生态依赖。
- 子模块不直接散落写死版本号。
- 插件版本统一维护在 `settings.gradle`、`settings.gradle.kts` 或 Version Catalog 中。

`settings.gradle.kts` 示例：

```kotlin
pluginManagement {
    repositories {
        gradlePluginPortal()
        mavenCentral()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        mavenCentral()
    }
    versionCatalogs {
        create("libs") {
            from(files("gradle/libs.versions.toml"))
        }
    }
}
```

`gradle/libs.versions.toml` 示例：

```toml
[versions]
spring-boot = "3.3.5"
mybatis-plus = "3.5.7"
hutool = "5.8.32"
springdoc = "2.6.0"

[libraries]
mybatis-plus-boot3 = { module = "com.baomidou:mybatis-plus-spring-boot3-starter", version.ref = "mybatis-plus" }
hutool-core = { module = "cn.hutool:hutool-core", version.ref = "hutool" }
springdoc-openapi-ui = { module = "org.springdoc:springdoc-openapi-starter-webmvc-ui", version.ref = "springdoc" }

[plugins]
spring-boot = { id = "org.springframework.boot", version.ref = "spring-boot" }
```

模块依赖声明示例：

```kotlin
dependencies {
    implementation(libs.mybatis.plus.boot3)
    implementation(libs.hutool.core)
    implementation(libs.springdoc.openapi.ui)
}
```

Spring Boot BOM 示例：

```kotlin
dependencies {
    implementation(platform("org.springframework.boot:spring-boot-dependencies:3.3.5"))
}
```

Gradle 要求：

- 必须提交 `gradlew`、`gradlew.bat` 和 `gradle/wrapper`。
- 禁止提交本地 Gradle 缓存、构建产物和 IDE 私有文件。
- 多模块项目的公共配置应抽取到根工程或 convention plugin。
- 新增依赖时优先更新 `libs.versions.toml`，再在模块中引用 alias。
- 不使用 `+`、`latest.release`、动态版本或快照版本，除非明确是内部快照并经过评审。
- 依赖仓库优先使用 `mavenCentral()`，新增私服或第三方仓库必须说明原因。
- 禁止在子模块中随意新增 repositories。

## Python 依赖管理规范

使用 FastAPI 或其他 Python 服务的项目必须遵守本节。

包管理工具：

- 项目应统一使用一种 Python 依赖管理方式，如 `uv`、Poetry、PDM、pip-tools 或项目既有方案。
- 禁止同一项目同时维护多套主依赖入口，如同时把 `pyproject.toml`、`requirements.txt`、`Pipfile` 都作为主入口。
- 如项目已有统一工具，以项目现有工具和 CI 配置为准，不为了个人偏好更换包管理器。
- 必须提交对应 lockfile 或冻结依赖文件，如 `uv.lock`、`poetry.lock`、`pdm.lock`、`requirements.lock`、`requirements.txt`。
- 禁止提交虚拟环境目录，如 `.venv`、`venv`、`env`。

版本管理要求：

- 运行依赖和开发依赖必须区分维护。
- 运行依赖只包含生产运行需要的包。
- 测试、格式化、类型检查、代码生成等工具放入开发依赖组。
- 新增依赖时必须写入统一依赖入口，并更新 lockfile。
- 不使用未固定的裸依赖作为可发布环境输入，例如生产部署不应只依赖 `fastapi` 这类无版本约束声明。
- Python 版本必须在项目中明确声明，如 `.python-version`、`pyproject.toml` 的 `requires-python` 或 CI 配置。
- FastAPI、Pydantic、SQLAlchemy、Alembic、httpx 等核心依赖升级必须评估兼容性和迁移影响。

`pyproject.toml` 示例：

```toml
[project]
requires-python = ">=3.11"
dependencies = [
    "fastapi>=0.115,<1.0",
    "uvicorn[standard]>=0.30,<1.0",
    "sqlalchemy>=2.0,<3.0",
    "pydantic>=2.0,<3.0"
]

[dependency-groups]
dev = [
    "pytest>=8.0,<9.0",
    "ruff>=0.8,<1.0",
    "mypy>=1.0,<2.0"
]
```

`requirements.txt` 方案要求：

- 如项目使用 `requirements.in` / `requirements.txt`，应通过 pip-tools 或项目既有工具生成固定版本文件。
- `requirements.txt` 用于部署时必须包含可复现版本。
- 开发依赖建议拆分为 `requirements-dev.txt`。
- 不手工随意编辑生成文件，除非项目明确采用手工维护方式。

Python 依赖准入要求：

- 优先使用标准库、FastAPI、Pydantic、SQLAlchemy、项目已有工具。
- 引入数据库驱动、认证、安全、加密、任务队列、对象存储 SDK 等依赖前必须确认维护状态和安全风险。
- 引入带 C 扩展或系统依赖的包时，必须评估部署镜像、CI、Windows/macOS/Linux 兼容性。
- 引入异步相关依赖时，必须确认是否阻塞事件循环，是否适配当前 async 技术栈。
- 替换 Pydantic、ORM、HTTP Client、任务队列等基础库属于架构变更，必须先说明影响范围和迁移方案。

Python 提交前检查：

- 是否更新统一依赖入口和 lockfile。
- 是否区分运行依赖与开发依赖。
- 是否确认 Python 版本兼容。
- 是否能通过项目安装命令重新创建环境。
- 是否需要更新 Dockerfile、CI、部署脚本或启动命令。

## 前端依赖管理规范

使用 Vue、Soybean Admin 或其他前端项目时必须遵守本节。

包管理工具：

- 项目应统一使用一种包管理器。Soybean Admin 项目默认使用 `pnpm`。
- 禁止同一项目混用 `npm`、`yarn`、`pnpm`、`bun`。
- 必须提交对应 lockfile，如 `pnpm-lock.yaml`、`package-lock.json`、`yarn.lock`、`bun.lockb`。
- 禁止同时提交多个不同包管理器的 lockfile。
- 禁止提交 `node_modules`、构建产物和本地包管理器缓存。
- Node.js 版本必须明确声明，如 `.nvmrc`、`.node-version`、`package.json` 的 `engines` 或 CI 配置。

版本管理要求：

- 生产依赖放入 `dependencies`，构建、测试、类型检查、格式化工具放入 `devDependencies`。
- 不手工修改 lockfile 以绕过安装问题。
- 不使用 `latest`、`*` 或不受控的动态版本。
- 新增依赖必须通过项目包管理器安装，并同步提交 `package.json` 和 lockfile。
- 工作区项目必须在根目录统一维护 workspace 配置，避免子包私自引入不一致版本。
- `resolutions`、`overrides`、`pnpm.overrides` 只能用于解决明确冲突或安全问题，并说明原因。

Vue / Soybean Admin 依赖要求：

- 优先复用 Vue 3、Vue Router、Pinia、Ant Design Vue、UnoCSS、Vue I18n、Soybean Admin 已有工具链。
- 新增 UI 组件库、状态管理库、请求库、路由库、表格库、表单库前必须说明为什么现有体系无法满足。
- 禁止在 Soybean Admin 项目中绕过现有 request、router、store、hooks、i18n 体系另起一套基础设施。
- 引入图表、富文本、地图、编辑器、文件预览等大型依赖前，必须评估包体积、按需加载、许可证和移动端表现。
- 新增 Vite、ESLint、TypeScript、UnoCSS、自动导入、路由生成相关插件时，必须确认不会破坏现有构建和代码生成流程。

前端依赖准入要求：

- 检查 npm 包维护状态、下载来源、License、体积、tree-shaking 支持和安全漏洞。
- 优先选择 ESM 友好、支持 TypeScript、支持按需加载的依赖。
- 谨慎引入长期未维护、依赖链过深、安装脚本复杂或包含原生构建步骤的包。
- 浏览器端依赖禁止引入 Node-only API，避免构建后运行时失败。
- 涉及加密、认证、支付、文件处理等安全敏感能力时，必须优先使用成熟、维护良好的库，并评估合规风险。

前端提交前检查：

- 是否更新 `package.json` 和 lockfile。
- 是否使用项目指定包管理器安装。
- 是否把依赖放入正确的 `dependencies` / `devDependencies`。
- 是否需要更新 Dockerfile、CI、构建脚本或部署缓存。
- 是否执行或提示执行 `pnpm typecheck`、`pnpm lint`、必要时执行 `pnpm build`。

## 开源协议与依赖准入规范

所有新引入的 Java、Python、前端依赖必须满足项目可接受的开源协议要求，禁止引入商业授权、闭源限制或不适合业务分发的依赖。

允许优先使用的常见协议：

- Apache License 2.0
- MIT License
- BSD 2-Clause / BSD 3-Clause
- EPL 2.0
- MPL 2.0

需要谨慎评估的协议：

- LGPL
- GPL
- AGPL
- SSPL
- PolyForm
- Elastic License
- Commons Clause
- 未明确授权的自定义 License

依赖准入要求：

- 新增依赖前必须确认依赖坐标、版本、License、维护状态和安全风险。
- 禁止引入商业协议、试用协议、付费授权协议、限制生产使用的协议。
- 禁止引入 License 不明确、来源不可信或长期无人维护的依赖。
- 能使用 JDK、Python 标准库、Spring Boot、FastAPI、Vue、Soybean Admin 或现有工具实现的功能，不应轻易新增依赖。
- 同类工具只能保留一个主选型，避免同时引入多个功能高度重复的包。
- 新增依赖必须说明用途，不允许为了少量简单逻辑引入大型依赖。
- 如依赖存在传递依赖风险，应检查传递依赖的 License 和安全漏洞。

新增依赖检查清单：

- 是否确实需要新增依赖。
- 是否已有同类依赖可复用。
- Maven 版本是否在父 POM 或根 POM 统一维护。
- Gradle 版本是否在 Version Catalog、根工程或插件管理中统一维护。
- Python 依赖是否在统一依赖入口和 lockfile 中维护。
- 前端依赖是否在 `package.json` 和对应 lockfile 中维护。
- License 是否为项目允许的开源协议。
- 是否存在商业授权、生产使用限制或分发限制。
- 是否存在已知高危漏洞。
- 依赖体积和传递依赖是否可接受。
- 是否在文档或提交说明中说明新增依赖用途。


