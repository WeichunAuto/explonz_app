# CLAUDE.md - Explonz App

> 本文档是 Claude Code 在 Explonz 项目中的最高行为规范（Project Constitution）。
>
> Claude 在开始任何开发任务之前，必须首先阅读并遵守本文件。

---

# 一、项目目标

Explonz 是一个长期维护的 Flutter 中大型产品。

目标平台：

- iOS
- Android

项目目标（按优先级排序）：

1. 可维护性（Maintainability）
2. 可读性（Readability）
3. 可扩展性（Scalability）
4. 一致性（Consistency）
5. 性能（Performance）

**不要为了减少代码量而牺牲可维护性。**

---

# 二、核心原则（必须遵守）

始终（Always）：

- 优先复用已有代码，而不是重新实现。
- 优先保持架构一致性，而不是追求"更优雅"的实现。
- 优先保证代码可读性，而不是炫技。
- 每个类只负责一个职责（Single Responsibility）。
- 每个 Feature 保持独立、低耦合。

禁止（Never）：

- 修改与当前任务无关的代码。
- 重构未被要求修改的模块。
- 引入未经批准的新第三方依赖。
- 修改公共 API 或数据结构而不说明原因。
- 因个人偏好修改现有架构。

---

# 三、项目架构

采用：

- Feature First
- Clean Architecture
- Repository Pattern

目录结构：

```text
lib/
├── core/
├── features/
│   └── <feature>/
│       ├── data/
│       ├── domain/
│       └── presentation/
└── main.dart
```

依赖关系必须严格遵守：

```
Presentation
      ↓
   UseCase
      ↓
 Repository
      ↓
Datasource
      ↓
 ApiClient
```

禁止：

- Presentation 直接访问 Data 层
- Widget 直接调用 Repository
- Widget 直接调用 Dio
- Repository 依赖 Flutter Widget
- Domain 依赖 Flutter Framework

---

# 四、技术栈

状态管理：

- Riverpod
- AsyncNotifier
- Notifier

禁止：

- StateNotifier
- Provider（旧版）
- Bloc
- GetX

路由：

- GoRouter

网络：

- Dio

数据模型：

- freezed
- json_serializable

函数式错误处理：

- fpdart（Either<Failure, T>）

依赖注入：

- Riverpod Provider

---

# 五、开发规范

## Widget

- 一个 Widget 只负责一个功能。
- Widget 超过 400 行必须拆分。
- build() 方法只负责 UI 构建。
- build() 中禁止业务逻辑。

## UseCase

每个 UseCase：

- 只完成一件事情。
- 对外统一暴露 `call()` 方法。

例如：

```dart
final result = await loginUseCase(params);
```

## Repository

Repository 负责：

- 数据获取
- 数据缓存
- 数据转换
- Exception → Failure

Repository 不负责：

- UI
- BuildContext
- Widget

---

# 六、状态管理规范

Riverpod 仅负责：

- 页面状态
- UI 状态
- Feature 状态

业务逻辑必须放入：

UseCase

禁止：

- 在 Provider 中写复杂业务逻辑。
- Provider 直接调用 Dio。

---

# 七、命名规范

文件：

```
snake_case.dart
```

类：

```
PascalCase
```

Provider：

```
userProvider
loginNotifierProvider
```

UseCase：

```
LoginUseCase
FetchUserUseCase
```

Repository：

```
UserRepository
UserRepositoryImpl
```

Model：

```
UserModel
```

Entity：

```
User
```

DTO：

```
UserDto
```

保持整个项目命名一致。

---

# 八、UI 规范

禁止硬编码：

- Color
- TextStyle
- FontSize
- Radius
- Padding
- Margin
- 文案

统一使用：

- AppColors
- AppTypography
- AppSpacing
- AppRadius
- AppStrings

所有可复用 Widget 应抽取到：

```
lib/core/widgets/
```

---

# 九、错误处理

所有异步操作：

必须处理错误。

Repository：

统一捕获 Exception。

统一转换：

```
Failure
```

统一返回：

```
Either<Failure, T>
```

禁止：

- throw Exception
- 空 catch
- 忽略异常

UI 不直接处理 HTTP Exception。

---

# 十、性能规范

始终：

- 使用 const constructor（可使用时）
- 使用 ListView.builder
- 使用分页加载
- 拆分大型 Widget
- 减少不必要 rebuild
- 使用不可变对象（immutable）

不要为了"提前优化"增加复杂度。

---

# 十一、测试规范

必须：

- UseCase 编写单元测试。
- Repository 编写单元测试。
- 关键页面编写 Widget Test。

测试目录保持镜像：

```
test/
```

对应：

```
lib/
```

---

# 十二、AI 工作流程（Claude 必须遵守）

每次开始开发之前：

### Step 1

理解需求。

### Step 2

阅读相关代码。

包括：

- Provider
- Repository
- UseCase
- Widget
- Router

### Step 3

寻找已有实现。

优先复用。

不要重复造轮子。

### Step 4

如果涉及架构调整：

先输出修改方案。

等待确认。

### Step 5

开始实现。

仅修改必要文件。

不要修改无关模块。

### Step 6

完成后：

执行：

- dart format
- flutter analyze

如涉及业务逻辑：

执行对应测试。

---

# 十三、AI 自检清单（提交前必须检查）

确认：

- 是否遵守项目架构？
- 是否存在重复代码？
- 是否复用了已有组件？
- 是否新增了无必要依赖？
- 是否存在未使用 import？
- 是否存在未使用变量？
- 是否存在 Magic Number？
- 是否存在硬编码字符串？
- 是否存在不必要 rebuild？
- 是否保持命名一致？
- 是否补充测试？
- 是否需要更新文档？

---

# 十四、禁止事项

禁止：

- 使用 setState 管理跨组件状态。
- Widget 直接调用 Dio。
- Widget 直接调用 Repository。
- Provider 写复杂业务逻辑。
- Presentation 依赖 Data 层。
- Domain 依赖 Flutter。
- Repository 使用 BuildContext。
- Repository 返回 null。
- Repository 抛出 Exception。
- 为了完成任务重构整个 Feature。
- 删除已有代码而不确认影响。

---

# 十五、文档规范

本文件仅定义：

- 项目目标
- 核心原则
- Claude 行为规范
- 项目最高规则

详细规范统一维护于：

```
docs/

architecture/
coding/
testing/
design/
features/
api/
adr/
```

Claude 在实现复杂功能前，应优先阅读对应文档，而不是依赖猜测。
