
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/api_service.dart';
import '../widgets/base_layout.dart';
import 'announcements_page.dart';
import 'courses.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService api = ApiService();

  String welcome = "Welcome to Sagely!";
  String message = "";
  String announcementMessage = "";
  String courseMessage = "";
  String filesMessage = "";
  List<dynamic> announcements = [];

  bool loading = true;
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final user = await api.getUserOnly();
      final allAnnouncements = await api.getAnnouncements();

      if (user != null && user.isNotEmpty) {
        setState(() {
          isLoggedIn = true;
          welcome = "Welcome back, ${user['name'].toString().split(" ")[0]}!";
          if (user['role'] == "Student") {
            message =
                "Here's what's happening with your postgraduate journey today.";
            announcementMessage =
                "Check the latest updates from your department.";
            courseMessage = "Review and manage your enrolled courses.";
            filesMessage =
                "Access and download your study materials and forms.";
          } else {
            message = "Here's what's happening in the system today.";
            announcementMessage =
                "Stay updated with system-wide announcements.";
            courseMessage = "View and manage all available courses.";
            filesMessage = "Upload and manage official system documents.";
          }
        });
      } else {
        _setGuestMessages();
      }

      if (allAnnouncements.isNotEmpty) {
        allAnnouncements.sort(
          (a, b) => DateTime.parse(b["publishDate"])
              .compareTo(DateTime.parse(a["publishDate"])),
        );

        setState(() {
          announcements = allAnnouncements.take(3).toList();
        });
      }
    } catch (e) {
      _setGuestMessages();
      print("Error loading data: $e");
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  void _setGuestMessages() {
    setState(() {
      isLoggedIn = false;
      welcome = "Welcome to Sagely!";
      message = "Sign in to explore your postgraduate resources and updates.";
      announcementMessage = "Log in to view announcements.";
      courseMessage = "Log in to explore available courses.";
      filesMessage = "Log in to access necessary files.";
    });
  }

  // ================= Cards =================
  Widget buildCard(
    String title,
    IconData icon,
    String content,
    String buttonText,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF800020),
                  ),
                ),
                Icon(icon, color: Color(0xFFB8860B), size: 22),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              content,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF800020),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 3,
              ),
              onPressed: onTap,
              child: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }

  // ================= Announcements =================
  Widget buildAnnouncementItem(dynamic ann) {
    final date = DateTime.parse(ann["publishDate"]);
    final formattedDate =
        "${date.day.toString().padLeft(2, "0")} ${_monthName(date.month)} ${date.year}";

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(FontAwesomeIcons.circle,
                  color: const Color(0xFFB8860B), size: 10),
              const SizedBox(width: 8),
              Text(
                ann["title"],
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF800020),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            formattedDate,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            ann["content"],
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      "",
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];
    return months[month];
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      isLoggedIn: isLoggedIn,
      activeRoute: "/",
      child: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner
                Container(
                  padding: const EdgeInsets.all(30),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF800020), Color(0xFF5A0018)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        welcome,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        message,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),

                // Cards
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount:
                      MediaQuery.of(context).size.width < 768 ? 1 : 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1.8,
                  children: [
                    buildCard(
                      "Announcements",
                      FontAwesomeIcons.bullhorn,
                      announcementMessage,
                      "View All",
                      () {
                        if (isLoggedIn) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AnnouncementsPage(),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginPage()),
                          );
                        }
                      },
                    ),
                    buildCard(
                      "Courses",
                      FontAwesomeIcons.book,
                      courseMessage,
                      "View Courses",
                      () {
                        if (isLoggedIn) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CoursesPage(),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginPage()),
                          );
                        }
                      },
                    ),
                    buildCard(
                      "Files",
                      FontAwesomeIcons.fileArrowDown,
                      filesMessage,
                      "View Files",
                      () {
                        if (isLoggedIn) {
                          
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginPage()),
                          );
                        }
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Announcements Section
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: Colors.black.withOpacity(0.05)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            FontAwesomeIcons.solidBell,
                            color: Color(0xFFB8860B),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            "Latest Announcements",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF800020),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      ...announcements.map(buildAnnouncementItem).toList(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
