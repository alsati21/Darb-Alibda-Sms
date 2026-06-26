import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/navigation/app_router.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/cubit/auth_state.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/dashboard/data/repositories/dashboard_repository.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'features/news/data/repositories/news_repository.dart';
import 'features/news/presentation/cubit/news_cubit.dart';
import 'shared/theme/app_theme.dart';

void main() {
  runApp(const SchoolTeacherApp());
}

class SchoolTeacherApp extends StatelessWidget {
  const SchoolTeacherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(create: (_) => AuthRepository()),
        RepositoryProvider<DashboardRepository>(create: (_) => DashboardRepository()),
        RepositoryProvider<NewsRepository>(create: (_) => NewsRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (context) => AuthCubit(context.read<AuthRepository>())..tryRestoreSession(),
          ),
          BlocProvider<NewsCubit>(
            create: (context) => NewsCubit(context.read<NewsRepository>()),
          ),
        ],
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            Widget home;
            if (state is AuthLoading) {
              home = const Scaffold(body: Center(child: CircularProgressIndicator()));
            } else if (state is AuthSuccess) {
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
