import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/confirm_modal.dart';

class Header extends StatefulWidget {
  const Header({super.key});

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  final ApiService api = ApiService();

  String? userName;
  bool isLoggedIn = false;
  bool loading = true;

  final Color mainColor = const Color(0xFF800020);
  final Color thirdColor = const Color(0xFFB8860B); 

  @override
  void initState() {
    super.initState();
    initHeader();
  }

  Future<void> initHeader() async {
    await ApiService.loadToken(); 
    await loadUser();
  }

  Future<void> loadUser() async {
    try {
      final response = await api.me();
      print("API /me response: $response");

      setState(() {
        userName = response["user"]?["name"]; 
        isLoggedIn = true;
        loading = false;
      });
    } catch (e) {
      print("Error fetching user: $e");
      setState(() {
        isLoggedIn = false;
        userName = null;
        loading = false;
      });
    }
  }

  Future<void> _confirmLogout(BuildContext parentContext) async {
    showDialog(
      context: parentContext,
      builder: (context) => ConfirmModal(
        title: "Confirm Logout",
        message: "Are you sure you want to log out?",
        confirmText: "Yes, Logout",
        onConfirm: () async {
          Navigator.of(context).pop();

          try {
            await api.logout();

            if (!parentContext.mounted) return;

            setState(() {
              isLoggedIn = false;
              userName = null;
            });

            Navigator.of(parentContext)
                .pushReplacementNamed("/login_page");
          } catch (e) {
            if (!parentContext.mounted) return;
            ScaffoldMessenger.of(parentContext).showSnackBar(
              const SnackBar(content: Text("Logout failed, please try again.")),
            );
          }
        },
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    double height = 80;
    double logoFontSize = 28;
    double userFontSize = 16;
    double imgHeight = 24;

    if (screenWidth <= 768) {
      height = 50;
      logoFontSize = 22;
      userFontSize = 14;
      imgHeight = 20;
    }
    if (screenWidth <= 480) {
      logoFontSize = 25;
      userFontSize = 18;
      imgHeight = 18;
    }

    return Container(
      height: height,
      color: Colors.white,
      child: Row(
        children: [
          // ===== Menu Button + Logo =====
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Builder(
                builder: (context) => IconButton(
                  icon: Icon(Icons.menu, color: mainColor),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  padding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(width: 4),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Row(
                    children: [
                      Text(
                        "SAGE",
                        style: TextStyle(
                          fontFamily: "Cairo",
                          fontSize: logoFontSize,
                          fontWeight: FontWeight.bold,
                          color: mainColor,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        "L",
                        style: TextStyle(
                          fontSize: logoFontSize,
                          fontWeight: FontWeight.bold,
                          color: thirdColor,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        "Y",
                        style: TextStyle(
                          fontSize: logoFontSize,
                          fontWeight: FontWeight.bold,
                          color: thirdColor,
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    top: -8,
                    left: 90,
                    child: Image.asset(
                      "assets/graduate-hat.png",
                      height: imgHeight,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const Spacer(),

          // ===== Username / Login / Logout =====
          if (loading)
            const CircularProgressIndicator()
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    if (isLoggedIn) {
                      Navigator.pushNamed(context, "/profile");
                    } else {
                      Navigator.pushNamed(context, "/login_page");
                    }
                  },
                  child: Text(
                    isLoggedIn && userName != null
                        ? userName!.split(" ").take(2).join(" ") 
                        : "Login",
                    style: TextStyle(
                      fontSize: userFontSize,
                      fontWeight: FontWeight.w600,
                      color: mainColor,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
                if (isLoggedIn)
                  IconButton(
                    icon: Icon(Icons.logout, color: mainColor),
                    onPressed: () => _confirmLogout(context),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
