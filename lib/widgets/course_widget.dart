
import 'package:flutter/material.dart';

class CourseCard extends StatelessWidget {
  final int id;
  final String title;
  final String description;
  final bool isAdmin;
  final VoidCallback? onView;
  final VoidCallback? onEdit;

  const CourseCard({
    super.key,
    required this.id,
    required this.title,
    required this.description,
    this.isAdmin = false,
    this.onView,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course title
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF800020),
            ),
          ),
          const SizedBox(height: 10),

          // Course description
          Text(
            description,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 15),

          // Action buttons
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: onView,
                icon: const Icon(Icons.visibility, size: 18, color: Colors.white),
                label: const Text(
                  "View Details",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF800020),
                ),
              ),
              const SizedBox(width: 10),
              if (isAdmin)
                OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 18, color: Color(0xFF800020)),
                  label: const Text(
                    "Edit Course",
                    style: TextStyle(color: Color(0xFF800020)),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF800020)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
