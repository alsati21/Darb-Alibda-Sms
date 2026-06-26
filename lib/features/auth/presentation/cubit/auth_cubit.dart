import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/auth_repository.dart';
import '../../../../core/storage/token_storage.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._authRepository) : super(const AuthInitial());

  final AuthRepository _authRepository;
  String? _sessionToken;
  final TokenStorage _tokenStorage = TokenStorage();

  String? get sessionToken => _sessionToken;

  Future<void> login({
    required String phone,
    required String password,
  }) async {
    emit(const AuthLoading());

    try {
      final response = await _authRepository.login(
        phone: phone,
        password: password,
      );
      _sessionToken = _extractToken(response);
      if (_sessionToken != null) {
        await _tokenStorage.saveToken(_sessionToken!);
      }
      emit(AuthSuccess(payload: response));
    } catch (error) {
      emit(AuthFailure(_readErrorMessage(error)));
    }
  }

  Future<void> logout() async {
    emit(const AuthLoading());

    try {
      final token = _sessionToken;
      if (token != null && token.isNotEmpty) {
        await _authRepository.logout(token);
      }
      _sessionToken = null;
      await _tokenStorage.deleteToken();
      emit(const AuthInitial());
    } catch (error) {
      emit(AuthFailure(_readErrorMessage(error)));
    }
  }

  /// Try to restore a previously saved session token and validate it by
  /// fetching the current user's profile. If successful, emits [AuthSuccess].
  /// Otherwise clears the stored token and remains at [AuthInitial].
  Future<void> tryRestoreSession() async {
    emit(const AuthLoading());

    try {
      final stored = await _tokenStorage.readToken();
      if (stored == null || stored.isEmpty) {
        emit(const AuthInitial());
        return;
      }

      _sessionToken = stored;
      final profile = await _authRepository.fetchProfile(_sessionToken!);
      emit(AuthSuccess(payload: profile));
    } catch (error) {
      _sessionToken = null;
      await _tokenStorage.deleteToken();
      emit(const AuthInitial());
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data, {String? avatarPath}) async {
    emit(const AuthLoading());
    try {
      final token = _sessionToken;
      if (token == null || token.isEmpty) throw Exception('غير مسجل - لا يوجد توكن');
      final response = await _authRepository.updateProfile(token, data, avatarPath: avatarPath);
      // update local session payload if response contains updated user
      emit(AuthSuccess(payload: response));
    } catch (error) {
      // handle API validation errors separately to allow UI to show inline messages
      if (error is ApiValidationException) {
        emit(AuthValidationFailure(error.errors));
        return;
      }

      emit(AuthFailure(_readErrorMessage(error)));
    }
  }

  Future<void> forgotPassword(String identifier) async {
    emit(const AuthLoading());
    try {
      final response = await _authRepository.forgotPassword(identifier);
      emit(AuthSuccess(payload: response));
    } catch (error) {
      emit(AuthFailure(_readErrorMessage(error)));
    }
  }

  String _readErrorMessage(Object error) {
    final message = error.toString();
    if (message.startsWith('Exception: ')) {
      return message.replaceFirst('Exception: ', '');
    }
    return message;
  }

  String? _extractToken(Map<String, dynamic> payload) {
    final directToken = payload['token'];
    if (directToken is String && directToken.isNotEmpty) {
      return directToken;
    }

    final accessToken = payload['access_token'];
    if (accessToken is String && accessToken.isNotEmpty) {
      return accessToken;
    }

    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      final nestedToken = data['token'];
      if (nestedToken is String && nestedToken.isNotEmpty) {
        return nestedToken;
      }

      final nestedAccessToken = data['access_token'];
      if (nestedAccessToken is String && nestedAccessToken.isNotEmpty) {
        return nestedAccessToken;
      }
    }

    return null;
  }
}