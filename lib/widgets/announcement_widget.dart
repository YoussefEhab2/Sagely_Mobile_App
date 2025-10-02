
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../screens/announcement_details.dart'; 
import '../services/api_service.dart';
import '../screens/edit_announcement.dart'; 
import '../screens/announcement_details.dart'; 
class AnnouncementWidget extends StatelessWidget {
  final Map<String, dynamic> announcement;
  final Map<String, dynamic>? course;
  final Map<String, dynamic>? user;
  final Function(int)? onUpdated; 
  const AnnouncementWidget({
    super.key,
    required this.announcement,
    this.course,
    this.user,
    this.onUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final publishDate = DateTime.parse(announcement['publishDate']);
    String monthName(int month) {
      const months = [
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
      ];
      return months[month - 1];
    }
    final formattedDate =
        "${publishDate.day.toString().padLeft(2, '0')} ${monthName(publishDate.month)} ${publishDate.year}";

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + Category
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                announcement['title'] ?? "",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF800020),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0x19800020),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  announcement['category'] ?? "",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: Color(0xFF800020),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Date + Course
          Row(
            children: [
              const FaIcon(FontAwesomeIcons.calendarAlt, size: 14, color: Colors.grey),
              const SizedBox(width: 5),
              Text(
                formattedDate,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(width: 15),
              const FaIcon(FontAwesomeIcons.book, size: 14, color: Colors.grey),
              const SizedBox(width: 5),
              Text(
                course?['name'] ?? "General",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Description
          Text(
            announcement['content'] ?? "",
            style: const TextStyle(fontSize: 14, color: Colors.black87),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          // Buttons
          Row(
            children: [
              ElevatedButton.icon(
                icon: const FaIcon(FontAwesomeIcons.eye, size: 16),
                label: const Text("View Details"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AnnouncementDetailsPage(
                        announcementId: announcement['id'],
                        courseId: course?['id'],
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF800020),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(130, 45),
                ),
              ),
              const SizedBox(width: 10),
              if (user != null && user!['role'].toString().toLowerCase() == "admin")
                ElevatedButton.icon(
                  icon: const FaIcon(FontAwesomeIcons.edit, size: 16),
                  label: const Text("Edit"),
                  onPressed: () async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => EditAnnouncementPage(
        announcementId: announcement['id'],
        isAdmin: true,
      ),
    ),
  );

  if (result == true && onUpdated != null) {
    onUpdated!(announcement['id']); 
  }
},

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF800020),
                    side: const BorderSide(color: Color(0xFF800020)),
                    minimumSize: const Size(130, 45),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
