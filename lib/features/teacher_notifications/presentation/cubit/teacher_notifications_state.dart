import '../../data/models/teacher_notification_item.dart';

class TeacherNotificationsState {
  const TeacherNotificationsState({
    required this.isLoading,
    required this.isMarkingAllRead,
    required this.isRefreshing,
    required this.notifications,
    required this.unreadNotifications,
    required this.readNotifications,
    required this.unreadCount,
    required this.readCount,
    required this.selectedTab,
    required this.errorMessage,
    required this.successMessage,
    required this.lastDeletedNotificationId,
  });

  factory TeacherNotificationsState.initial() {
    return const TeacherNotificationsState(
      isLoading: false,
      isMarkingAllRead: false,
      isRefreshing: false,
      notifications: <TeacherNotificationItem>[],
      unreadNotifications: <TeacherNotificationItem>[],
      readNotifications: <TeacherNotificationItem>[],
      unreadCount: 0,
      readCount: 0,
      selectedTab: 0,
      errorMessage: null,
      successMessage: null,
      lastDeletedNotificationId: null,
    );
  }

  final bool isLoading;
  final bool isMarkingAllRead;
  final bool isRefreshing;
  final List<TeacherNotificationItem> notifications;
  final List<TeacherNotificationItem> unreadNotifications;
  final List<TeacherNotificationItem> readNotifications;
  final int unreadCount;
  final int readCount;
  final int selectedTab;
  final String? errorMessage;
  final String? successMessage;
  final String? lastDeletedNotificationId;

  TeacherNotificationsState copyWith({
    bool? isLoading,
    bool? isMarkingAllRead,
    bool? isRefreshing,
    List<TeacherNotificationItem>? notifications,
    List<TeacherNotificationItem>? unreadNotifications,
    List<TeacherNotificationItem>? readNotifications,
    int? unreadCount,
    int? readCount,
    int? selectedTab,
    String? errorMessage,
    String? successMessage,
    String? lastDeletedNotificationId,
    bool clearErrorMessage = false,
    bool clearSuccessMessage = false,
    bool clearDeletedNotificationId = false,
  }) {
    return TeacherNotificationsState(
      isLoading: isLoading ?? this.isLoading,
      isMarkingAllRead: isMarkingAllRead ?? this.isMarkingAllRead,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      notifications: notifications ?? this.notifications,
      unreadNotifications: unreadNotifications ?? this.unreadNotifications,
      readNotifications: readNotifications ?? this.readNotifications,
      unreadCount: unreadCount ?? this.unreadCount,
      readCount: readCount ?? this.readCount,
      selectedTab: selectedTab ?? this.selectedTab,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccessMessage ? null : (successMessage ?? this.successMessage),
      lastDeletedNotificationId: clearDeletedNotificationId ? null : (lastDeletedNotificationId ?? this.lastDeletedNotificationId),
    );
  }
}
