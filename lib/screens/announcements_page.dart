
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/api_service.dart';
import '../widgets/announcement_widget.dart';
import '../widgets/base_layout.dart';
import 'add_announcement.dart';

class AnnouncementsPage extends StatefulWidget {
  const AnnouncementsPage({super.key});

  @override
  State<AnnouncementsPage> createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends State<AnnouncementsPage> {
  final ApiService api = ApiService();

  Map<String, dynamic>? currentUser;
  List<Map<String, dynamic>> allCourses = [];
  List<Map<String, dynamic>> allAnnouncements = [];

  List<Map<String, dynamic>> relatedCourses = [];
  List<Map<String, dynamic>> announcements = [];

  String searchValue = "";
  dynamic courseFilter; 
  int currentPage = 0;
  final int pageSize = 3;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }
Future<void> refreshAnnouncement(int id) async {
  try {
    final updated = await api.getAnnouncementById(id);
    setState(() {
      final index = announcements.indexWhere((a) => a['id'] == id);
      if (index != -1) {
        announcements[index] = updated;
        
        announcements.sort(
          (a, b) => DateTime.parse(b['publishDate'])
              .compareTo(DateTime.parse(a['publishDate'])),
        );
      }
    });
  } catch (e) {
    print("Error refreshing announcement: $e");
  }
}

  Future<void> loadData() async {
    setState(() => isLoading = true);
    try {
      // Get current user
      final userData = await api.getUserOnly();
      currentUser = userData;

      // Get all courses
      final coursesData = await api.getCourses();
      allCourses = List<Map<String, dynamic>>.from(coursesData);

      // Get all announcements
      final announcementsData = await api.getAnnouncements();
      allAnnouncements = List<Map<String, dynamic>>.from(announcementsData);

      // Prepare relatedCourses and announcements based on role
      List<Map<String, dynamic>> generalAnnouncements =
          allAnnouncements.where((a) => a['courseID'] == null).toList();

      List<Map<String, dynamic>> courseAnnouncements =
          allAnnouncements.where((a) => a['courseID'] != null).toList();

      announcements = [...generalAnnouncements];

      if (currentUser!['role'].toString().toLowerCase() == 'admin') {
        relatedCourses = allCourses
            .where((c) => c['adminid'] == currentUser!['id'])
            .toList();

        for (var a in courseAnnouncements) {
          var course = allCourses.firstWhere(
            (c) => c['id'] == a['courseID'],
            orElse: () => {},
          );
          if (course.isNotEmpty && course['adminid'] == currentUser!['id']) {
            announcements.add(a);
          }
        }
      } else {
        // Student
        final enrolledData = await api.getMyEnrolledCourses();
        relatedCourses = enrolledData.map<Map<String, dynamic>>((c) {
          return {'id': c['courseId'], 'name': c['courseName']};
        }).toList();

        for (var a in courseAnnouncements) {
          if (relatedCourses.any((c) => c['id'] == a['courseID'])) {
            announcements.add(a);
          }
        }
      }

      // Sort by publishDate descending
      announcements.sort(
        (a, b) => DateTime.parse(b['publishDate'])
            .compareTo(DateTime.parse(a['publishDate'])),
      );

      // Set default courseFilter
      courseFilter = null;

      setState(() => isLoading = false);
    } catch (e) {
      print("Error loading data: $e");
      setState(() => isLoading = false);
    }
  }

  List<Map<String, dynamic>> get filteredAnnouncements {
    return announcements
        .where(
          (a) =>
              a['title'].toString().toLowerCase().contains(
                    searchValue.toLowerCase(),
                  ) &&
              (courseFilter == null || a['courseID'] == courseFilter),
        )
        .toList();
  }

  List<Map<String, dynamic>> get currentAnnouncements {
    int start = currentPage * pageSize;
    int end = start + pageSize;
    if (end > filteredAnnouncements.length) end = filteredAnnouncements.length;
    return filteredAnnouncements.sublist(start, end);
  }

  int get pageCount => (filteredAnnouncements.length / pageSize).ceil();

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      isLoggedIn: true,
      activeRoute: "/announcements",
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + Add Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        FaIcon(
                          FontAwesomeIcons.bullhorn,
                          color: Color(0xFFB8860B),
                          size: 28,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Announcements",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 24,
                            color: Color(0xFF800020),
                          ),
                        ),
                      ],
                    ),
                    if (currentUser?['role'].toString().toLowerCase() == 'admin')
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddAnnouncementPage(
                                isAdmin: true,
                              ),
                            ),
                          ).then((_) {
                            loadData();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF800020),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(12),
                        ),
                        child: const FaIcon(
                          FontAwesomeIcons.plus,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Search & Filter
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        decoration: const InputDecoration(
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey,
                          ),
                          hintText: "Search announcements...",
                          border: InputBorder.none,
                        ),
                        onSubmitted: (val) => setState(() {
                          searchValue = val;
                          currentPage = 0;
                        }),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonFormField<dynamic>(
                        value: courseFilter,
                        decoration: const InputDecoration(border: InputBorder.none),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text("All Announcements"),
                          ),
                          ...relatedCourses.map(
                            (c) => DropdownMenuItem(
                              value: c['id'] as int,
                              child: Text(c['name']),
                            ),
                          ),
                        ],
                        onChanged: (val) => setState(() {
                          courseFilter = val;
                          currentPage = 0;
                        }),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Announcements List
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: currentAnnouncements.length,
                  itemBuilder: (context, index) {
                    var a = currentAnnouncements[index];
                    var course = relatedCourses.firstWhere(
                      (c) => c['id'] == a['courseID'],
                      orElse: () => {'name': 'General'},
                    );
                    return AnnouncementWidget(
                      announcement: a,
                      course: course,
                      user: currentUser!,
                       onUpdated: (id) => refreshAnnouncement(id), 
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Pagination
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: List.generate(pageCount, (i) {
                //     return Padding(
                //       padding: const EdgeInsets.symmetric(horizontal: 4),
                //       child: ElevatedButton(
                //         style: ElevatedButton.styleFrom(
                //           backgroundColor: currentPage == i
                //               ? const Color(0xFF800020)
                //               : Colors.grey[300],
                //         ),
                //         onPressed: () => setState(() => currentPage = i),
                //         child: Text(
                //           "${i + 1}",
                //           style: TextStyle(
                //             color: currentPage == i ? Colors.white : Colors.black,
                //           ),
                //         ),
                //       ),
                //     );
                //   }),
                // ),
              ],
            ),
    );
  }
}
