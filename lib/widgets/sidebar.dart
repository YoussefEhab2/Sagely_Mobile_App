
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/api_service.dart'; 
import 'confirm_modal.dart'; 
class Sidebar extends StatefulWidget {
  final bool isLoggedIn;
  final String activeRoute;

  const Sidebar({
    super.key,
    required this.isLoggedIn,
    required this.activeRoute,
  });

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  final Color mainColor = const Color(0xFF800020); 
  final Color activeBgColor = const Color(0x1A800020);
  final ApiService apiService = ApiService();

  int unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final notifications = await apiService.getMyNotifications();      
      setState(() {
        unreadCount = notifications
            .where((n) =>  n["status"] == "Unread") 
            .length;
      });
    } catch (e) {
      print("Failed to load notifications: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 250,
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            // ===== Header =====
            Container(
              height: 130,
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("SAGE",
                      style: TextStyle(
                          fontFamily: "Cairo",
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: mainColor)),
                  const SizedBox(width: 2),
                  Text("L",
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFB8860B))),
                  const SizedBox(width: 2),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Text("Y",
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFB8860B))),
                      Positioned(
                        top: -8,
                        left: 0,
                        right: -10,
                        child: Image.asset(
                          "assets/graduate-hat.png",
                          height: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(color: Colors.grey.shade300, thickness: 1),

            // ===== Menu Items =====
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _menuItem(
                      context,
                      icon: FontAwesomeIcons.tachometerAlt,
                      text: "Dashboard",
                      route: "/",
                      activeRoute: widget.activeRoute),
                  _menuItem(
                      context,
                      icon: FontAwesomeIcons.bullhorn,
                      text: "Announcements",
                      route: "/announcements",
                      activeRoute: widget.activeRoute),
                  _menuItem(
                      context,
                      icon: FontAwesomeIcons.book,
                      text: "Courses",
                      route: "/courses",
                      activeRoute: widget.activeRoute),
                  _menuItem(
                      context,
                      icon: FontAwesomeIcons.fileDownload,
                      text: "Files",
                      route: "/files",
                      activeRoute: widget.activeRoute),

                  
                  
                  _menuItem(
                    
                    context,
                    icon: FontAwesomeIcons.solidBell,
                    text: "Notifications",
                    route: "/notifications",
                    activeRoute: widget.activeRoute,
                    badge: unreadCount > 0 ? unreadCount.toString() : null,
                    
                  ),

                  _menuItem(
                      context,
                      icon: FontAwesomeIcons.robot,
                      text: "Chatbot",
                      route: "/chatbot",
                      activeRoute: widget.activeRoute),
                  _menuItem(
                    context,
                    icon: FontAwesomeIcons.solidUser,
                    text: widget.isLoggedIn ? "Profile" : "Login",
                    route: widget.isLoggedIn ? "/profile" : "/login_page",
                    activeRoute: widget.activeRoute,
                  ),
                  if (widget.isLoggedIn)
                    _menuItem(
                      context,
                      icon: FontAwesomeIcons.signOutAlt,
                      text: "Logout",
                      route: "",
                      activeRoute: "",
                      onTap: () => _confirmLogout(context),
                      isLogout: true,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(BuildContext context,
      {required IconData icon,
      required String text,
      required String route,
      required String activeRoute,
      String? badge, 
      VoidCallback? onTap,
      bool isLogout = false}) {
    final bool isActive = !isLogout && route == activeRoute;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap ??
            () {
              if (route.isNotEmpty) {
                Navigator.pushReplacementNamed(context, route);
              }
            },
        child: Container(
          height: 60,
          padding: const EdgeInsets.only(left: 35, right: 20),
          decoration: BoxDecoration(
            color: isActive ? activeBgColor : Colors.transparent,
            border: isActive
                ? Border(left: BorderSide(color: mainColor, width: 4))
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  FaIcon(icon, color: mainColor, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: mainColor,
                    ),
                  ),
                ],
              ),
              if (badge != null) 
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: mainColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext parentContext) {
    showDialog(
      context: parentContext,
      builder: (context) => ConfirmModal(
        title: "Confirm Logout",
        message: "Are you sure you want to log out?",
        confirmText: "Yes, Logout",
        onConfirm: () async {
          Navigator.of(context).pop();
          try {
            await apiService.logout();
            if (!parentContext.mounted) return;
            Navigator.of(parentContext).pushReplacementNamed("/login_page");
          } catch (e) {
            print("Logout failed: $e");
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
}
