import 'package:flutter/material.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/classes/presentation/pages/classes_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/schedule/presentation/pages/schedule_page.dart';
import '../../features/attendance/presentation/pages/attendance_page.dart';
import '../../features/student_profile/presentation/pages/student_profile_page.dart';
import '../../features/absence_requests/presentation/pages/absence_requests_page.dart';
import '../../features/grades/presentation/pages/grades_page.dart';
import '../../features/notes/presentation/pages/notes_page.dart';
import '../../features/news/presentation/pages/news_page.dart';
import '../../features/teacher_feedback/presentation/pages/teacher_feedback_page.dart';
import '../../features/teacher_complaints/presentation/pages/teacher_complaints_page.dart';
import '../../features/teacher_notifications/presentation/pages/teacher_notifications_page.dart';
import '../../features/profile/presentation/pages/teacher_profile_page.dart';
import 'route_names.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case RouteNames.dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardPage());
      case RouteNames.classes:
        return MaterialPageRoute(builder: (_) => const ClassesPage());
      case RouteNames.schedule:
        return MaterialPageRoute(builder: (_) => const SchedulePage());
      case RouteNames.attendance:
        return MaterialPageRoute(builder: (_) => const AttendancePage());
      case RouteNames.studentProfile:
        return MaterialPageRoute(builder: (_) => const StudentProfilePage());
      case RouteNames.absenceRequests:
        return MaterialPageRoute(builder: (_) => const AbsenceRequestsPage());
      case RouteNames.grades:
        return MaterialPageRoute(builder: (_) => const GradesPage());
      case RouteNames.notes:
        return MaterialPageRoute(builder: (_) => const NotesPage());
      case RouteNames.news:
        return MaterialPageRoute(builder: (_) => const NewsPage());
      case RouteNames.feedback:
        return MaterialPageRoute(builder: (_) => const TeacherFeedbackPage());
      case RouteNames.complaints:
        return MaterialPageRoute(builder: (_) => const TeacherComplaintsPage());
      case RouteNames.notifications:
        return MaterialPageRoute(builder: (_) => const TeacherNotificationsPage());
      case RouteNames.profile:
        return MaterialPageRoute(builder: (_) => const TeacherProfilePage());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('الصفحة غير موجودة'),
            ),
          ),
        );
    }
  }
}
