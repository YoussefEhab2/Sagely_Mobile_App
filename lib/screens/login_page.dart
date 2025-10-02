
import 'package:flutter/material.dart';
import 'package:sagely/services/api_service.dart'; 
import 'home_page.dart';
import 'signup_page.dart';
import 'Notifications_Page.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final ApiService api = ApiService();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  String? errorMessage; 

  final Color burgundy = const Color(0xFF800020);
  final Color gold = const Color(0xFFB8860B);
  final Color light = const Color(0xFFFAFAFA);

  Future<void> _handleLogin() async {
    setState(() {
      isLoading = true;
      errorMessage = null; 
    });

    try {
      final res = await api.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

  
      if (res.containsKey('token')) {
        await api.saveToken(res['token']);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Welcome ${res['user']['name']} 🎉")),
        );
 


        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    } catch (e) {
      setState(() {
        errorMessage = "Login failed. Please try again.";

        if (e.toString().contains("Invalid credentials")) {
          errorMessage = "Invalid email or password.";
        } else if (e.toString().contains("Unauthorized") ||
            e.toString().contains("401")) {
          errorMessage = "Your session expired. Please login again.";
        } else if (e.toString().contains("Network")) {
          errorMessage = "No internet connection. Please check your network.";
        }
      });
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: light,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Logo
              Image.asset("assets/logo.png", height: 250),
              const SizedBox(height: 2),

              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "SAGE",
                    style: TextStyle(
                      fontFamily: "Cairo",
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: burgundy,
                    ),
                  ),
                  const SizedBox(width: 0),
                  Text(
                    "L",
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: gold,
                    ),
                  ),
                  const SizedBox(width: 0),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Text(
                        "Y",
                        style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          color: gold,
                        ),
                      ),
                      Positioned(
                        top: -10,
                        left: 0,
                        right: -30,
                        child: Image.asset(
                          "assets/graduate-hat.png",
                          height: 30,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 0),

              const SizedBox(height: 20),

              // Title
              Text(
                "Welcome to Sagely",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: burgundy,
                ),
              ),

              const SizedBox(height: 8),
              Text(
                "A centralized digital platform for managing announcements, submission requirements, downloadable forms, and student queries for the postgraduate department at Cairo University.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              const SizedBox(height: 30),

              // Email
              buildTextField(
                "Email",
                "Enter your email",
                controller: emailController,
              ),

              // Password
              buildTextField(
                "Password",
                "Enter your password",
                isPassword: true,
                controller: passwordController,
              ),

              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  
                  child: Text(
                    "Forgot password?",
                
                    style: TextStyle(color: burgundy),
                  ),
                ),
              ),

              const SizedBox(height: 10),

        
              if (errorMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.red[50], // خلفية فاتحة
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          errorMessage!,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Sign In Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handleLogin,
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
                          "Sign In",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // ===== Sign Up Link =====
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("New here? "),
                  GestureDetector(
                    onTap: () {
                      // Navigate to SignUpPage
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignUpPage()),
                      );
                    },
                    child: Text(
                      "Create an Account",
                      style: TextStyle(
                        color: burgundy,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for text fields
  Widget buildTextField(
    String label,
    String hint, {
    bool isPassword = false,
    TextEditingController? controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hint,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
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
