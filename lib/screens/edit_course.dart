import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import 'manage_course_page.dart';
import 'not_found.dart';

class EditCoursePage extends StatefulWidget {
  final int courseId;
  const EditCoursePage({super.key, required this.courseId});

  @override
  State<EditCoursePage> createState() => _EditCoursePageState();
}

class _EditCoursePageState extends State<EditCoursePage> {
  Map<String, dynamic>? course;
  bool isLoading = true;
  bool notFound = false;
  final ApiService api = ApiService();

  @override
  void initState() {
    super.initState();
    _loadCourse();
  }

  Future<void> _loadCourse() async {
    try {
      final data = await api.getCourseById(widget.courseId);
      if (mounted) {
        setState(() {
          course = data;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Course not found: $e");
      if (mounted) {
        setState(() {
          notFound = true;
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (notFound || course == null) {
      return const NotFoundPage();
    }

    return ManageCoursePage(course: course);
  }
}
