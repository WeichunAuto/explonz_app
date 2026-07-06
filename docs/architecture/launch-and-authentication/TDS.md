# TDS：启动 & 身份认证（Launch & Authentication）

**文档版本**：v1.2
**创建日期**：2026-07-04
**最后更新**：2026-07-05
**对应 PRD**：`docs/features/launch-and-authentication/PRD.md`
**状态**：待评审

---

## 一、现有代码基础

| 文件 | 现状 | 本次处理 |
|---|---|---|
| `lib/core/errors/failures.dart` | 已有 NetworkFailure / ServerFailure / CacheFailure / UnauthorizedFailure / UnknownFailure | 直接复用，无需修改 |
| `lib/core/utils/typedef.dart` | 已有 `FutureEither<T>` / `FutureEitherVoid` | 直接复用 |
| `lib/core/constants/app_constants.dart` | 已有 `tokenKey` / `refreshTokenKey` / `baseUrl` | 补充 `isFirstLaunchKey` 常量 |
| `lib/core/network/api_client.dart` | Dio Provider，含 PrettyDioLogger，TODO 注释留有 Auth Interceptor 位置 | 补充 `AuthInterceptor` |
| `lib/core/router/app_router.dart` | 仅有 `/login` 和 `/`，无 auth 重定向逻辑 | 重构为 ShellRoute + redirect 守卫 |
| `lib/features/auth/presentation/pages/login_page.dart` | 空 Stub | 按设计稿重新实现 |
| `lib/features/home/presentation/pages/home_page.dart` | 空 Stub | 暂不处理（属于 Home Feature） |

---

## 二、新增目录结构

```
lib/
├── core/
│   ├── network/
│   │   ├── api_client.dart              # 已有，补充 AuthInterceptor 注册
│   │   └── auth_interceptor.dart        # NEW — Token 自动刷新拦截器
│   ├── services/
│   │   └── notification_service.dart    # NEW — 通知权限封装
│   └── constants/
│       └── app_constants.dart           # 已有，补充 isFirstLaunchKey
│
└── features/
    ├── launch/                          # NEW Feature — 启动 & 通知引导
    │   └── presentation/
    │       ├── pages/
    │       │   ├── launch_page.dart
    │       │   └── permissions_page.dart
    │       └── providers/
    │           └── launch_notifier.dart
    │
    └── auth/                            # 已有目录，扩充完整层次
        ├── data/
        │   ├── datasources/
        │   │   ├── auth_remote_datasource.dart
        │   │   ├── auth_local_datasource.dart
        │   │   └── social_auth_datasource.dart
        │   ├── models/
        │   │   ├── auth_response_model.dart  # 登录响应（token + user 合并）
        │   │   ├── auth_token_model.dart     # 仅 token（用于 /auth/refresh）
        │   │   └── user_model.dart
        │   └── repositories/
        │       └── auth_repository_impl.dart
        ├── domain/
        │   ├── entities/
        │   │   ├── auth_response.dart        # 登录响应聚合（AuthToken + User）
        │   │   ├── auth_token.dart
        │   │   └── user.dart
        │   ├── repositories/
        │   │   └── auth_repository.dart
        │   └── usecases/
        │       ├── login_with_email_usecase.dart
        │       ├── login_with_google_usecase.dart
        │       ├── login_with_facebook_usecase.dart
        │       ├── refresh_token_usecase.dart
        │       └── get_auth_status_usecase.dart
        └── presentation/
            ├── pages/
            │   └── login_page.dart      # 重新实现
            ├── widgets/
            │   ├── login_header.dart
            │   ├── email_login_form.dart
            │   └── social_login_button.dart
            └── providers/
                ├── auth_state.dart
                └── auth_notifier.dart
```

---

## 三、依赖关系

严格遵守 Clean Architecture 单向依赖：

```
Presentation (pages / providers)
        ↓
    UseCase
        ↓
  Repository (interface — domain层)
        ↓
RepositoryImpl (data层)
        ↓
  Datasource (Remote / Local / Social)
        ↓
   Dio / SDK / SecureStorage
```

跨层禁止：
- Presentation 不得直接访问 Datasource 或 Dio
- Domain 层（Entity / UseCase / Repository interface）不得 import Flutter 或第三方 SDK

---

## 四、Domain 层

### 4.1 Entities

**`auth_response.dart`**

登录接口（`/auth/login`、`/auth/google`、`/auth/facebook`）同时返回 token 和 user，用此聚合实体承载，避免登录后再发起额外 `GET /users/me` 请求。

```dart
@freezed
class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
    required AuthToken token,
    required User user,
  }) = _AuthResponse;
}
```

**`auth_token.dart`**

```dart
@freezed
class AuthToken with _$AuthToken {
  const factory AuthToken({
    required String accessToken,
    required String refreshToken,
    required DateTime accessTokenExpiresAt,
    required DateTime refreshTokenExpiresAt,
  }) = _AuthToken;

  const AuthToken._();

  bool get isAccessTokenExpired =>
      DateTime.now().isAfter(accessTokenExpiresAt);

  bool get isRefreshTokenExpired =>
      DateTime.now().isAfter(refreshTokenExpiresAt);
}
```

**`user.dart`**

```dart
enum AuthProvider { email, google, facebook }

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String nickname,
    String? avatarUrl,
    String? email,
    @Default([]) List<AuthProvider> providers,
  }) = _User;
}
```

### 4.2 Repository Interface

**`auth_repository.dart`**

```dart
abstract interface class AuthRepository {
  /// Email + Password 登录，返回 token + user 聚合（来自同一响应，无需额外网络请求）
  FutureEither<AuthResponse> loginWithEmail({
    required String email,
    required String password,
  });

  /// Google OAuth 登录/注册（含账号合并），返回 token + user 聚合
  FutureEither<AuthResponse> loginWithGoogle();

  /// Facebook OAuth 登录/注册（含账号合并），返回 token + user 聚合
  FutureEither<AuthResponse> loginWithFacebook();

  /// 使用 Refresh Token 静默刷新 Access Token（响应不含 user，仅返回新 token）
  FutureEither<AuthToken> refreshToken();

  /// App 重启时从后端获取当前用户信息（本地有 token 但无 user 缓存时调用）
  FutureEither<User> getCurrentUser();

  /// 是否处于登录状态（本地判断，不走网络）
  bool get isLoggedIn;

  /// 登出：清除本地 Token
  FutureEitherVoid logout();
}
```

### 4.3 UseCases

每个 UseCase 只做一件事，对外暴露 `call()`。

| UseCase | 入参 | 返回 | 说明 |
|---|---|---|---|
| `LoginWithEmailUseCase` | `LoginWithEmailParams` | `FutureEither<AuthResponse>` | 邮箱密码登录，响应含 token + user |
| `LoginWithGoogleUseCase` | 无 | `FutureEither<AuthResponse>` | SDK 授权 + 后端验证，响应含 token + user |
| `LoginWithFacebookUseCase` | 无 | `FutureEither<AuthResponse>` | SDK 授权 + 后端验证，响应含 token + user |
| `RefreshTokenUseCase` | 无 | `FutureEither<AuthToken>` | Token 静默刷新，响应仅含新 token |
| `GetAuthStatusUseCase` | 无 | `bool` | 同步判断本地登录态 |

```dart
// 示例
class LoginWithEmailUseCase {
  const LoginWithEmailUseCase(this._repository);
  final AuthRepository _repository;

  FutureEither<AuthResponse> call(LoginWithEmailParams params) =>
      _repository.loginWithEmail(
        email: params.email,
        password: params.password,
      );
}

@freezed
class LoginWithEmailParams with _$LoginWithEmailParams {
  const factory LoginWithEmailParams({
    required String email,
    required String password,
  }) = _LoginWithEmailParams;
}
```

---

## 五、Data 层

### 5.0 API 接口约定

> **[ASSUMED — 待 Backend 确认后修改]**
> 以下接口结构为前端假定值，字段名、错误码、响应结构均可能与实际不符。
> 需在开发前与 Backend 对齐，对齐后删除此注释。

#### 通用错误响应

```json
// HTTP 4xx / 5xx
{
  "error": {
    "code": "invalid_credentials",   // [ASSUMED] 错误码字符串，待确认枚举值
    "message": "Incorrect email or password."
  }
}
```

常见错误码（假定）：

| code | HTTP Status | 场景 |
|---|---|---|
| `invalid_credentials` | 401 | 邮箱或密码错误 |
| `account_not_found` | 404 | 邮箱未注册 |
| `token_expired` | 401 | Access Token 过期 |
| `refresh_token_expired` | 401 | Refresh Token 过期，需重新登录 |
| `validation_error` | 422 | 请求参数校验失败 |

#### POST `/auth/login` — Email 登录

```json
// Request
{
  "email": "user@example.com",
  "password": "password123"
}

// Response 200
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "dGhpcyBpcyBhIHJlZnJlc2ggdG9rZW4...",
  "access_token_expires_at": 1751792400,   // Unix timestamp（秒）
  "refresh_token_expires_at": 1754384400,  // Unix timestamp（秒）
  "user": {                                // [ASSUMED] token 和 user 合并在同一响应
    "id": "usr_abc123",
    "nickname": "JohnDoe",
    "avatar_url": "https://cdn.explonz.com/avatars/usr_abc123.jpg",
    "email": "user@example.com",
    "providers": ["email"]                 // [ASSUMED] 已绑定的登录方式列表
  }
}
```

#### POST `/auth/google` — Google OAuth 登录/注册

```json
// Request
{
  "id_token": "google_id_token_from_sdk"  // google_sign_in SDK 返回的 ID Token
}

// Response 200（与 /auth/login 结构相同）
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "dGhpcyBpcyBhIHJlZnJlc2ggdG9rZW4...",
  "access_token_expires_at": 1751792400,
  "refresh_token_expires_at": 1754384400,
  "user": {
    "id": "usr_abc123",
    "nickname": "John Doe",               // 来自 Google 账号昵称
    "avatar_url": "https://lh3.googleusercontent.com/...",
    "email": "user@gmail.com",
    "providers": ["google"]
  }
}
// [ASSUMED] 账号合并（邮箱相同）由 Backend 静默处理，
// 前端收到的响应结构与正常登录相同，无额外字段标识合并行为。
```

#### POST `/auth/facebook` — Facebook OAuth 登录/注册

```json
// Request
{
  "access_token": "facebook_access_token_from_sdk"  // flutter_facebook_auth SDK 返回的 Access Token
}

// Response 200（与 /auth/login 结构相同）
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "dGhpcyBpcyBhIHJlZnJlc2ggdG9rZW4...",
  "access_token_expires_at": 1751792400,
  "refresh_token_expires_at": 1754384400,
  "user": {
    "id": "usr_abc123",
    "nickname": "John Doe",               // 来自 Facebook 账号昵称
    "avatar_url": "https://graph.facebook.com/...",
    "email": "user@facebook.com",
    "providers": ["facebook"]
  }
}
```

#### POST `/auth/refresh` — 刷新 Access Token

```json
// Request
{
  "refresh_token": "dGhpcyBpcyBhIHJlZnJlc2ggdG9rZW4..."
}

// Response 200
{
  "access_token": "new_access_token...",
  "refresh_token": "new_refresh_token...",         // [ASSUMED] 每次刷新同时轮换 Refresh Token
  "access_token_expires_at": 1751796000,
  "refresh_token_expires_at": 1754388000
}
// [ASSUMED] 不返回 user 对象
```

#### GET `/users/me` — 获取当前用户信息

```json
// Response 200
{
  "id": "usr_abc123",
  "nickname": "JohnDoe",
  "avatar_url": "https://cdn.explonz.com/avatars/usr_abc123.jpg",
  "email": "user@example.com",
  "providers": ["email", "google"]   // 已绑定的所有登录方式
}
```

---

#### iOS 原生配置（假定占位）

> **[ASSUMED — 待项目负责人提供后替换]**

```xml
<!-- ios/Runner/Info.plist -->

<!-- Google Sign-In URL Scheme -->
<!-- [ASSUMED] 格式为 com.googleusercontent.apps.<reversed_client_id> -->
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>com.googleusercontent.apps.XXXXXXXX-PLACEHOLDER</string>
    </array>
  </dict>
</array>

<!-- Facebook Login -->
<!-- [ASSUMED] 需替换为实际 App ID 和 Client Token -->
<key>FacebookAppID</key>
<string>FACEBOOK_APP_ID_PLACEHOLDER</string>
<key>FacebookClientToken</key>
<string>FACEBOOK_CLIENT_TOKEN_PLACEHOLDER</string>
<key>FacebookDisplayName</key>
<string>Explonz</string>
```

```kotlin
// android/app/src/main/res/values/strings.xml
// [ASSUMED] 需替换为实际值
<string name="facebook_app_id">FACEBOOK_APP_ID_PLACEHOLDER</string>
<string name="fb_login_protocol_scheme">fbFACEBOOK_APP_ID_PLACEHOLDER</string>
<string name="facebook_client_token">FACEBOOK_CLIENT_TOKEN_PLACEHOLDER</string>
```

---

### 5.1 Models

**`auth_response_model.dart`**（登录接口专用，token + user 合并响应）

对应 `POST /auth/login`、`POST /auth/google`、`POST /auth/facebook` 响应结构。

```dart
@freezed
class AuthResponseModel with _$AuthResponseModel {
  const factory AuthResponseModel({
    @JsonKey(name: 'access_token')           required String    accessToken,
    @JsonKey(name: 'refresh_token')          required String    refreshToken,
    /// Unix timestamp（秒）
    @JsonKey(name: 'access_token_expires_at')  required int     accessTokenExpiresAt,
    /// Unix timestamp（秒）
    @JsonKey(name: 'refresh_token_expires_at') required int     refreshTokenExpiresAt,
    required UserModel user,
  }) = _AuthResponseModel;

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseModelFromJson(json);
}

extension AuthResponseModelX on AuthResponseModel {
  AuthResponse toEntity() => AuthResponse(
    token: AuthToken(
      accessToken: accessToken,
      refreshToken: refreshToken,
      accessTokenExpiresAt:
          DateTime.fromMillisecondsSinceEpoch(accessTokenExpiresAt * 1000),
      refreshTokenExpiresAt:
          DateTime.fromMillisecondsSinceEpoch(refreshTokenExpiresAt * 1000),
    ),
    user: user.toEntity(),
  );

  /// 用于本地存储（仅持久化 token 部分）
  AuthTokenModel toTokenModel() => AuthTokenModel(
    accessToken: accessToken,
    refreshToken: refreshToken,
    accessTokenExpiresAt: accessTokenExpiresAt,
    refreshTokenExpiresAt: refreshTokenExpiresAt,
  );
}
```

**`auth_token_model.dart`**（刷新接口专用，`POST /auth/refresh` 响应不含 user）

服务端以 **Unix timestamp（秒）** 返回过期时间。

```dart
@freezed
class AuthTokenModel with _$AuthTokenModel {
  const factory AuthTokenModel({
    @JsonKey(name: 'access_token')             required String accessToken,
    @JsonKey(name: 'refresh_token')            required String refreshToken,
    /// Unix timestamp（秒），服务端返回
    @JsonKey(name: 'access_token_expires_at')  required int    accessTokenExpiresAt,
    /// Unix timestamp（秒），服务端返回
    @JsonKey(name: 'refresh_token_expires_at') required int    refreshTokenExpiresAt,
  }) = _AuthTokenModel;

  factory AuthTokenModel.fromJson(Map<String, dynamic> json) =>
      _$AuthTokenModelFromJson(json);
}

extension AuthTokenModelX on AuthTokenModel {
  AuthToken toEntity() => AuthToken(
    accessToken: accessToken,
    refreshToken: refreshToken,
    accessTokenExpiresAt:
        DateTime.fromMillisecondsSinceEpoch(accessTokenExpiresAt * 1000),
    refreshTokenExpiresAt:
        DateTime.fromMillisecondsSinceEpoch(refreshTokenExpiresAt * 1000),
  );
}
```

**`user_model.dart`**

```dart
@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String nickname,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    String? email,
    @Default([]) List<String> providers,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

extension UserModelX on UserModel {
  User toEntity() => User(
    id: id,
    nickname: nickname,
    avatarUrl: avatarUrl,
    email: email,
    providers: providers.map((p) => AuthProvider.values.byName(p)).toList(),
  );
}
```

### 5.2 Datasources

**`auth_remote_datasource.dart`** — 后端 API 调用

| 方法 | HTTP | 路径 | Body | 返回类型 |
|---|---|---|---|---|
| `loginWithEmail` | POST | `/auth/login` | `{email, password}` | `AuthResponseModel` |
| `loginWithGoogle` | POST | `/auth/google` | `{id_token}` | `AuthResponseModel` |
| `loginWithFacebook` | POST | `/auth/facebook` | `{access_token}` | `AuthResponseModel` |
| `refreshToken` | POST | `/auth/refresh` | `{refresh_token}` | `AuthTokenModel` |
| `getCurrentUser` | GET | `/users/me` | — | `UserModel` |

所有方法：捕获 `DioException`，转换为对应 `Failure`，不 throw。

**`auth_local_datasource.dart`** — 本地安全存储

使用 `flutter_secure_storage`：

| 方法 | Key | 说明 |
|---|---|---|
| `saveToken(AuthTokenModel)` | `AppConstants.tokenKey` / `refreshTokenKey` | 持久化 Token |
| `readToken()` → `AuthTokenModel?` | 同上 | 读取本地 Token |
| `deleteToken()` | 同上 | 登出时清除 |
| `isFirstLaunch()` → `bool` | `AppConstants.isFirstLaunchKey` | 读取 SharedPreferences |
| `setFirstLaunchDone()` | 同上 | 写入后不再为 true |

**`social_auth_datasource.dart`** — 第三方 SDK 封装

```dart
abstract interface class SocialAuthDatasource {
  /// 唤起 Google Sign-In，返回 idToken；取消返回 null
  Future<String?> signInWithGoogle();

  /// 唤起 Facebook Login，返回 accessToken；取消返回 null
  Future<String?> signInWithFacebook();
}
```

实现类分别封装 `google_sign_in` 和 `flutter_facebook_auth` SDK，屏蔽 SDK 细节。

### 5.3 Repository 实现

**`auth_repository_impl.dart`** — 协调三个 Datasource

```dart
// 邮箱登录：返回 AuthResponse（token + user 来自同一响应，无额外网络请求）
@override
FutureEither<AuthResponse> loginWithEmail({
  required String email,
  required String password,
}) async {
  try {
    final model = await _remote.loginWithEmail(email: email, password: password);
    await _local.saveToken(model.toTokenModel()); // 仅持久化 token 部分
    return Right(model.toEntity());
  } on NetworkFailure catch (f) {
    return Left(f);
  } on ServerFailure catch (f) {
    return Left(f);
  } catch (e) {
    return Left(Failure.unknown(message: e.toString()));
  }
}

// Google 登录：SDK 取 idToken → 后端验证 → 本地持久化 token → 返回 AuthResponse
@override
FutureEither<AuthResponse> loginWithGoogle() async {
  try {
    final idToken = await _social.signInWithGoogle();
    if (idToken == null) return Left(const Failure.unknown(message: 'Cancelled'));
    final model = await _remote.loginWithGoogle(idToken: idToken);
    await _local.saveToken(model.toTokenModel());
    return Right(model.toEntity()); // entity 含 user，无需额外调用 getCurrentUser
  } catch (e) {
    return Left(Failure.unknown(message: e.toString()));
  }
}

// App 重启：本地有 token 但无 user 缓存，调用 GET /users/me 获取用户信息
@override
FutureEither<User> getCurrentUser() async {
  try {
    final model = await _remote.getCurrentUser();
    return Right(model.toEntity());
  } catch (e) {
    return Left(Failure.unknown(message: e.toString()));
  }
}

// isLoggedIn：读取本地 Token，判断 Refresh Token 是否有效（同步，不走网络）
@override
bool get isLoggedIn {
  final token = _local.readTokenSync();
  if (token == null) return false;
  return !token.toEntity().isRefreshTokenExpired;
}
```

---

## 六、核心基础设施

### 6.1 Auth Interceptor（Token 自动刷新）

位置：`lib/core/network/auth_interceptor.dart`

```
请求发出
    ↓
onRequest: 读取本地 Access Token，添加 Authorization: Bearer <token>
    ↓
响应返回
    ↓
onError: 是否 401？
    ├── 否 → 透传错误
    └── 是 → 调用 RefreshTokenUseCase
              ├── 成功 → 保存新 Token，重试原始请求
              └── 失败 → 清除本地 Token，发送 authStateChanged 事件（触发路由重定向）
```

**重要**：拦截器使用独立 Dio 实例调用 `/auth/refresh`，避免循环拦截。

### 6.2 Notification Service

位置：`lib/core/services/notification_service.dart`

```dart
abstract interface class NotificationService {
  /// 检查系统通知权限是否已授权
  Future<bool> isPermissionGranted();

  /// 请求通知权限，返回用户是否同意
  Future<bool> requestPermission();

  /// 跳转系统设置页（通知权限被拒绝后的引导入口）
  Future<void> openNotificationSettings();
}
```

实现使用 `permission_handler` 包（见 §九 依赖清单）。

---

## 七、Presentation 层

### 7.1 Auth State & Notifier

**`auth_state.dart`**

```dart
@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.initial()                     = AuthInitial;
  const factory AuthState.loading()                     = AuthLoading;
  const factory AuthState.authenticated(User user)      = AuthAuthenticated;
  const factory AuthState.unauthenticated()             = AuthUnauthenticated;
  const factory AuthState.error(Failure failure)        = AuthError;
}
```

**`auth_notifier.dart`**

两条进入 `authenticated` 的路径：
- **登录**：`AuthResponse` 携带 user，直接进入 `authenticated`，无额外网络请求。
- **App 重启**：本地 token 存在，调用 `GET /users/me` 取 user，再进入 `authenticated`。

```dart
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() {
    final isLoggedIn = ref.read(getAuthStatusUseCaseProvider).call();
    if (!isLoggedIn) return const AuthState.unauthenticated();
    // App 重启路径：本地有有效 token，需从后端拉取 user
    _fetchCurrentUser();
    return const AuthState.loading();
  }

  Future<void> _fetchCurrentUser() async {
    final result = await ref.read(getCurrentUserUseCaseProvider).call();
    state = result.fold(
      (failure) => const AuthState.unauthenticated(), // token 失效则登出
      (user)    => AuthState.authenticated(user),
    );
  }

  // 登录路径：AuthResponse 已含 user，直接更新 state，不发额外请求
  Future<void> loginWithEmail({required String email, required String password}) async {
    state = const AuthState.loading();
    final result = await ref.read(loginWithEmailUseCaseProvider).call(
      LoginWithEmailParams(email: email, password: password),
    );
    state = result.fold(
      (failure) => AuthState.error(failure),
      (response) => AuthState.authenticated(response.user),
    );
  }

  Future<void> loginWithGoogle() async {
    state = const AuthState.loading();
    final result = await ref.read(loginWithGoogleUseCaseProvider).call();
    state = result.fold(
      (failure) => AuthState.error(failure),
      (response) => AuthState.authenticated(response.user),
    );
  }

  Future<void> loginWithFacebook() async {
    state = const AuthState.loading();
    final result = await ref.read(loginWithFacebookUseCaseProvider).call();
    state = result.fold(
      (failure) => AuthState.error(failure),
      (response) => AuthState.authenticated(response.user),
    );
  }

  Future<void> logout() async { ... }
  void clearError() => state = const AuthState.unauthenticated();
}
```

### 7.2 Launch Notifier

**`launch_notifier.dart`**

```dart
enum LaunchDestination { permissions, home }

@riverpod
class LaunchNotifier extends _$LaunchNotifier {
  @override
  Future<LaunchDestination> build() async {
    // 保证最短展示时长 1.5s
    final results = await Future.wait([
      _checkDestination(),
      Future.delayed(const Duration(milliseconds: 1500)),
    ]);
    return results.first as LaunchDestination;
  }

  Future<LaunchDestination> _checkDestination() async {
    final isFirstLaunch = await ref.read(authLocalDatasourceProvider).isFirstLaunch();
    if (!isFirstLaunch) return LaunchDestination.home;

    final isGranted = await ref.read(notificationServiceProvider).isPermissionGranted();
    return isGranted ? LaunchDestination.home : LaunchDestination.permissions;
  }
}
```

### 7.3 页面 Widget 职责边界

| Widget | 职责 | 禁止 |
|---|---|---|
| `LaunchPage` | 展示 Logo，监听 LaunchNotifier 跳转 | 任何业务逻辑 |
| `PermissionsPage` | 展示引导 UI，调用 NotificationService，写 isFirstLaunchDone | 直接访问 Repository |
| `LoginPage` | 渲染表单，分发 AuthNotifier 事件，展示错误 | 直接调用 Dio / UseCase |
| `EmailLoginForm` | 纯表单 Widget，通过回调传递输入值 | 持有任何状态 Provider |
| `SocialLoginButton` | 纯展示 Widget，接收 onTap 回调 | — |

---

## 八、路由设计

### 8.1 路由表

```
/launch           → LaunchPage          (冷启动入口，不在 Shell 内)
/permissions      → PermissionsPage     (首次启动，不在 Shell 内)
/                 → ShellRoute (底部导航 Shell)
  /discover       → DiscoverPage
  /squads         → SquadsPage
  /post           → PostPage
  /chats          → ChatsPage
  /me             → MePage (已登录) 或 LoginPage (未登录，Shell 保持可见)
```

### 8.2 启动路由逻辑

`initialLocation` 固定指向 `/launch`。LaunchPage 完成初始化后由 `LaunchNotifier` 驱动 `context.go()` 跳转，不依赖 GoRouter `redirect`。

### 8.3 Auth Redirect 守卫

GoRouter `redirect` 仅负责运行时保护（非启动流程）：

```dart
redirect: (context, state) {
  final isLoggedIn = ref.read(authNotifierProvider) is AuthAuthenticated;
  final isAuthRoute = state.matchedLocation == '/me';

  // /me 路由：未登录不重定向，交由 LoginPage 在 /me 下原地渲染
  // 其他需要登录的操作（发帖、Squads）由各自 Feature 的 redirect 处理
  return null;
},
```

说明：Me 标签页采用"条件渲染"而非路由重定向——`/me` 路由始终可访问，但内部根据 `authNotifierProvider` 状态决定渲染 `MePage` 还是 `LoginPage`。这样底部导航栏在登录页面始终可见，符合设计稿。

---

## 九、新增依赖清单

以下包需在开发前更新 `pubspec.yaml`，并经过确认后引入：

| 包名 | 版本约束 | 用途 |
|---|---|---|
| `google_sign_in` | `^6.x` | Google OAuth |
| `flutter_facebook_auth` | `^7.x` | Facebook OAuth |
| `flutter_secure_storage` | `^9.x` | Access / Refresh Token 安全存储 |
| `shared_preferences` | `^2.x` | isFirstLaunch 标记 |
| `permission_handler` | `^11.x` | 通知权限检查 & 请求 |
| `app_settings` | `^5.x` | 跳转系统设置页（通知权限引导） |

> `riverpod_annotation` / `freezed` / `json_serializable` / `fpdart` / `dio` 项目已有，不重复引入。

---

## 十、关键流程时序

### 10.1 冷启动流程

```
main()
  └─ ProviderScope
       └─ ExplonzApp (router: initialLocation = /launch)
            └─ LaunchPage
                 ├─ 展示 Logo（UI 立即渲染）
                 ├─ LaunchNotifier.build() 后台执行：
                 │   ├─ parallel: [checkDestination(), delay(1.5s)]
                 │   └─ 取最慢完成
                 └─ 跳转 /permissions 或 /discover
```

### 10.2 Google 登录流程

```
用户点击 "Continue with Google"
  └─ AuthNotifier.loginWithGoogle()
       └─ LoginWithGoogleUseCase.call()
            └─ AuthRepositoryImpl.loginWithGoogle()
                 ├─ SocialAuthDatasource.signInWithGoogle()
                 │   └─ Google Sign-In SDK → idToken
                 ├─ AuthRemoteDatasource.loginWithGoogle(idToken)
                 │   └─ POST /auth/google → AuthResponseModel（token + user）
                 └─ AuthLocalDatasource.saveToken(model.toTokenModel())
                      └─ SecureStorage 持久化（仅 token 部分）

AuthRepositoryImpl → AuthResponse.toEntity()
AuthNotifier → AuthState.authenticated(response.user)  ← user 直接来自登录响应
             → 路由渲染 MePage（无额外 GET /users/me 请求）
```

### 10.3 Token 自动刷新流程

```
Dio 请求 → 401
  └─ AuthInterceptor.onError()
       └─ RefreshTokenUseCase.call()
            ├─ 成功：
            │   ├─ 保存新 Token
            │   └─ 重试原请求（透明）
            └─ 失败（Refresh Token 过期）：
                 ├─ AuthLocalDatasource.deleteToken()
                 └─ AuthNotifier → AuthState.unauthenticated()
                      └─ Router 自动渲染 LoginPage（/me 条件渲染）
```

---

## 十一、Providers 依赖树

```
authNotifierProvider (Notifier<AuthState>)
  ├─ loginWithEmailUseCaseProvider      → FutureEither<AuthResponse>
  ├─ loginWithGoogleUseCaseProvider     → FutureEither<AuthResponse>
  ├─ loginWithFacebookUseCaseProvider   → FutureEither<AuthResponse>
  ├─ getAuthStatusUseCaseProvider       → bool（同步，本地判断）
  ├─ getCurrentUserUseCaseProvider      → FutureEither<User>（App 重启路径）
  └─ authRepositoryProvider
       ├─ authRemoteDatasourceProvider → dioProvider
       ├─ authLocalDatasourceProvider  → flutter_secure_storage / shared_preferences
       └─ socialAuthDatasourceProvider → google_sign_in / flutter_facebook_auth

launchNotifierProvider (AsyncNotifier<LaunchDestination>)
  ├─ authLocalDatasourceProvider
  └─ notificationServiceProvider → permission_handler

appRouterProvider (Provider<GoRouter>)
  └─ authNotifierProvider
```

---

## 十二、测试计划

遵照 CLAUDE.md §十一，以下模块必须编写测试：

| 测试目标 | 测试类型 | 文件路径 |
|---|---|---|
| `LoginWithEmailUseCase` | Unit Test | `test/features/auth/domain/usecases/login_with_email_usecase_test.dart` |
| `LoginWithGoogleUseCase` | Unit Test | `test/features/auth/domain/usecases/login_with_google_usecase_test.dart` |
| `LoginWithFacebookUseCase` | Unit Test | `test/features/auth/domain/usecases/login_with_facebook_usecase_test.dart` |
| `RefreshTokenUseCase` | Unit Test | `test/features/auth/domain/usecases/refresh_token_usecase_test.dart` |
| `AuthRepositoryImpl` | Unit Test | `test/features/auth/data/repositories/auth_repository_impl_test.dart` |
| `AuthInterceptor` | Unit Test | `test/core/network/auth_interceptor_test.dart` |
| `LaunchNotifier` | Unit Test | `test/features/launch/presentation/providers/launch_notifier_test.dart` |
| `LoginPage` | Widget Test | `test/features/auth/presentation/pages/login_page_test.dart` |
| `PermissionsPage` | Widget Test | `test/features/launch/presentation/pages/permissions_page_test.dart` |

---

## 十三、待确认问题（Open Questions）

| # | 问题 | 影响 | 状态 |
|---|---|---|---|
| TQ1 | `/auth/login`、`/auth/google`、`/auth/facebook` 的请求/响应结构？ | AuthTokenModel / UserModel 字段定义 | **假定**：见 §5.0，待 Backend 确认后修改 |
| TQ2 | 账号合并（Email 与 Google/Facebook 邮箱相同）是否由后端静默处理，前端无感知？ | RepositoryImpl 不需要额外处理 | **假定**：Backend 静默处理，前端响应结构与正常登录相同，无需额外逻辑；见 §5.0 注释 |
| TQ3 | Access Token 过期时间由服务端返回（字段名？格式：ISO8601 还是 Unix timestamp？） | AuthTokenModel 解析逻辑 | **已确认**：Unix timestamp（秒），`int` 类型，转换：`DateTime.fromMillisecondsSinceEpoch(value * 1000)` |
| TQ4 | Google / Facebook iOS 配置（URL Scheme、Bundle ID）由谁提供？ | iOS 原生配置 | **假定**：占位符见 §5.0，待项目负责人替换为实际值 |
