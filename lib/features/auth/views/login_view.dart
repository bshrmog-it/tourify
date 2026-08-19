import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourify/features/agency/create_package/views/pages/add_package_view.dart';
import 'package:tourify/features/agency/home/views/active_packages_view.dart';
import 'package:tourify/features/agency/home/views/agency_main_layout_view.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import 'signup_view.dart';
// TODO: Replace this with the real home view for each role
// import '../../home/views/user_home_view.dart';
// import '../../agency/views/agency_home_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final username = TextEditingController();
  final password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthCubit(),
      child: Scaffold(
        body: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }

            if (state is AuthSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Welcome ${state.user.fullName}")),
              );

              Future.delayed(const Duration(milliseconds: 300), () {
                if (!context.mounted) return;
                if (state.role == 'agency') {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => AgencyMainLayoutView(),
                    ),
                  );
                } else {
                  // TODO: Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const UserHomeView()));
                }
              });
            }
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    const SizedBox(height: 60),
                    const Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Log in and discover what's new",
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 30),

                    TextFormField(
                      controller: username,
                      decoration: const InputDecoration(labelText: "Username"),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return "Username is required";
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: password,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: "Password"),
                      validator: (v) {
                        if (v == null || v.isEmpty)
                          return "Password is required";
                        if (v.length < 6)
                          return "Password must be at least 6 characters";
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),

                    state is AuthLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: () {
                              if (!_formKey.currentState!.validate()) return;

                              context.read<AuthCubit>().login(
                                username: username.text.trim(),
                                password: password.text,
                              );
                            },
                            child: const Text("Login"),
                          ),

                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account? "),
                        InkWell(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SignupView(),
                              ),
                            );
                          },
                          child: const Text(
                            "Create Account",
                            style: TextStyle(
                              color: Colors.yellow,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
