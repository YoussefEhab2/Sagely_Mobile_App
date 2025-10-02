
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/api_service.dart';
import '../widgets/base_layout.dart'; 
import 'course_details_page.dart';
import '../widgets/footer.dart';
import '../widgets/header.dart';
import '../widgets/sidebar.dart';
class AnnouncementDetailsPage extends StatefulWidget {
  final int announcementId;
  final int? courseId; 

  const AnnouncementDetailsPage({
    super.key,
    required this.announcementId,
    this.courseId,
  });

  @override
  State<AnnouncementDetailsPage> createState() =>
      _AnnouncementDetailsPageState();
}

class _AnnouncementDetailsPageState extends State<AnnouncementDetailsPage> {
  final ApiService api = ApiService();

  Map<String, dynamic>? announcement;
  Map<String, dynamic>? course;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);

    try {
      announcement = await api.getAnnouncementById(widget.announcementId);

      if (widget.courseId != null) {
        course = await api.getCourseById(widget.courseId!);
      }

      setState(() => isLoading = false);
    } catch (e) {
      print("Error loading announcement details: $e");
      setState(() => isLoading = false);
    }
  }

  String formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return "${date.day.toString().padLeft(2, '0')} ${_monthName(date.month)} ${date.year}";
  }

  String _monthName(int month) {
    const months = [
      "January","February","March","April","May","June",
      "July","August","September","October","November","December"
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (announcement == null) {
      return const Scaffold(
        body: Center(child: Text("Error: Announcement not found")),
      );
    }

    return BaseLayout(
      activeRoute: "/announcements",
      isLoggedIn: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF800020),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              FontAwesomeIcons.bullhorn,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
  
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  announcement!['title'] ?? "",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "${course?['name'] ?? "General"} | "
                  "${announcement!['category']} | "
                  "${formatDate(announcement!['publishDate'])}",
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                const Divider(thickness: 1, color: Color(0xFFD2D4D6)),
                const SizedBox(height: 10),
                Text(
                  announcement!['content'] ?? "",
                  style: const TextStyle(fontSize: 19),
                ),
                const SizedBox(height: 10),
                const Divider(thickness: 1, color: Color(0xFFD2D4D6)),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF800020),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(80, 35),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      icon: const Icon(
                        FontAwesomeIcons.backwardStep,
                        size: 16,
                      ),
                      label: const Text("Back"),
                    ),
                    const SizedBox(width: 15),
                    if (course != null)
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CourseDetailsPage(
                                courseId: course!['id'],
                              ),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFF800020),
                          ),
                          foregroundColor: const Color(0xFF800020),
                          minimumSize: const Size(130, 35),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        icon: const Icon(
                          FontAwesomeIcons.book,
                          size: 16,
                        ),
                        label: const Text("View Course"),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }


}
