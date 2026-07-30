import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/navigation/app_router.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/data/repositories/support_repository.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/cubit/auth_state.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/absence_requests/data/repositories/absence_requests_repository.dart';
import 'features/absence_requests/presentation/cubit/absence_requests_cubit.dart';
import 'features/attendance/data/repositories/attendance_repository.dart';
import 'features/attendance/presentation/cubit/attendance_cubit.dart';
import 'features/classes/presentation/cubit/classes_cubit.dart';
import 'features/classes/data/repositories/classes_repository.dart';
import 'features/dashboard/data/repositories/dashboard_repository.dart';
import 'features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'features/grades/data/repositories/grades_repository.dart';
import 'features/grades/presentation/cubit/grades_cubit.dart';
import 'features/news/data/repositories/news_repository.dart';
import 'features/news/presentation/cubit/news_cubit.dart';
import 'features/notes/data/repositories/parent_notes_repository.dart';
import 'features/notes/presentation/cubit/notes_cubit.dart';
import 'features/profile/presentation/cubit/profile_cubit.dart';
import 'features/teacher_feedback/data/repositories/teacher_feedback_repository.dart';
import 'features/teacher_feedback/presentation/cubit/teacher_feedback_cubit.dart';
import 'features/teacher_complaints/data/repositories/teacher_complaints_repository.dart';
import 'features/teacher_complaints/presentation/cubit/teacher_complaints_cubit.dart';
import 'features/teacher_notifications/data/repositories/teacher_notifications_repository.dart';
import 'features/teacher_notifications/presentation/cubit/teacher_notifications_cubit.dart';
import 'features/schedule/data/repositories/schedule_repository.dart';
import 'features/schedule/presentation/cubit/schedule_cubit.dart';
import 'shared/theme/app_theme.dart';

void main() {

  runZonedGuarded(
    () {
      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        debugPrint('FlutterError: ${details.exceptionAsString()}');
        debugPrint('${details.stack}');
      };

      PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
        debugPrint('PlatformDispatcher error: $error');
        debugPrint('$stack');

        return true;
      };

      runApp(const SchoolTeacherApp());
    },
    (Object error, StackTrace stack) {

      debugPrint('Uncaught zone error: $error');
      debugPrint('$stack');

    },
  );
}

class SchoolTeacherApp extends StatelessWidget {
  const SchoolTeacherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(create: (_) => AuthRepository()),
        RepositoryProvider<SupportRepository>(
          create: (_) => SupportRepository(),
        ),
        RepositoryProvider<DashboardRepository>(
          create: (_) => DashboardRepository(),
        ),
        RepositoryProvider<AttendanceRepository>(
          create: (_) => AttendanceRepository(),
        ),
        RepositoryProvider<NewsRepository>(create: (_) => NewsRepository()),
        RepositoryProvider<ClassesRepository>(
          create: (_) => ClassesRepository(),
        ),
        RepositoryProvider<ScheduleRepository>(
          create: (_) => ScheduleRepository(),
        ),
        RepositoryProvider<AbsenceRequestsRepository>(
          create: (_) => AbsenceRequestsRepository(),
        ),
        RepositoryProvider<GradesRepository>(create: (_) => GradesRepository()),
        RepositoryProvider<ParentNotesRepository>(
          create: (_) => ParentNotesRepository(),
        ),
        RepositoryProvider<TeacherFeedbackRepository>(
          create: (_) => TeacherFeedbackRepository(),
        ),
        RepositoryProvider<TeacherComplaintsRepository>(
          create: (_) => TeacherComplaintsRepository(),
        ),
        RepositoryProvider<TeacherNotificationsRepository>(
          create: (_) => TeacherNotificationsRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (context) => AuthCubit(
              context.read<AuthRepository>(),
              supportRepository: context.read<SupportRepository>(),
            )..tryRestoreSession(),
          ),
          BlocProvider<NewsCubit>(
            create: (context) => NewsCubit(context.read<NewsRepository>()),
          ),
          BlocProvider<DashboardCubit>(
            create: (context) =>
                DashboardCubit(context.read<DashboardRepository>()),
          ),
          BlocProvider<AttendanceCubit>(
            create: (context) =>
                AttendanceCubit(context.read<AttendanceRepository>()),
          ),
          BlocProvider<ScheduleCubit>(
            create: (context) =>
                ScheduleCubit(context.read<ScheduleRepository>()),
          ),
          BlocProvider<AbsenceRequestsCubit>(
            create: (context) =>
                AbsenceRequestsCubit(context.read<AbsenceRequestsRepository>()),
          ),
          BlocProvider<ProfileCubit>(
            create: (context) => ProfileCubit(context.read<AuthRepository>()),
          ),
          BlocProvider<GradesCubit>(
            create: (context) => GradesCubit(context.read<GradesRepository>()),
          ),
          BlocProvider<NotesCubit>(
            create: (context) => NotesCubit(
              context.read<ParentNotesRepository>(),
              context.read<AuthCubit>(),
            ),
          ),
          BlocProvider<ClassesCubit>(
            create: (context) =>
                ClassesCubit(context.read<ClassesRepository>()),
          ),
          BlocProvider<TeacherFeedbackCubit>(
            create: (context) =>
                TeacherFeedbackCubit(context.read<TeacherFeedbackRepository>()),
          ),
          BlocProvider<TeacherComplaintsCubit>(
            create: (context) => TeacherComplaintsCubit(
              context.read<TeacherComplaintsRepository>(),
            ),
          ),
          BlocProvider<TeacherNotificationsCubit>(
            create: (context) => TeacherNotificationsCubit(
              context.read<TeacherNotificationsRepository>(),
            ),
          ),
        ],
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            Widget home;
            if (state is AuthLoading) {
              home = const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            } else if (state is AuthSuccess) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final token = context.read<AuthCubit>().sessionToken;
                if (token != null && token.isNotEmpty) {
                  context.read<TeacherNotificationsCubit>().loadNotifications(
                    token,
                  );
                }
              });
              home = const DashboardPage();
            } else {
              home = const LoginPage();
            }

            return MaterialApp(
              title: 'نظام إدارة المدرسة',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [Locale('ar', '')],
              locale: const Locale('ar', ''),
              home: home,
              onGenerateRoute: AppRouter.generateRoute,
            );
          },
        ),
      ),
    );
  }
}
