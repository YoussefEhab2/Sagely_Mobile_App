
import 'package:flutter/material.dart';
import 'package:sagely/screens/login_page.dart';
import '../services/api_service.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final Color burgundy = const Color(0xFF800020);
  final Color gold = const Color(0xFFB8860B);
  final Color light = const Color(0xFFFAFAFA);

  bool isLoading = false;

  final ApiService api = ApiService();


  Future<void> registerUser() async {
    if (!mounted) return;

    setState(() => isLoading = true);

    try {
      final response = await api.signup(
        _nameController.text,
        _emailController.text,
        _passwordController.text,
        _phoneController.text,
      );

      if (!mounted) return; 

      if (response['token'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account created successfully!")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed: ${response['message'] ?? 'Unknown error'}")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: light,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Image.asset("assets/logo.png", height: 250),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("SAGE",
                        style: TextStyle(
                          fontFamily: "Cairo",
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          color: burgundy,
                        )),
                    Text("L",
                        style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          color: gold,
                        )),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Text("Y",
                            style: TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                              color: gold,
                            )),
                        Positioned(
                          top: -10,
                          left: 0,
                          right: -30,
                          child: Image.asset("assets/graduate-hat.png", height: 30),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Text("Join Sagely",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: burgundy,
                    )),
                const SizedBox(height: 8),
                Text(
                  "Create your account to access announcements, submit requirements, download forms, and send queries to the postgraduate department at Cairo University.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                const SizedBox(height: 30),

                // ====== Form Fields ======
                buildTextFormField(
                  controller: _nameController,
                  label: "Full Name",
                  hint: "Enter your full name",
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter your full name';
                    if (value.trim().split(' ').length < 3) return 'Enter your full name (three parts)';
                    return null;
                  },
                ),

                buildTextFormField(
                  controller: _emailController,
                  label: "Email",
                  hint: "Enter your email",
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter your email';
                    if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) return 'Enter a valid email';
                    return null;
                  },
                ),

                buildTextFormField(
                  controller: _phoneController,
                  label: "Phone Number",
                  hint: "Enter your phone number",
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter your phone number';
                    if (!RegExp(r'^(010|011|012|015)[0-9]{8}$').hasMatch(value)) return 'Enter a valid Egyptian phone number';
                    return null;
                  },
                ),

                buildTextFormField(
                  controller: _passwordController,
                  label: "Password",
                  hint: "Enter your password",
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter your password';
                    if (value.length < 8) return 'Password must be at least 8 characters';
                    if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Password must have at least 1 uppercase letter';
                    if (!RegExp(r'[a-z]').hasMatch(value)) return 'Password must have at least 1 lowercase letter';
                    if (!RegExp(r'[0-9]').hasMatch(value)) return 'Password must have at least 1 number';
                    return null;
                  },
                ),

                buildTextFormField(
                  controller: _confirmPasswordController,
                  label: "Confirm Password",
                  hint: "Confirm your password",
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please confirm your password';
                    if (value != _passwordController.text) return 'Passwords do not match';
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // ====== Sign Up button ======
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              registerUser(); 
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: burgundy,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Sign Up",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 15),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                      },
                      child: Text("Sign In",
                          style: TextStyle(
                            color: burgundy,
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: burgundy),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }
}
