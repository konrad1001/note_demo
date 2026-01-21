import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_state.g.dart';
part 'user_state.freezed.dart';

@freezed
abstract class UserState with _$UserState {
  const factory UserState({@Default({}) Map<String, int> insightRatings}) =
      _UserState;

  factory UserState.fromJson(Map<String, dynamic> json) =>
      _$UserStateFromJson(json);
}

class UserStateNotifier extends Notifier<UserState> {
  @override
  UserState build() {
    return UserState();
  }
}
