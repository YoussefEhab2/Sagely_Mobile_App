
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'not_found.dart';
import '../widgets/base_layout.dart';

class EnrollmentRequestsPage extends StatefulWidget {
  final int courseId;
  const EnrollmentRequestsPage({super.key, required this.courseId});

  @override
  State<EnrollmentRequestsPage> createState() => _EnrollmentRequestsPageState();
}

class _EnrollmentRequestsPageState extends State<EnrollmentRequestsPage> {
  final ApiService api = ApiService();

  Map<String, dynamic>? course;
  Map<String, dynamic>? user;
  List<dynamic> submissions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final fetchedUser = await api.getUserOnly();
      final fetchedCourse = await api.getCourseById(widget.courseId);
      final fetchedSubmissions = await api.getSubmissionsByCourse(widget.courseId);

    
      final uniqueSubs = {
        for (var sub in fetchedSubmissions) sub['studentID']: sub
      }.values.toList();

      setState(() {
        user = fetchedUser;
        course = fetchedCourse;
        submissions = uniqueSubs;
        isLoading = false;
      });
    } catch (e) {
      print("Error: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (course == null || user == null || user!['role']?.toLowerCase() == 'student') {
      return const NotFoundPage();
    }

    return BaseLayout(
      isLoggedIn: true, 
      activeRoute: "/courses",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, 
        children: [
          // header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF800020),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Enrollment Submissions",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  "Review and process student enrollment requests",
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // submissions list
          submissions.isEmpty
              ? const Center(child: Text("No submissions found"))
              : ListView.builder(
                  shrinkWrap: true, 
                  physics: const NeverScrollableScrollPhysics(), 
                  itemCount: submissions.length,
                  itemBuilder: (context, index) {
                    final sub = submissions[index];
                    return SubmissionCard(
                      course: course!,
                      submission: sub,
                    );
                  },
                ),
        ],
      ),
    );
  }
}

class SubmissionCard extends StatelessWidget {
  final Map<String, dynamic> course;
  final Map<String, dynamic> submission;

  const SubmissionCard({
    super.key,
    required this.course,
    required this.submission,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Container(
        padding: const EdgeInsets.all(16),
        height: 100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Student Info
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  submission['studentName'] ?? "Unknown",
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF800020)),
                ),
                const SizedBox(height: 4),
                Text(
                  submission['studentEmail'] ?? "",
                  style: const TextStyle(color: Color.fromARGB(221, 0, 0, 0)),
                ),
              ],
            ),

            // Check button
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF800020),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Check Requirements",
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
