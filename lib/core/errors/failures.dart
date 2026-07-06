import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

@freezed
sealed class Failure with _$Failure {
  const factory Failure.network({required String message, int? statusCode}) =
      NetworkFailure;

  const factory Failure.server({required String message, int? statusCode}) =
      ServerFailure;

  const factory Failure.cache({required String message}) = CacheFailure;

  const factory Failure.unauthorized({
    @Default('Unauthorized') String message,
  }) = UnauthorizedFailure;

  const factory Failure.unknown({
    @Default('An unknown error occurred') String message,
  }) = UnknownFailure;

  const factory Failure.cancelled() = CancelledFailure;
}
