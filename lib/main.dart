import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourify/core/stroage/token_storage.dart';
import 'package:tourify/features/package/cubits/countries/countries_cubit.dart';
//import 'package:tourify/features/package/views/pages/create_package_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await TokenStorage.saveToken(
    "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIwMTlmYmFiNi0yZWQ2LTczYjYtYjRjMy05ZjNkZjRjZjAzY2YiLCJqdGkiOiJmNjM5YmM3Y2U3M2ZhODlmMzI5ODZkY2IzMWNjYjJlZDFiZTZmNTFiNjFlNjEyMzU3NWRmMzk1M2FlN2RjZjczZTc5MzYxOWYwMTAzY2QzMCIsImlhdCI6MTc4NTY5NTA0NS4wMTUyMjIsIm5iZiI6MTc4NTY5NTA0NS4wMTUyMjQsImV4cCI6MTgxNzIzMTA0NC4xMjU0ODUsInN1YiI6IjIiLCJzY29wZXMiOltdfQ.f2WvTA-Mv0jy3Glq3lHDPpN9Buzfd7RmFINeLzNj6qSowy-VvHxxyO8oBgXCVb7mJB7-08pZjka2t6iM8XNhOjl8hbSwqymEZda4jZNI8kJIhUQvLZIO2ADx_qFQBgng5lPzI4oFXl-BvqQdcLADEZFO7ncYv9ecUsMb865gq8PsTTveuLh2dLGB4gyBr9-J3ltS328ieTFNMBRfc7OJjKwokaTRvAGTDDKltZk4Fw5nRWh1GRBUWSz_qZ2ywDnaoz7xvPbc-A-w4AxA6XdWR-veHipY-2-Df4-WkNCWeoP1QVhhEmmasumrl0widHSnzHQqruFvMzWoqg5IdGgfY7t-zIglyUUT3yOW30SZurDDhtxbQ1etwlIEmT3Qq9UOnDAyQ8Jxtg-PrY3Uk6W3q8W6e40chd0qwURaT7xHeqkf7o0CLMvmCPDopQddyb2qTOOA89MiKT5VyqaJfvho6eZLDQ5Fjiz-44_WyZxa_Yph-FseuwDHjLV9l9Ci7RATenwlSwcWGBaBwDUsQzbShifrFx6u3OMXH4QY9MUrcTXROQJUoqqQYue1BVWlZy2IY60j2IbmXXAH8R_cNwkoZ8fP2O3k2M4TG8vay2MMgFRbDp61VfruYKwdU8SJ0EnVqAGHjSLhspwkvPIsoRU8rtcDiUnexPIVPNe7I1N4aj8",
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (_) => CountriesCubit())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        //home: const CreatePackagePage(),
      ),
    );
  }
}
