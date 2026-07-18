# Logout 技术方案

## 一、现状分析

### 已有实现

| 层 | 文件 | 现状 |
|---|---|---|
| Notifier | `auth_notifier.dart:84` | `logout()` 已实现：调用 repo.logout() → state = AuthUnauthenticated |
| Repository | `auth_repository_impl.dart:117` | `logout()` 已实现：仅删除本地 token |
| Router | `app_router.dart:147` | `_MeRoute` 已响应式处理：AuthAuthenticated → MePage，其他 → LoginPage |
| UI | `me_page.dart:17` | 占位按钮已调用 `authProvider.notifier.logout()` |

### 现有流程

```
MePage 按钮 onPressed
  → ref.read(authProvider.notifier).logout()
  → AuthRepositoryImpl.logout()
      → authLocalDatasource.deleteToken()   ← 清除本地 token
  → state = AuthUnauthenticated
  → _MeRoute rebuild → 渲染 LoginPage       ← UI 自动切换，无需手动 navigate
```

### 缺口

1. **无服务端 logout 调用**：后端 token 未被吊销，refresh_token 在过期前仍有效。
2. **`AuthRemoteDatasource` 无 `logout()` 接口**。
3. **其他 Feature 的缓存状态未清除**（如有用户相关 Provider 缓存数据，logout 后可能残留）。

---

## 二、需要修改的文件

```
lib/features/auth/data/datasources/auth_remote_datasource.dart   ← 新增 logout()
lib/features/auth/domain/repositories/auth_repository.dart       ← 无需改动（接口已有 logout）
lib/features/auth/data/repositories/auth_repository_impl.dart    ← 补充 remote.logout() 调用
```

> `AuthNotifier`、`MePage`、Router 均无需修改。

---

## 三、具体实现方案

### Step 1：AuthRemoteDatasource 新增 logout()

`auth_remote_datasource.dart` 抽象接口增加：

```dart
Future<void> logout();
```

`AuthRemoteDatasourceImpl` 实现：

```dart
@override
Future<void> logout() async {
  try {
    await _dio.post<void>('/auth/logout');
  } on DioException catch (e) {
    throw _mapDioException(e);
  }
}
```

> 若后端 logout 接口不存在或不需要调用，此步骤跳过，仅做本地清除即可。

### Step 2：AuthRepositoryImpl.logout() 补充远端调用

```dart
@override
FutureEitherVoid logout() async {
  try {
    await _remote.logout();          // 先吊销服务端 token
    await _local.deleteToken();      // 再清除本地 token
    return const Right(unit);
  } on Failure catch (f) {
    // 即使服务端调用失败，也执行本地清除，保证本地登出
    await _local.deleteToken();
    return Left(f);
  } catch (e) {
    await _local.deleteToken();
    return Left(Failure.unknown(message: e.toString()));
  }
}
```

> 关键原则：服务端调用失败不阻塞本地登出。

### Step 3：（可选）清除其他 Feature 缓存

若其他 Feature 有 keepAlive 的 Provider 缓存了用户数据，在 `AuthNotifier.logout()` 中用 `ref.invalidate()` 清除：

```dart
Future<void> logout() async {
  await ref.read(authRepositoryProvider).logout();
  // ref.invalidate(someUserDataProvider);  // 按需添加
  state = const AuthState.unauthenticated();
}
```

---

## 四、导航行为说明

无需手动 `context.go()`，原因：

`_MeRoute`（`app_router.dart:147`）已响应式监听 `authProvider`：

```dart
return switch (authState) {
  AuthAuthenticated() => const MePage(),
  _                   => const LoginPage(),   // logout 后自动渲染 LoginPage
};
```

logout → state 变为 `AuthUnauthenticated` → `_MeRoute` rebuild → 自动展示 `LoginPage`。

其余 Tab（Discover / Squads / Chats 等）为公开内容页，logout 不影响其展示，无需处理。

---

## 五、待确认事项

- [ ] 后端是否有 `/auth/logout` 接口？需要传 refresh_token 还是依赖请求头 Authorization？
- [ ] logout 后其他 Tab 是否需要重置到初始状态（如 Chats 列表清空）？

---

## 六、改动范围总结

| 文件 | 改动 |
|---|---|
| `auth_remote_datasource.dart` | 新增 `logout()` 方法（接口 + 实现） |
| `auth_repository_impl.dart` | `logout()` 补充 `_remote.logout()` 调用，失败时仍保证本地清除 |
| 其他文件 | 不改动 |
