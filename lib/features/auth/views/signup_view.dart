import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../models/register_model.dart';
import 'login_view.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final usernameController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final passwordController = TextEditingController();

  final agencyNameController = TextEditingController();
  final agencyDescriptionController = TextEditingController();
  final agencyLandlineController = TextEditingController();
  final agencyAddressController = TextEditingController();

  String role = 'user';
  DateTime? selectedDate;

  File? profileImage;
  File? idCardImage;
  File? agencyImage;

  final ImagePicker picker = ImagePicker();

  final _emailRegex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,}$');
  final _phoneRegex = RegExp(
    r'^09\d{8}$',
  ); // Adjust this according to the format accepted by your backend

  Future<void> pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (date != null) setState(() => selectedDate = date);
  }

  Future<void> pickImage(void Function(File) onPicked) async {
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image != null) setState(() => onPicked(File(image.path)));
  }

  String? get formattedDate {
    if (selectedDate == null) return null;
    return "${selectedDate!.year.toString().padLeft(4, '0')}-"
        "${selectedDate!.month.toString().padLeft(2, '0')}-"
        "${selectedDate!.day.toString().padLeft(2, '0')}";
  }

  String? _required(String? v, [String label = "This field"]) {
    if (v == null || v.trim().isEmpty) return "$label is required";
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthCubit(),
      child: Scaffold(
        body: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Account created successfully'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginView()),
              );
            }

            if (state is AuthRegisterPendingApproval) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.orange,
                ),
              );
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginView()),
              );
            }

            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    const SizedBox(height: 40),
                    const Text(
                      "Create Account",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    DropdownButtonFormField<String>(
                      value: role,
                      items: const [
                        DropdownMenuItem(
                          value: 'user',
                          child: Text('User / Tourist'),
                        ),
                        DropdownMenuItem(
                          value: 'agency',
                          child: Text('Travel Agency'),
                        ),
                      ],
                      onChanged: (val) => setState(() => role = val!),
                      decoration: const InputDecoration(
                        labelText: "Account Type",
                      ),
                    ),
                    const SizedBox(height: 15),

                    TextFormField(
                      controller: usernameController,
                      decoration: const InputDecoration(labelText: "Username"),
                      validator: (v) => _required(v, "Username"),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: "Email"),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return "Email is required";
                        if (!_emailRegex.hasMatch(v.trim()))
                          return "Invalid email format";
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: "Phone Number",
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return "Phone number is required";
                        if (!_phoneRegex.hasMatch(v.trim()))
                          return "Invalid phone number";
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: firstNameController,
                            decoration: const InputDecoration(
                              labelText: "First Name",
                            ),
                            validator: (v) => _required(v, "First Name"),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: lastNameController,
                            decoration: const InputDecoration(
                              labelText: "Last Name",
                            ),
                            validator: (v) => _required(v, "Last Name"),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: passwordController,
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
                    const SizedBox(height: 15),

                    FormField<DateTime>(
                      validator: (_) => selectedDate == null
                          ? "Date of birth is required"
                          : null,
                      builder: (state) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () async {
                              await pickDate();
                              state.didChange(selectedDate);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 205, 205, 203),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Text(
                                selectedDate == null
                                    ? "Select your date of birth"
                                    : formattedDate!,
                              ),
                            ),
                          ),
                          if (state.hasError)
                            Padding(
                              padding: const EdgeInsets.only(top: 6, right: 12),
                              child: Text(
                                state.errorText!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () => pickImage((f) => profileImage = f),
                          child: const Text("Profile Picture"),
                        ),
                        const SizedBox(width: 10),
                        if (profileImage != null)
                          const Icon(Icons.check, color: Colors.green),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () => pickImage((f) => idCardImage = f),
                          child: const Text("ID Card Picture"),
                        ),
                        const SizedBox(width: 10),
                        if (idCardImage != null)
                          const Icon(Icons.check, color: Colors.green),
                      ],
                    ),

                    if (role == 'agency') ...[
                      const SizedBox(height: 25),
                      const Divider(),
                      const Text(
                        "Travel Agency Information",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: agencyNameController,
                        decoration: const InputDecoration(
                          labelText: "Agency Name",
                        ),
                        validator: (v) => role == 'agency'
                            ? _required(v, "Agency Name")
                            : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: agencyDescriptionController,
                        decoration: const InputDecoration(
                          labelText: "Agency Description",
                        ),
                        maxLines: 3,
                        validator: (v) => role == 'agency'
                            ? _required(v, "Agency Description")
                            : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: agencyLandlineController,
                        decoration: const InputDecoration(
                          labelText: "Landline Phone",
                        ),
                        validator: (v) => role == 'agency'
                            ? _required(v, "Landline Phone")
                            : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: agencyAddressController,
                        decoration: const InputDecoration(
                          labelText: "Agency Address",
                        ),
                        validator: (v) => role == 'agency'
                            ? _required(v, "Agency Address")
                            : null,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () => pickImage((f) => agencyImage = f),
                            child: const Text("Agency Picture"),
                          ),
                          const SizedBox(width: 10),
                          if (agencyImage != null)
                            const Icon(Icons.check, color: Colors.green),
                        ],
                      ),
                    ],

                    const SizedBox(height: 30),

                    state is AuthLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: () {
                              if (!_formKey.currentState!.validate()) return;

                              if (role == 'agency' && agencyImage == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Agency picture is required"),
                                  ),
                                );
                                return;
                              }

                              final model = RegisterModel(
                                role: role,
                                phoneNumber: phoneController.text.trim(),
                                email: emailController.text.trim(),
                                username: usernameController.text.trim(),
                                firstName: firstNameController.text.trim(),
                                lastName: lastNameController.text.trim(),
                                password: passwordController.text,
                                dateOfBirth: formattedDate,
                                profileImage: profileImage,
                                idCardImage: idCardImage,
                                agencyName: role == 'agency'
                                    ? agencyNameController.text.trim()
                                    : null,
                                agencyDescription: role == 'agency'
                                    ? agencyDescriptionController.text.trim()
                                    : null,
                                agencyLandlinePhone: role == 'agency'
                                    ? agencyLandlineController.text.trim()
                                    : null,
                                agencyAddress: role == 'agency'
                                    ? agencyAddressController.text.trim()
                                    : null,
                                agencyImage: role == 'agency'
                                    ? agencyImage
                                    : null,
                              );

                              context.read<AuthCubit>().register(model);
                            },
                            child: const Text("Create New Account"),
                          ),

                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account? "),
                        InkWell(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginView(),
                              ),
                            );
                          },
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              color: Color.fromRGBO(232, 144, 4, 1),
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
