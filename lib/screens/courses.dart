
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../widgets/base_layout.dart';
import '../services/api_service.dart';
import '../widgets/course_widget.dart';
import 'add_course.dart';
import 'course_details_page.dart';
import 'edit_course.dart';

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  final ApiService api = ApiService();
  bool isLoading = true;
  List<dynamic> courses = [];
  bool isAdmin = false;
  bool enrolledOnly = false; 
  Map<String, dynamic>? currentUser;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      setState(() {
        isLoading = true;
      });

      final user = await api.getUserOnly();
      final adminStatus = user["role"]?.toString().toLowerCase() == "admin";
      final userId = user["id"];
      currentUser = user;

      List<dynamic> data;

      if (adminStatus) {
      
        final allCourses = await api.getCourses();
        data = allCourses.where((c) => c["adminid"] == userId).toList();
      } else if (enrolledOnly) {
  
        data = await api.getMyEnrolledCourses();
      } else {
        
        data = await api.getCourses();
      }

      setState(() {
        courses = data;
        isAdmin = adminStatus;
        isLoading = false;
      });
    } catch (e) {
      print("Error loading data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget pageContent = isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== Header row =====
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        FaIcon(FontAwesomeIcons.book, color: Color(0xFFB8860B)),
                        SizedBox(width: 8),
                        Text(
                          "Courses",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF800020),
                          ),
                        ),
                      ],
                    ),
                    if (isAdmin)
                      ElevatedButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddCoursePage(),
                            ),
                          );
                          if (result == true) {
                            fetchData();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF800020),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              8,
                            ), 
                          ),
                          padding: const EdgeInsets.all(12), 
                        ),
                        child: const FaIcon(
                          FontAwesomeIcons.plus,
                          color: Colors.white,
                          size: 20,
                        ),
                      )
                    else
                      
                      Row(
                        children: [
                          Transform.scale(
                            scale: 0.8,
                            child: Checkbox(
                              value: enrolledOnly,
                              activeColor: const Color(0xFF800020),
                              onChanged: (value) {
                                setState(() {
                                  enrolledOnly = value ?? false;
                                });
                                fetchData();
                              },
                            ),
                          ),
                          const SizedBox(width: 0),
                          const Text(
                            "Enrolled Only",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF800020),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 20),

                // ===== Courses list =====
                if (courses.isEmpty)
                  const Center(
                    child: Text(
                      "No courses available.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  Column(
                    children: courses.map((course) {
                      return CourseCard(
                        id: course["id"] ?? course["courseId"] ?? 0,
                        title: course["name"] ?? course["courseName"] ?? "",
                        description: course["description"] ?? "",
                        isAdmin: isAdmin,
                        onView: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CourseDetailsPage(
                                courseId:
                                    course["id"] ?? course["courseId"] ?? 0,
                              ),
                            ),
                          );
                        },
                        onEdit: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditCoursePage(courseId: course["id"]),
                            ),
                          ).then((result) {
                            if (result == true) {
                              fetchData();
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
              ],
            ),
          );

    return BaseLayout(
      child: pageContent,
      activeRoute: "/courses",
      isLoggedIn: true, 
    );
  }
}
