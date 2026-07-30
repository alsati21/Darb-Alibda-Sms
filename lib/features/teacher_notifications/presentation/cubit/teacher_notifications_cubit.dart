import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/teacher_notification_item.dart';
import '../../data/repositories/teacher_notifications_repository.dart';
import 'teacher_notifications_state.dart';

class TeacherNotificationsCubit extends Cubit<TeacherNotificationsState> {
  TeacherNotificationsCubit(this._repository) : super(TeacherNotificationsState.initial());

  final TeacherNotificationsRepository _repository;
  String? _token;

  Future<void> loadNotifications(String? token) async {
    if (token == null || token.isEmpty) {
      emit(state.copyWith(isLoading: false, errorMessage: 'لم يتم العثور على جلسة نشطة'));
      return;
    }

    _token = token;
    emit(state.copyWith(isLoading: true, errorMessage: null, successMessage: null));

    try {
      final summary = await _repository.fetchNotifications(token);
      final notifications = [...summary.unread, ...summary.read];
      emit(state.copyWith(
        isLoading: false,
        notifications: notifications,
        unreadNotifications: summary.unread,
        readNotifications: summary.read,
        unreadCount: summary.unreadCount,
        readCount: summary.readCount,
        clearErrorMessage: true,
      ));
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: _readErrorMessage(error)));
    }
  }

  void setSelectedTab(int tab) {
    emit(state.copyWith(selectedTab: tab));
  }

  Future<void> markAsRead(String notificationId) async {
    final token = _token;
    if (token == null || token.isEmpty) return;

    try {
      await _repository.markAsRead(token, notificationId);
      final movedItem = state.notifications.firstWhere((item) => item.id == notificationId);
      final updatedItem = movedItem.copyWith(isRead: true);
      final unread = state.unreadNotifications.where((item) => item.id != notificationId).toList();
      final read = [updatedItem, ...state.readNotifications.where((item) => item.id != notificationId)].toList();
      final remainingNotifications = [
        ...state.notifications.where((item) => item.id != notificationId),
        updatedItem,
      ];

      emit(state.copyWith(
        notifications: remainingNotifications,
        unreadNotifications: unread,
        readNotifications: read,
        unreadCount: unread.length,
        readCount: read.length,
        successMessage: 'تم تعليم الإشعار كمقروء بنجاح.',
        clearErrorMessage: true,
      ));
    } catch (error) {
      emit(state.copyWith(errorMessage: _readErrorMessage(error)));
    }
  }

  Future<void> markAllAsRead() async {
    final token = _token;
    if (token == null || token.isEmpty) return;

    emit(state.copyWith(isMarkingAllRead: true, errorMessage: null, successMessage: null));

    try {
      final markedCount = await _repository.markAllAsRead(token);
      final updatedUnread = state.unreadNotifications.map((item) => item.copyWith(isRead: true)).toList();
      final updatedRead = [
        ...updatedUnread,
        ...state.readNotifications,
      ];

      emit(state.copyWith(
        isMarkingAllRead: false,
        notifications: updatedRead,
        unreadNotifications: const [],
        readNotifications: updatedRead,
        unreadCount: 0,
        readCount: updatedRead.length,
        successMessage: markedCount > 0 ? 'تم تعليم جميع الإشعارات غير المقروءة كمقروءة.' : 'لا توجد إشعارات غير مقروءة.',
        clearErrorMessage: true,
      ));
    } catch (error) {
      emit(state.copyWith(isMarkingAllRead: false, errorMessage: _readErrorMessage(error)));
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    final token = _token;
    if (token == null || token.isEmpty) return;

    try {
      await _repository.deleteNotification(token, notificationId);
      final notifications = state.notifications.where((item) => item.id != notificationId).toList();
      final unread = state.unreadNotifications.where((item) => item.id != notificationId).toList();
      final read = state.readNotifications.where((item) => item.id != notificationId).toList();
      emit(state.copyWith(
        notifications: notifications,
        unreadNotifications: unread,
        readNotifications: read,
        unreadCount: unread.length,
        readCount: read.length,
        lastDeletedNotificationId: notificationId,
        successMessage: 'تم حذف الإشعار بنجاح.',
        clearErrorMessage: true,
      ));
    } catch (error) {
      emit(state.copyWith(errorMessage: _readErrorMessage(error)));
    }
  }

  void clearTransientMessages() {
    emit(state.copyWith(clearErrorMessage: true, clearSuccessMessage: true, clearDeletedNotificationId: true));
  }

  String _readErrorMessage(Object error) {
    final message = error.toString();
    if (message.startsWith('Exception: ')) {
      return message.replaceFirst('Exception: ', '');
    }
    return message;
  }
}
