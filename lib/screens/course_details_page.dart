
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/api_service.dart';
import '../widgets/base_layout.dart'; 
import 'Enroll.dart';
import 'EnrollmentRequests.dart';
import '../widgets/footer.dart';
import '../widgets/header.dart';
import '../widgets/sidebar.dart';

class CourseDetailsPage extends StatefulWidget {
  final int courseId;

  const CourseDetailsPage({super.key, required this.courseId});

  @override
  State<CourseDetailsPage> createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends State<CourseDetailsPage> {
  final ApiService api = ApiService();

  Map<String, dynamic>? course;
  Map<String, dynamic>? user;
  String? role; 
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final fetchedCourse = await api.getCourseById(widget.courseId);
      final fetchedUserResponse = await api.me();
      final fetchedUser = fetchedUserResponse['user'] as Map<String, dynamic>?;
      final normalizedRole = (fetchedUser?['role'] ?? '').toString().trim().toLowerCase();

      setState(() {
        course = fetchedCourse;
        user = fetchedUser;
        role = normalizedRole;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const mainColor = Color(0xFF800020);
    const secondColor = Colors.white;

    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (error != null || course == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            "Not Found",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    
    Widget pageContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: mainColor,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Center(
                child: Icon(
                  FontAwesomeIcons.book,
                  color: secondColor,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                course!['name'],
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Description
        Padding(
          padding: const EdgeInsets.only(left: 57),
          child: Container(
            padding: const EdgeInsets.only(bottom: 12),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFFD2D4D6),
                  width: 1,
                ),
              ),
            ),
            child: Text(
              course!['description'] ?? '',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
        ),
        const SizedBox(height: 25),

        // Buttons
        Padding(
          padding: const EdgeInsets.only(left: 57),
          child: Wrap(
            spacing: 15,
            runSpacing: 10,
            children: [
              // Back Button
              InkWell(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: mainColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(FontAwesomeIcons.backwardStep, color: secondColor, size: 14),
                      SizedBox(width: 6),
                      Text(
                        "Back",
                        style: TextStyle(color: secondColor, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),

              // Enroll Button (Student only)
              if (role == 'student')
                InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EnrollPage(courseId: widget.courseId),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: secondColor,
                      border: Border.all(color: mainColor, width: 0.7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(FontAwesomeIcons.rightToBracket, color: mainColor, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          "Enroll",
                          style: TextStyle(color: mainColor, fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),

              // View Enrollments Button (Admin only)
              if (role == 'admin')
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EnrollmentRequestsPage(courseId: widget.courseId),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: secondColor,
                      border: Border.all(color: mainColor, width: 0.7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(FontAwesomeIcons.users, color: mainColor, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          "View Enrollments",
                          style: TextStyle(color: mainColor, fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );

    return BaseLayout(
      child: pageContent,
      activeRoute: "/courses",
      isLoggedIn: true, 
    );
  }


}
