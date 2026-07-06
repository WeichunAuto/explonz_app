import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/user.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String nickname,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    String? email,

    /// [ASSUMED] List of bound login provider strings e.g. ["email","google"].
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
