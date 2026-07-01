import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/data/repositories/auth_repository.dart';

import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._authRepository) : super(ProfileState.initial());

  final AuthRepository _authRepository;
  String? _token;

  Future<void> loadProfile(String? token) async {
    if (token == null || token.isEmpty) {
      emit(state.copyWith(isLoading: false, errorMessage: 'لم يتم العثور على جلسة نشطة'));
      return;
    }

    _token = token;
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final profile = await _authRepository.fetchProfile(token);
      final data = profile['data'] is Map<String, dynamic> ? profile['data'] as Map<String, dynamic> : <String, dynamic>{};
      emit(state.copyWith(isLoading: false, profileData: data));
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: error.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<bool> saveProfile(Map<String, dynamic> updates, {String? avatarPath}) async {
    final token = _token;
    if (token == null || token.isEmpty) {
      emit(state.copyWith(errorMessage: 'لم يتم العثور على جلسة نشطة'));
      return false;
    }

    emit(state.copyWith(isSaving: true, errorMessage: null));

    try {
      final response = await _authRepository.updateProfile(token, updates, avatarPath: avatarPath);
      final data = response['data'] is Map<String, dynamic> ? response['data'] as Map<String, dynamic> : <String, dynamic>{};
      emit(state.copyWith(isSaving: false, profileData: data));
      return true;
    } catch (error) {
      emit(state.copyWith(isSaving: false, errorMessage: error.toString().replaceFirst('Exception: ', '')));
      return false;
    }
  }
}
