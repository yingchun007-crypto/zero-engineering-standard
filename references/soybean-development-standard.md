# Soybean Development Standard


## 目录

- [技术栈](#技术栈)
- [包管理与脚本](#包管理与脚本)
- [目录规范](#目录规范)
- [Vue 组件规范](#vue-组件规范)
- [路由规范](#路由规范)
- [API 与请求规范](#api-与请求规范)
- [类型规范](#类型规范)
- [状态管理规范](#状态管理规范)
- [表单与表格规范](#表单与表格规范)
- [国际化规范](#国际化规范)
- [样式与主题规范](#样式与主题规范)
- [图标与资源规范](#图标与资源规范)
- [权限与菜单规范](#权限与菜单规范)
- [环境变量规范](#环境变量规范)
- [代码风格规范](#代码风格规范)
- [注释规范](#注释规范)
- [AI 编码代理规则](#ai-编码代理规则)
- [最小交付清单](#最小交付清单)

本文件用于约束基于 `soybeanjs/soybean-admin-antd` 的前端项目开发方式。规则参考 `soybean-admin-antd` 仓库源码、README 和项目配置整理；具体版本、脚本和目录以当前项目 `package.json`、lockfile、配置文件和已有代码为准。如项目已二次封装，优先遵循项目现有约定。

参考项目：

```text
https://github.com/soybeanjs/soybean-admin-antd
https://antd.soybeanjs.cn
https://docs.soybeanjs.cn
```

## 技术栈

- Vue 3
- Vite
- TypeScript
- pnpm
- Pinia
- Vue Router
- Ant Design Vue
- UnoCSS
- @soybeanjs/eslint-config
- Elegant Router
- Vue I18n
- Iconify / unplugin-icons

## 包管理与脚本

项目使用 pnpm，禁止混用 npm、yarn、bun。

常用脚本：

```text
pnpm dev
pnpm build
pnpm build:test
pnpm typecheck
pnpm lint
pnpm gen-route
pnpm commit
```

要求：

- 新增依赖前必须确认必要性、License、维护状态和体积影响。
- 不为少量简单逻辑新增大型依赖。
- 不重复引入与现有依赖能力重叠的库。
- 提交前至少执行 `pnpm typecheck` 和 `pnpm lint`。
- 新增页面路由后必须执行 `pnpm gen-route`。
- 不手工修改自动生成的路由文件，除非项目明确要求。

## 目录规范

遵循框架现有目录结构：

```text
src
├── assets       静态资源
├── components   全局/通用组件
├── constants    常量和业务字典
├── enum         枚举
├── hooks        组合式函数
├── layouts      布局
├── locales      国际化
├── plugins      插件初始化
├── router       路由与守卫
├── service      请求封装与接口
├── store        Pinia 状态
├── styles       全局样式
├── theme        主题变量
├── typings      全局类型声明
├── utils        工具函数
└── views        页面
```

要求：

- 页面放在 `src/views`。
- 页面内部组件放在当前页面目录的 `modules` 目录。
- 通用组件放在 `src/components`。
- 业务常量和选项放在 `src/constants`。
- 请求接口放在 `src/service/api`。
- 请求实例和拦截逻辑放在 `src/service/request`。
- 全局类型放在 `src/typings`。
- 状态模块放在 `src/store/modules`。

## Vue 组件规范

SFC 默认使用 `<script setup lang="ts">`。

需要 TSX 渲染列、复杂 render 或 Ant Design Vue 表格 `customRender` 时，可使用：

```vue
<script setup lang="tsx">
</script>
```

组件要求：

- 业务组件必须使用 `defineOptions({ name: 'XxxName' })` 声明组件名。
- 组件名使用 PascalCase。
- 模板中组件名使用 PascalCase，例如 `<UserSearch />`。
- Ant Design Vue 自动导入组件使用 `A` 前缀，例如 `<AButton />`、`<AForm />`、`<ATable />`。
- Props、Emits 必须声明类型。
- 双向绑定优先使用 `defineModel`。
- 复杂页面拆分为 `modules` 子组件，避免单个页面过大。
- 不在组件中写与页面无关的通用工具逻辑，应抽取到 `hooks` 或 `utils`。

推荐结构：

```vue
<script setup lang="ts">
defineOptions({
  name: 'UserSearch'
});

interface Emits {
  (e: 'reset'): void;
  (e: 'search'): void;
}

const emit = defineEmits<Emits>();
</script>

<template>
  <ACard :bordered="false" class="card-wrapper"></ACard>
</template>

<style scoped></style>
```

## 路由规范

项目使用 Elegant Router 和文件路由能力。

要求：

- 新增页面优先在 `src/views` 中按目录创建页面。
- 页面文件默认使用 `index.vue`。
- 动态路由文件使用 `[id].vue`、`[url].vue` 等框架约定。
- 内置页面放在 `_builtin`，业务页面不要放入 `_builtin`。
- 新增、删除、重命名页面后执行 `pnpm gen-route`。
- 不直接手写破坏 `src/router/elegant` 自动生成产物。
- 路由元信息、权限、菜单、缓存策略应遵循框架现有 `RouteMeta` 类型。
- 路由守卫逻辑集中在 `src/router/guard`，不要散落在页面组件中。

## API 与请求规范

接口统一维护在 `src/service/api`，请求实例统一使用 `src/service/request` 中的 `request`。

接口函数规范：

- 函数命名使用 `fetchXxx`。
- 必须声明请求参数类型和返回数据类型。
- 返回类型使用框架请求封装推断，不在页面中解析原始响应。
- 页面只消费 `data` 和 `error`，不要绕过统一请求封装。
- 不在页面组件中直接调用 `fetch`、`axios` 或创建独立请求实例。
- 接口路径、成功码、登出码、token 过期码等规则优先通过 `.env` 配置。

示例：

```ts
import { request } from '../request';

/** get user list */
export function fetchGetUserList(params?: Api.SystemManage.UserSearchParams) {
  return request<Api.SystemManage.UserList>({
    url: '/systemManage/getUserList',
    method: 'get',
    params
  });
}
```

请求错误处理要求：

- 后端响应结构由 `src/service/request` 统一转换。
- Token 过期、登出、弹窗登出等逻辑统一在请求层处理。
- 页面不重复弹出通用错误提示。
- 敏感信息、token、完整响应体不要打印到控制台。

## 类型规范

项目使用 TypeScript，必须保持类型清晰。

要求：

- 后端接口类型统一维护在 `src/typings/api.d.ts` 的 `Api` namespace。
- 通用应用类型维护在 `src/typings/app.d.ts`、`common.d.ts` 等类型文件。
- 禁止滥用 `any`；确需使用时必须说明原因。
- 查询参数、表单模型、响应对象必须有明确类型。
- 状态、枚举、字典值使用联合类型或枚举表达。
- 类型应与后端接口字段保持一致，不在页面临时拼凑类型。

推荐：

```ts
type Model = Pick<Api.SystemManage.User, 'userName' | 'userPhone' | 'status'>;
```

## 状态管理规范

项目使用 Pinia，状态模块放在 `src/store/modules`。

要求：

- Store 使用组合式写法 `defineStore(id, () => {})`。
- Store id 使用 `SetupStoreId` 等统一枚举或现有常量。
- 认证、路由、标签页、主题等全局状态使用已有 store。
- 页面局部状态不要放入全局 store。
- Store 中可封装跨页面复用的异步流程，但不要写页面 UI 细节。
- 登录态、token、用户信息等敏感状态必须通过现有 `auth` store 和 storage 工具管理。

## 表单与表格规范

优先使用框架已有 hooks：

- `useTable`
- `useTableOperate`
- `useTableScroll`
- `useAntdForm`
- `useFormRules`

表格要求：

- 列定义保持类型清晰。
- 操作列按钮保持小尺寸和清晰语义。
- 表格分页、加载状态、刷新逻辑优先复用 `useTable`。
- 移动端滚动和分页优先复用框架已有能力。

表单要求：

- Ant Design Vue 表单使用 `AForm`、`AFormItem`、`rules`。
- 必填和格式校验优先使用 `useFormRules`。
- 表单 `model` 必须定义类型。
- Drawer / Modal 打开时应初始化模型并重置校验状态。
- 提交前必须先 `validate()`。

## 国际化规范

项目内置 Vue I18n。项目启用 i18n 时，业务文案必须国际化；如项目明确是单语言内部后台，应保持现有文案组织方式。

要求：

- 页面展示文本使用 `$t`。
- 字典 label 使用 i18n key，不直接写死中文。
- 国际化文本维护在 `src/locales/langs`。
- 启用 i18n 的项目新增页面必须补充对应语言文本；单语言项目按现有语言文件或页面约定维护。
- 日期、Ant Design Vue、Day.js 国际化遵循 `src/locales` 现有配置。

示例：

```ts
import { $t } from '@/locales';

const title = $t('page.manage.user.title');
```

## 样式与主题规范

项目使用 UnoCSS、主题变量和少量 scoped 样式。

要求：

- 优先使用 UnoCSS 原子类和框架已有快捷类。
- 通用卡片使用 `card-wrapper` 等已有 shortcut。
- 主题色、暗色模式、字体等全局样式遵循 `src/theme` 和 `src/styles`。
- 不在页面中硬编码大量颜色、间距和 z-index。
- 页面样式使用 `<style scoped>`。
- 复杂通用样式应抽取到全局样式或组件，不要复制粘贴。
- 移动端适配优先使用已有响应式类，如 `lt-sm:*`、`sm:*`。

## 图标与资源规范

项目使用 Iconify 和本地 SVG 图标自动导入。

要求：

- Iconify 图标使用 `icon-*` 组件前缀。
- 本地 SVG 放入 `src/assets/svg-icon`。
- 本地图标命名遵循小写中划线。
- 不直接内联大段 SVG。
- 图片资源按业务目录归档，避免散落。

## 权限与菜单规范

框架支持静态路由和动态路由权限。

要求：

- 路由权限模式由 `VITE_AUTH_ROUTE_MODE` 控制。
- 静态超级角色由 `VITE_STATIC_SUPER_ROLE` 控制。
- 用户角色、按钮权限从 auth store 和路由 store 获取。
- 页面内按钮权限不要硬编码，应接入框架权限模型。
- 菜单图标、隐藏菜单、缓存、外链等配置遵循 `RouteMeta` 类型。

## 环境变量规范

环境变量必须以 `VITE_` 开头。

常见配置：

- `VITE_BASE_URL`
- `VITE_APP_TITLE`
- `VITE_AUTH_ROUTE_MODE`
- `VITE_ROUTE_HOME`
- `VITE_HTTP_PROXY`
- `VITE_ROUTER_HISTORY_MODE`
- `VITE_SERVICE_SUCCESS_CODE`
- `VITE_SERVICE_LOGOUT_CODES`
- `VITE_SERVICE_MODAL_LOGOUT_CODES`
- `VITE_SERVICE_EXPIRED_TOKEN_CODES`
- `VITE_STORAGE_PREFIX`

要求：

- 不在代码中硬编码服务地址、成功码、登出码、token 过期码。
- 生产环境密钥、token、私有地址不得提交到仓库。
- 新增环境变量必须同步更新类型声明和示例配置。

## 代码风格规范

项目使用 SoybeanJS ESLint 配置和 EditorConfig。

格式要求：

- UTF-8。
- LF 换行。
- 2 空格缩进。
- 文件末尾保留换行。
- 提交前清理无用 import。
- 组件模板命名使用 PascalCase。
- 不使用通配符式大范围导入。

提交前检查：

```text
pnpm typecheck
pnpm lint
```

## 注释规范

注释应说明业务意图、复杂逻辑和边界条件。

要求：

- API 函数应有简短注释。
- 复杂 store action、权限判断、请求错误处理必须有必要注释。
- 类型文件中的关键字段应有注释，便于调用方理解。
- 不保留大段注释掉的废弃代码。
- 不写重复代码本身的无意义注释。

## AI 编码代理规则

AI 修改前端代码时必须遵守：

- 修改前先阅读同目录已有页面、组件、store、api 写法。
- 不绕过框架的 request、router、store、hooks、i18n 体系。
- 新增页面后执行或提示执行 `pnpm gen-route`。
- 新增依赖前检查 License、必要性和是否已有同类能力。
- 不做无关 UI 重构，不改变整体布局风格。
- 启用 i18n 的项目不把中文文案直接写死在业务页面中；单语言项目遵循现有文案组织方式。
- 不在页面组件里直接创建 axios/fetch 请求。
- 不泄露 token、密钥、接口原始错误堆栈或完整敏感响应。

## 最小交付清单

新增或修改前端功能时检查：

- 是否遵循 `src/views`、`modules`、`service/api`、`store/modules` 等目录约定。
- 是否使用 TypeScript 明确类型。
- 是否使用统一 request 封装。
- 是否补充或更新 `Api` namespace 类型。
- 是否使用 `$t` 和 locales 维护文案。
- 是否复用 Ant Design Vue、UnoCSS、已有 hooks 和组件。
- 是否需要执行 `pnpm gen-route`。
- 是否通过 `pnpm typecheck` 和 `pnpm lint`。
- 是否避免新增不必要依赖。
- 是否避免敏感信息泄露。

