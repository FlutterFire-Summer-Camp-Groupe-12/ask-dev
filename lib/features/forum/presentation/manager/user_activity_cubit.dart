import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user_activity.dart';
import '../../domain/usecases/get_user_activity.dart';

class UserActivityState extends Equatable {
  const UserActivityState({this.isLoading = false, this.activity, this.error});

  final bool isLoading;
  final UserActivity? activity;
  final String? error;

  @override
  List<Object?> get props => [isLoading, activity, error];
}

class UserActivityCubit extends Cubit<UserActivityState> {
  UserActivityCubit(this._getUserActivity) : super(const UserActivityState());

  final GetUserActivity _getUserActivity;

  Future<void> load(String userId) async {
    if (userId.isEmpty) return;
    emit(UserActivityState(isLoading: true, activity: state.activity));
    final result = await _getUserActivity(userId);
    if (isClosed) return;
    result.match(
      (failure) => emit(
        UserActivityState(activity: state.activity, error: failure.message),
      ),
      (activity) => emit(UserActivityState(activity: activity)),
    );
  }
}
