import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourify/core/naviagtion/navigation_service.dart';
import 'package:tourify/core/stroage/token_storage.dart';
import 'package:tourify/features/agency/home/views/active_packages_view.dart';
import 'package:tourify/features/auth/views/login_view.dart';
import 'package:tourify/features/bookings/views/my_bookings_view.dart';
import 'package:tourify/features/package/cubits/countries/countries_cubit.dart';
import 'package:tourify/firebase_options.dart';
import 'package:tourify/core/notifications/notification_service.dart';
import 'package:tourify/core/theme/app_theme.dart';
import 'package:tourify/core/theme/theme_controller.dart';
//import 'package:tourify/features/package/views/pages/create_package_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.initialize();

  await TokenStorage.saveToken(
    "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIwMWEwMWJjZS0xOWI3LTcyM2MtODI3Yy05ZjcwNjQ3MjNmM2MiLCJqdGkiOiJhN2VlODA5ZmY2MjA1NzQ2N2YzMDdkOTk4ZDVjZTk2NmVlNWRkNWNjODE2ZmIzY2JmNTEzYmJiODA3NTI2ZTU0NzFjYTZlOTVlZTFjNTFjZSIsImlhdCI6MTc4NzIwMzIwOS4xMTE0MzksIm5iZiI6MTc4NzIwMzIwOS4xMTE0NDEsImV4cCI6MTgxODczOTIwOS4xMDEyNTIsInN1YiI6IjEyIiwic2NvcGVzIjpbXX0.GGJnm4_Rbf1O_ESG9Dm2BzgXR5guKCu2-voh4w540vLQgoSdR2ois2qmScLsI5EdaTrAgcq2PpoMU_ge7U3i3Qe1IYMeC83oz606IPrlf60CUitUKRfJI_uj2Wndoedx1X9GWQYTrPRA9l4OZ5mJqpAWKO5z0fEMZusxkYcD2IlNph1vzSDhtZVjYWRkeiY_PmZG_q9kYC95tbCY9bUtORAZ9aZwZ2nfgNe4XF7QdCIhFNEvxhHmd_MT1kN0NKdBi4djVUHG15EeJRXI5XPOg07VrhdhqclkRhT_uFp9tzqOrGYjSTxuqumHeWqR2hhZzN9mdlBVZzqpmN65Ja3MyrLwIlK-h-IJPZfcQiQgJBpSjyHzgIsksbhKvOAoU6JieCVfyPt22xea-RZ2NmnLaW2rh5n-Ii5f1nFYdLwZ3YyByR3sB6eEciSlzTD5Qcl8NaWwQEQ1arr0A3HZrWQfavg_3Sv3PhE3TPF_PIsrlOGzQZXXeS_l1_o6g4XjTvUIke0c2I7xFhFvm1HK6hjWq9qQ4xXNvLQWYYe_gfWg9pFT2OfGjxGHuszQvhSj5H6QPK57nB1kV92oHY_pnAICL1MRVvSGne6WXTSEgGtE9jI3oHPh3E-RIYTVtqdJlWtCT6QjdAAu9msydSdLltz5PkxyW09MMj6cXqwz3JHSO6M",
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.mode,
      builder: (context, themeMode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,

          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: ThemeMode.dark,

          home: const MyBookingsView(),
        );
      },
    );
  }
}
