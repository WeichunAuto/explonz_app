# Explonz App — Claude Code 开发工作流步骤

> 本文档描述从设计稿到编码的完整流程，以及如何与 Claude Code / Harness 协作。

---

## 前置：需要开发自定义 Skill 吗？

**不需要。**

当前工作流所需能力已由以下内置机制覆盖：

| 需求                                            | 使用方式                              |
| ----------------------------------------------- | ------------------------------------- |
| 自动化重复操作（format、analyze、build_runner） | Harness Hook（`/update-config` 配置） |
| 编码后代码质量审查                              | 内置 `/simplify` skill                |
| 定时任务 / 远程触发                             | 内置 `/schedule` skill                |
| 配置权限、环境变量                              | 内置 `/update-config` skill           |

只有当你有**高度重复的、跨 session 的自定义工作流**（例如"每次新建 feature 自动生成脚手架"）时，才值得开发自定义 Skill。目前阶段不需要。

---

## 阶段一：环境准备（一次性）

### Step 1 — 确认目录结构

确保以下目录存在（已由项目初始化创建）：

```
docs/design/_global/          # 全局设计规范
docs/design/features/         # 各 feature 设计稿
docs/features/                # PRD 文档（Claude 生成）
docs/architecture/            # 架构设计文档（Claude 生成）
assets/images/                # 位图资源
assets/icons/                 # SVG 图标
assets/fonts/                 # 自定义字体
```

### Step 2 — 配置 Harness Hooks

在项目根目录执行 `/update-config`，配置以下自动化行为：

**Hook 1：编辑 Dart 文件后自动格式化**

- 触发事件：`PostToolUse: Edit`
- 条件：文件路径匹配 `lib/**/*.dart`
- 命令：`dart format $FILE`

**Hook 2：任务完成后自动静态分析**

- 触发事件：`Stop`
- 命令：`flutter analyze --no-fatal-infos`

**Hook 3：model/provider 文件变更后提醒 build_runner**

- 触发事件：`PostToolUse: Edit`
- 条件：文件路径匹配 `**/*.freezed.dart` 或 `**/models/**`
- 命令：提示用户运行 `dart run build_runner build`

### Step 3 — 配置权限

通过 `/update-config` 将以下命令加入自动允许列表，避免每次确认：

```
dart format
flutter analyze
dart run build_runner build --delete-conflicting-outputs
flutter test
```

---

## 阶段二：全局设计规范输入（一次性）

### Step 4 — 放置全局设计文件

将以下文件放入 `docs/design/_global/`：

| 文件名              | 内容                                   |
| ------------------- | -------------------------------------- |
| `colour-scheme.png` | 色彩方案（已完成）                     |
| `typography.png`    | 字体规范（字号、字重、行高）           |
| `spacing.png`       | 间距规范                               |
| `components.png`    | 通用组件规范（Button、Input、Card 等） |
| `navigation.png`    | 导航结构 / 底部栏设计                  |

### Step 5 — 要求 Claude 提取全局 Token

所有全局规范文件放好后，对 Claude 说：

```
请读取 docs/design/_global/ 下的所有设计规范图，
根据规范更新以下文件：
- lib/core/theme/app_typography.dart
- lib/core/theme/app_spacing.dart
- lib/core/theme/app_colors.dart（如有补充）
- lib/core/theme/app_radius.dart
```

**等 Claude 完成并通过 `flutter analyze` 后，再进入下一阶段。**

---

## 阶段三：Feature 开发循环（每个 feature 重复）

每个 feature 按以下顺序执行，**不要跳步**。

---

### Step 6 — 放置设计稿

将该 feature 的所有设计稿截图放入：

```
docs/design/features/<feature-name>/
```

命名规范：

```
01-login.png          # 用数字前缀保证顺序
02-login-error.png
03-register.png
04-register-success.png
```

### Step 7 — 放置切图资源

将设计师导出的切图放入对应目录：

**SVG 图标** → `assets/icons/`

```
ic_home.svg
ic_profile.svg
ic_arrow_right.svg
```

**PNG 位图**（需提供 1x / 2x / 3x）：

```
assets/images/img_onboarding.png        # 1x
assets/images/2.0x/img_onboarding.png   # 2x
assets/images/3.0x/img_onboarding.png   # 3x
```

**字体文件** → `assets/fonts/`

```
Inter-Regular.ttf
Inter-Medium.ttf
Inter-SemiBold.ttf
```

> 新增资源后告知 Claude 更新 `pubspec.yaml` 的 assets/fonts 注册。

---

### Step 8 — 生成 PRD

文件放好后，对 Claude 说：

```
请读取 docs/design/features/auth/ 下的所有设计稿，
为 auth feature 生成 PRD，输出到 docs/features/auth.md。

PRD 需包含：
- 功能概述
- 用户故事（User Stories）
- 页面清单及交互说明
- 数据需求
- 边界条件 / 异常处理
```

**你审阅 `docs/features/auth.md`，修改后继续。**

---

### Step 9 — 生成系统设计

PRD 确认后，对 Claude 说：

```
请根据 docs/features/auth.md，输出 auth feature 的系统设计，
包含：
- 数据模型（Entity / Model / DTO）
- Repository 接口定义
- UseCase 清单
- Provider / State 结构
- 路由定义
输出到 docs/architecture/auth.md。
```

**你审阅架构设计，确认后继续。**

---

### Step 10 — 开始编码

架构设计确认后，对 Claude 说：

```
请根据 docs/features/auth.md 和 docs/architecture/auth.md，
按照 CLAUDE.md 规范实现 auth feature。
按以下顺序实现：
1. Entity + Model（freezed）
2. Repository 接口 + Impl
3. UseCase
4. Provider
5. Page + Widget
```

Claude 编码期间，Harness Hook 会自动执行 `dart format`。

---

### Step 11 — 运行代码生成

有新的 freezed / riverpod 文件时运行：

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

### Step 12 — 代码审查

编码完成后，执行：

```
/simplify
```

Claude 会检查：重复代码、可复用性、命名一致性、不必要的复杂度。

---

### Step 13 — 运行测试

```bash
flutter test test/features/auth/
flutter analyze
```

---

### Step 14 — 进入下一个 Feature

重复 Step 6 ~ Step 13。

---

## 快速参考：何时可以要求编码？

```
✅ docs/features/<feature>.md 已审阅确认
✅ docs/architecture/<feature>.md 已审阅确认
✅ 切图已放入 assets/ 对应目录
✅ pubspec.yaml 已注册新资源
```

满足以上四条，即可执行 Step 10。

---

## 目录结构速查

```
docs/
├── design/
│   ├── _global/            ← 全局规范图（Step 4）
│   └── features/
│       └── <feature>/      ← 设计稿（Step 6）
├── features/               ← PRD（Step 8 Claude 生成）
└── architecture/           ← 系统设计（Step 9 Claude 生成）

assets/
├── icons/                  ← SVG 切图（Step 7）
├── images/                 ← PNG 切图（Step 7）
└── fonts/                  ← 字体文件（Step 7）

lib/
└── features/
    └── <feature>/          ← 代码（Step 10 Claude 生成）
```

---

## 提示词模板

### 生成 PRD

```
请读取 docs/design/features/<feature>/ 下的设计稿，
为 <feature> feature 生成 PRD，输出到 docs/features/<feature>.md。
```

### 生成架构设计

```
请根据 docs/features/<feature>.md，
输出系统设计到 docs/architecture/<feature>.md。
```

### 开始编码

```
请根据 docs/features/<feature>.md 和 docs/architecture/<feature>.md，
按照 CLAUDE.md 规范实现 <feature> feature。
```

### 代码审查

```
/simplify
```
