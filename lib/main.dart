import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:tourify/firebase_options.dart';

import 'package:tourify/core/notifications/notification_service.dart';
import 'package:tourify/core/theme/app_theme.dart';
import 'package:tourify/core/theme/theme_controller.dart';

import 'package:tourify/features/auth/views/login_view.dart';

import 'package:tourify/shared/cubits/favorites/favorites_cubit.dart';
import 'package:tourify/shared/cubits/wallet/wallet_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Notifications
  await NotificationService.initialize();

  // تحميل آخر Theme اختاره المستخدم
  await ThemeController.load();

  runApp(const TourifyApp());
}

class TourifyApp extends StatelessWidget {
  const TourifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<FavoritesCubit>(
          create: (_) => FavoritesCubit(),
        ),

        BlocProvider<WalletCubit>(
          create: (_) => WalletCubit()..refresh(),
        ),
      ],
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: ThemeController.mode,
        builder: (context, themeMode, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,

            // Light Theme
            theme: lightTheme,

            // Dark Theme
            darkTheme: darkTheme,

            // Theme المستخدم المحفوظ
            themeMode: themeMode,

            // نقطة بداية التطبيق
            home: const LoginView(),
          );
        },
      ),
    );
  }
}