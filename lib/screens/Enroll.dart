import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'EnrollmentManagement.dart';

class EnrollPage extends StatefulWidget {
  final int courseId;
  const EnrollPage({super.key, required this.courseId});

  @override
  State<EnrollPage> createState() => _EnrollPageState();
}

class _EnrollPageState extends State<EnrollPage> {
  final ApiService api = ApiService();
  Map<String, dynamic>? course;
  List<dynamic> requirements = [];

  @override
  void initState() {
    super.initState();
    _fetchCourse();
  }

  Future<void> _fetchCourse() async {
    try {
      final fetchedCourse = await api.getCourseById(widget.courseId);
      final reqs = await api.getRequirementsByCourse(widget.courseId);
      setState(() {
        course = fetchedCourse;
        requirements = reqs;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (course == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      
      body: SingleChildScrollView(
        child: EnrollmentManagement(
          course: course!,
          requirements: requirements,
        ),
      ),
    );
  }
}
