import 'package:freezed_annotation/freezed_annotation.dart';

part 'errors.freezed.dart';

@freezed
abstract class NError with _$NError {
  const factory NError({Object? error, String? message}) = _NError;
}
