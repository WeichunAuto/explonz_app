# PRD：启动 & 身份认证（Launch & Authentication）

**文档版本**：v1.1
**创建日期**：2026-07-04
**最后更新**：2026-07-04
**状态**：已确认

---

## 一、背景与目标

### 1.1 背景

Explonz 是一款面向探索与发现的社区型 App。为降低新用户使用门槛，App 采用"免登录即可浏览"策略——用户无需注册即可查看内容，仅在需要发帖、加入 Squad、发送消息等操作时才要求登录。

### 1.2 目标

- 降低新用户的首次使用摩擦，提升留存率。
- 在适当时机（点击"Me"标签）引导用户完成注册/登录。
- 支持 Google 账号与 Facebook 账号第三方快捷登录。
- 在首次启动时完成通知权限的申请。

### 1.3 成功指标（Success Metrics）

| 指标 | 目标值 |
|---|---|
| 启动后进入首页的转化率 | ≥ 95% |
| 通知权限授权率 | ≥ 40% |
| 未登录用户点击 Me 后的注册转化率 | ≥ 25% |
| 第三方登录（Google/Facebook）占比 | ≥ 60% |

---

## 二、用户故事（User Stories）

| ID | 角色 | 需求 | 验收标准 |
|---|---|---|---|
| US-01 | 新用户 | 打开 App 时看到品牌启动画面 | Launch 页展示 Explonz Logo，持续约 2 秒后自动跳转 |
| US-02 | 新用户（首次启动） | 系统询问是否允许通知 | 仅首次启动时展示 Permissions 页并触发系统权限弹窗 |
| US-03 | 新用户 | 不登录也能浏览 Discover 首页 | 跳过/拒绝通知后直接进入 Home 页，无需登录 |
| US-04 | 未登录用户 | 点击底部导航"Me"查看个人中心 | 展示登录/注册页（Me-unlogin），而非个人信息页 |
| US-05 | 未登录用户 | 使用 Email + Password 登录 | 填写邮箱和密码后点击 Log in，登录成功跳转至 Me 页 |
| US-06 | 未登录用户 | 使用 Google 账号一键登录/注册 | 点击 "Continue with Google"，完成 OAuth 授权后进入 App |
| US-07 | 未登录用户 | 使用 Facebook 账号一键登录/注册 | 点击 "Continue with Facebook"，完成 OAuth 授权后进入 App |
| US-08 | 未登录用户 | 忘记密码时找回 | 点击 "Forgot?" 进入密码重置流程 |
| US-09 | 未登录用户 | 没有账号时跳转注册 | 点击 "Sign up" 进入注册页面 |

---

## 三、交互流程（Interaction Flow）

### 3.1 完整流程图

```
APP 启动
    |
    v
[Launch 页] — 展示 Logo 约 2s
    |
    v
是否首次启动？
    |          \
   是           否
    |            \
    v             v
检查通知权限      [Home 首页]
    |
已授权？
    |         \
   是           否
    |            \
    v             v
[Home 首页]   [Permissions 页]
               |
          用户点击 Allow
               |
          系统弹出通知授权弹窗
               |
          用户同意 / 拒绝（均可）
               |
               v
          [Home 首页]
```

### 3.2 "Me" 标签点击流程

```
用户点击底部导航 "Me"
    |
已登录？
    |         \
   是           否
    |            \
    v             v
[Me 个人页]   [Me-unlogin 登录页]
               |
    ┌──────────┼──────────────┐
    |          |              |
    v          v              v
Email 登录  Google 登录  Facebook 登录
    |          |              |
    └──────────┴──────────────┘
               |
          登录/注册成功
               |
               v
          [Me 个人页]
```

---

## 四、页面规格（Screen Specifications）

### 4.1 Launch 页（启动页）

**触发条件**：每次 App 冷启动。

**UI 规格**：

| 元素 | 规格 |
|---|---|
| 背景 | 全屏渐变：Sunset Amber #FFB347 → Sunset Coral #F2683C（从上至下） |
| Logo | Explonz 图标 + 文字，白色，水平居中，垂直居中偏上 |

**行为逻辑**：

1. App 启动，立即展示 Launch 页。
2. 同时在后台执行初始化：检查登录态、读取 `isFirstLaunch` 本地标记。
3. 展示时长：最短 1.5 秒，初始化完成即可跳转，最长不超过 3 秒。
4. 跳转目标：根据 `isFirstLaunch` 决定跳转 Permissions 页或 Home 页。

---

### 4.2 Permissions 页（通知权限引导页）

**触发条件**：仅首次启动 且 系统通知权限未授权时展示。

**UI 规格**：

| 元素 | 规格 |
|---|---|
| 背景 | 浅暖色调渐变背景（浅橙至白） |
| 顶部 Logo | Explonz 图标 + 文字，深色，居中 |
| 插图 | 铃铛图标卡片，带装饰徽章（星形、闪电），居中 |
| 标题 | "Allow Permissions"，字号约 24px，加粗，居中 |
| 副标题 | "To stay on top of likes, comments, the latest posts and more, allow Explonz to send you notifications."，居中，字号约 14px |
| Allow 按钮 | 全宽，橙色渐变，圆角，文字 "Allow →"，白色 |
| Later 链接 | 文字按钮，居中，文字 "Later"，颜色较浅 |

**行为逻辑**：

1. 展示页面。
2. 用户点击 **Allow**：
   - 调用系统 API 弹出通知权限授权弹窗。
   - 用户同意或拒绝，均跳转至 Home 页。
3. 用户点击 **Later**：
   - 不请求通知权限，直接跳转至 Home 页。
4. 写入 `isFirstLaunch = false`，确保后续启动不再展示此页。

**通知权限重新引导（App 内入口）**：

用户在 Permissions 页点击"Later"或在系统弹窗中拒绝后，App 内应提供入口，引导用户前往系统设置重新开启通知。

- 入口位置：Me 个人页 → Settings（设置）→ Notifications（通知设置）
- 交互：检测到通知权限未开启时，展示提示条（Banner）："Enable notifications to stay updated. Tap to open Settings."
- 点击后：调用系统 API 直接跳转至该 App 的系统通知设置页（iOS: `UIApplication.openSettingsURLString`；Android: `Settings.ACTION_APP_NOTIFICATION_SETTINGS`）。
- 此功能属于 Me / Settings Feature，本 PRD 仅做记录，实现在对应 Feature 中完成。

---

### 4.3 Home 首页（Discover 标签）

**触发条件**：完成启动流程后的默认落地页。

**UI 规格**：

| 元素 | 规格 |
|---|---|
| 顶部标签栏 | For You（默认选中） / Nearby / Trending，红色下划线表示激活 |
| 右上角图标 | 搜索图标、汉堡菜单图标 |
| 活动通知条 | 黄绿色圆点 + 通知文本 + 角标数字，全宽横幅 |
| Seasonal Pickings | 横向滚动卡片列表，带 "View All" 链接 |
| Community Discoveries | 垂直信息流，每条含用户信息、标题、内容摘要、图片、标签、互动数 |
| FAB | 右下角橙色圆形 "+" 按钮 |
| 底部导航栏 | Discover（激活）/ Squads / Post / Message / Me |

**行为逻辑**：

- 未登录用户可正常浏览 For You / Nearby / Trending 内容。
- 点击 Post FAB 或 Squads / Message 导航：弹出登录引导或跳转 Me-unlogin 页（待后续 Feature PRD 定义）。
- 点击底部 "Me" 导航：跳转 Me-unlogin 页。

---

### 4.4 Me-unlogin 页（未登录状态的 Me 页）

**触发条件**：用户未登录时点击底部导航 "Me"。

**UI 规格**：

| 元素 | 规格 |
|---|---|
| 顶部区域 | 橙色渐变背景（Sunset Amber → Sunset Coral），展示 Explonz Logo |
| 标题 | "Welcome back"，加粗，约 24px |
| 副标题 | "Log in to discover, post and join squads."，约 14px，灰色 |
| Email 输入框 | 带信封图标，Placeholder: "you@example.com" |
| Password 输入框 | 带锁图标，默认隐藏密码，右侧 "SHOW" 切换；右上角 "Forgot?" 文字链接，橙色 |
| Log in 按钮 | 全宽，橙色渐变，圆角，白色文字 "Log in" |
| 分割线 | "OR LOGIN WITH"，两侧短横线 |
| Continue with Google | 全宽，白底深色边框，Google 彩色图标 + 文字 |
| Continue with Facebook | 全宽，白底深色边框，Facebook 蓝色图标 + 文字 |
| 注册引导 | "Don't have an account? Sign up"，"Sign up" 橙色，文字链接 |
| 底部导航栏 | 保持可见，Me 标签高亮 |

**行为逻辑**：

#### Email 登录

1. 用户输入邮箱 + 密码，点击 "Log in"。
2. 校验：邮箱格式、密码非空。
3. 调用登录 API。
4. 成功 → 跳转 Me 个人页。
5. 失败 → 在表单下方展示错误提示（如"密码错误"、"账号不存在"）。

#### Google 登录

1. 用户点击 "Continue with Google"。
2. 唤起 Google Sign-In SDK，进入 OAuth 授权流程。
3. 授权成功 → 后端验证 ID Token → 返回用户信息及 Session Token。
4. **新用户**：后端以 Google 账号的昵称和头像自动创建账号，无需额外引导，直接跳转 Me 个人页。用户后续可在设置中自行修改昵称/头像。
5. **已有账号（Email 相同）**：自动合并账号——将 Google 登录方式绑定至已有 Email 账号，以已有账号身份登录，跳转 Me 个人页。
6. **已有 Google 账号**：直接登录，跳转 Me 个人页。
7. 授权取消 → 停留在当前页，不展示错误提示。
8. 授权失败（服务异常）→ 停留在当前页，Toast 提示错误信息。

#### Facebook 登录

1. 用户点击 "Continue with Facebook"。
2. 唤起 Facebook Login SDK，进入 OAuth 授权流程。
3. 授权成功 → 后端验证 Access Token → 返回用户信息及 Session Token。
4. **新用户**：后端以 Facebook 账号的昵称和头像自动创建账号，无需额外引导，直接跳转 Me 个人页。用户后续可在设置中自行修改昵称/头像。
5. **已有账号（Email 相同）**：自动合并账号——将 Facebook 登录方式绑定至已有 Email 账号，以已有账号身份登录，跳转 Me 个人页。
6. **已有 Facebook 账号**：直接登录，跳转 Me 个人页。
7. 授权取消 → 停留在当前页，不展示错误提示。
8. 授权失败（服务异常）→ 停留在当前页，Toast 提示错误信息。

#### 忘记密码

1. 用户点击 "Forgot?"。
2. 跳转密码重置页（待后续 PRD 定义）。

#### 注册

1. 用户点击 "Sign up"。
2. 跳转注册页（待后续 PRD 定义）。

---

## 五、登录态管理

| 状态 | 存储方式 | 说明 |
|---|---|---|
| Access Token | Secure Storage（Keychain/Keystore） | 有效期 1 小时，请求时携带 |
| Refresh Token | Secure Storage（Keychain/Keystore） | 有效期 30 天，用于刷新 Access Token |
| isFirstLaunch | SharedPreferences | 首次启动标记，写入后不再重置 |
| 通知权限状态 | 系统 API 实时查询 | 不单独存储，每次启动从系统获取 |

**Token 刷新策略**：

- Access Token 过期时，客户端自动使用 Refresh Token 静默刷新，用户无感知。
- Refresh Token 过期（30 天未使用）→ 清除本地 Token，视为未登录，下次点击 Me 时展示 Me-unlogin 页。
- 刷新失败（网络异常）→ 保留本地 Token，待网络恢复后重试，不强制登出。

**登录态恢复**：

- App 启动时，在 Launch 页后台读取本地 Token。
- Access Token 有效 → 视为已登录。
- Access Token 过期但 Refresh Token 有效 → 自动静默刷新后视为已登录。
- Refresh Token 过期/不存在 → 视为未登录，用户点击 Me 时展示 Me-unlogin 页。

---

## 六、错误处理

| 场景 | 处理方式 |
|---|---|
| 网络不可用时点击 Log in | Toast 提示："Network unavailable. Please try again." |
| Email 格式不正确 | 输入框下方红色提示："Please enter a valid email address." |
| 密码为空 | 输入框下方红色提示："Password cannot be empty." |
| 账号不存在 | 表单下方提示："No account found with this email." |
| 密码错误 | 表单下方提示："Incorrect password. Please try again." |
| Google 授权取消 | 不展示错误，停留当前页 |
| Facebook 授权取消 | 不展示错误，停留当前页 |
| 第三方登录服务异常 | Toast 提示："Login failed. Please try again later." |

---

## 七、权限要求

| 权限 | 平台 | 时机 | 必要性 |
|---|---|---|---|
| Push Notification | iOS / Android | 首次启动（Permissions 页） | 可选 |
| Internet | iOS / Android | 运行时 | 必须 |

---

## 八、第三方 SDK 依赖

| SDK | 用途 | 平台 |
|---|---|---|
| google_sign_in | Google OAuth 登录 | iOS / Android |
| flutter_facebook_auth | Facebook OAuth 登录 | iOS / Android |
| flutter_local_notifications 或系统 API | 通知权限请求 | iOS / Android |
| flutter_secure_storage | Session Token 安全存储 | iOS / Android |
| shared_preferences | isFirstLaunch 标记存储 | iOS / Android |

> 所有新增依赖需在开发前确认引入，并更新 `pubspec.yaml`。

---

## 九、不在本期范围内（Out of Scope）

- 注册页（Sign Up）详细流程
- 密码重置（Forgot Password）流程
- Me 个人主页（已登录状态）
- Apple ID 登录
- 短信验证码登录
- 登出（Sign Out）逻辑
- 账号注销（Delete Account）

---

## 十、设计资源

| 文件 | 路径 |
|---|---|
| 启动页设计稿 | `docs/design/features/launch and authentication/Launch.png` |
| 权限引导页设计稿 | `docs/design/features/launch and authentication/Permissions.png` |
| 首页设计稿 | `docs/design/features/launch and authentication/Home.png` |
| 未登录 Me 页设计稿 | `docs/design/features/launch and authentication/Me-unlogin.png` |
| 全局色彩规范 | `docs/design/_global/colour-scheme.png` |

**品牌色彩参考（来自色彩规范）**：

> 色值定义见 `lib/core/theme/app_colors.dart`；设计稿见 `docs/design/_global/colour-scheme.png`。

**Core Palette**

| 名称 | Hex | AppColors Token | 本 Feature 用途 |
|---|---|---|---|
| Sunset Amber | #FFB347 | `AppColors.highlight` | 品牌渐变起始色（0%） |
| Sunset Coral | #F2683C | `AppColors.primary` | 主色 / 按钮 / 品牌渐变中间色（48%） |
| Dusk Plum | #B23A55 | `AppColors.depth` | 品牌渐变结束色（100%） |
| Trail Gold | #FFD15E | `AppColors.accent` | Accent 点缀色 |

**Ink & Surfaces**

| 名称 | Hex | AppColors Token | 本 Feature 用途 |
|---|---|---|---|
| Snow | #FFFFFF | `AppColors.onColour` | 彩色背景上的文字 / 图标 |
| Plum Ink | #5A3A5E | `AppColors.markLight` | 标记色 |
| Coral Ink | #E8743A | `AppColors.packLight` | 包裹色 |
| Forest Night | #10201D | `AppColors.darkSurf` | 深色底色 |

**品牌渐变**

| AppColors Token | 方向 | 渐变停止点 |
|---|---|---|
| `AppColors.brandGradient` | 水平（左 → 右） | #FFB347（0%）→ #F2683C（48%）→ #B23A55（100%） |

---

## 十一、待确认问题（Open Questions）

| # | 问题 | 负责人 | 状态 | 结论 |
|---|---|---|---|---|
| Q1 | 新用户注册后是否需要引导补充昵称/头像？ | Product | **已确认** | 不需要。直接使用 Google/Facebook 的昵称和头像，用户后续可自行修改。 |
| Q2 | 第三方登录若邮箱与已有账号相同，是否自动合并账号？ | Product + Backend | **已确认** | 是，自动合并——将第三方登录方式绑定至已有 Email 账号。 |
| Q3 | Session Token 有效期多长？是否支持 Refresh Token？ | Backend | **已确认** | Access Token 有效期 1 小时；Refresh Token 有效期 30 天，过期后需重新登录。 |
| Q4 | 连续登录失败锁定策略是否在后端执行还是前端控制？ | Backend | **移除** | 本期不实现锁定策略。 |
| Q5 | 通知权限被拒绝后，App 内部是否有入口引导用户去系统设置重新开启？ | Product | **已确认** | 需要。入口位于 Me → Settings → Notifications，详见 §4.2。 |
