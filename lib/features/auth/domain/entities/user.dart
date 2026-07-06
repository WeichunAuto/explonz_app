import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

enum AuthProvider { email, google, facebook }

@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    required String nickname,
    String? avatarUrl,
    String? email,
    @Default([]) List<AuthProvider> providers,
  }) = _User;
}
