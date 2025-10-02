import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/confirm_modal.dart';
import '../widgets/base_layout.dart';

class ManageAnnouncementPage extends StatefulWidget {
  final int? announcementId; 
  final bool isAdmin;

  const ManageAnnouncementPage({
    super.key,
    this.announcementId,
    required this.isAdmin,
  });

  @override
  State<ManageAnnouncementPage> createState() => _ManageAnnouncementPageState();
}

class _ManageAnnouncementPageState extends State<ManageAnnouncementPage> {
  final _formKey = GlobalKey<FormState>();

  bool loading = true;
  bool showError = false;

  List<Map<String, dynamic>> courses = [];
  Map<String, dynamic>? announcement;
  int? selectedCourse;
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  TextEditingController categoryController = TextEditingController();

  final Color maroon = const Color(0xFF800020);

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final rawCourses = await ApiService().getCourses();
      courses = List<Map<String, dynamic>>.from(rawCourses);

      if (widget.announcementId != null) {
        final fetchedAnnouncement = await ApiService().getAnnouncementById(
          widget.announcementId!,
        );
        announcement = fetchedAnnouncement;
        titleController.text = announcement?['title'] ?? "";
        contentController.text = announcement?['content'] ?? "";
        categoryController.text = announcement?['category'] ?? "";
        selectedCourse = announcement?['courseID'];
      }

      setState(() => loading = false);
    } catch (e) {
      debugPrint("Error fetching data: $e");
      setState(() => loading = false);
    }
  }

  void submit() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => showError = true);
      return;
    }
    setState(() => showError = false);

    try {
      if (widget.announcementId == null) {
        await ApiService().createAnnouncement(
          titleController.text,
          contentController.text,
          categoryController.text,
          selectedCourse,
        );
      } else {
        await ApiService().editAnnouncement(widget.announcementId.toString(), {
          "title": titleController.text,
          "content": contentController.text,
          "category": categoryController.text,
          "courseID": selectedCourse,
        });
      }
      Navigator.pop(context, true);
    } catch (e) {
      debugPrint("Error submitting announcement: $e");
    }
  }

  void deleteAnnouncement() async {
    if (widget.announcementId == null) return;
    try {
      await ApiService().deleteAnnouncement(widget.announcementId.toString());
      Navigator.pop(context, true);
    } catch (e) {
      debugPrint("Error deleting announcement: $e");
    }
  }

  InputDecoration fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFFD3D3D3)),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.grey, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isAdmin) {
      return const Scaffold(body: Center(child: Text("Not Found")));
    }

    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return BaseLayout(
      isLoggedIn: true,
      activeRoute: "/announcements",
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F6F7),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                blurRadius: 12,
                spreadRadius: 2,
                color: Colors.black.withOpacity(0.15),
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.announcementId == null
                      ? "Create Announcement"
                      : "Edit Announcement",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: maroon,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  "Title",
                  style: TextStyle(color: maroon, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: titleController,
                  decoration: fieldDecoration("Enter title"),
                  validator: (val) =>
                      val == null || val.isEmpty ? "Enter title" : null,
                ),
                const SizedBox(height: 16),

                // Content
                Text(
                  "Content",
                  style: TextStyle(color: maroon, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: contentController,
                  maxLines: 4,
                  decoration: fieldDecoration("Enter content"),
                  validator: (val) =>
                      val == null || val.isEmpty ? "Enter content" : null,
                ),
                const SizedBox(height: 16),

                // Category
                Text(
                  "Category",
                  style: TextStyle(color: maroon, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: categoryController,
                  decoration: fieldDecoration("Enter category"),
                  validator: (val) =>
                      val == null || val.isEmpty ? "Enter category" : null,
                ),
                const SizedBox(height: 16),

                // Course Dropdown
                Text(
                  "Course",
                  style: TextStyle(color: maroon, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<int>(
                  value: selectedCourse,
                  decoration: fieldDecoration("Select course"),
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 200,
                        ),
                        child: Text("General", overflow: TextOverflow.ellipsis),
                      ),
                    ),
                    ...courses.map(
                      (c) => DropdownMenuItem(
                        value: c['id'],
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 200),
                          child: Text(
                            c['name'],
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ],
                  onChanged: (val) => setState(() => selectedCourse = val),
                ),

                const SizedBox(height: 12),

                if (showError)
                  const Text(
                    "Please Enter all fields!",
                    style: TextStyle(color: Colors.red),
                  ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: maroon,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          widget.announcementId == null ? "Create" : "Save",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (widget.announcementId != null)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => ConfirmModal(
                                title: "Confirm Delete",
                                message:
                                    "Are you sure you want to delete this item?",
                                confirmText: "Yes, Delete",
                                onConfirm: () {
                                  deleteAnnouncement();
                                  Navigator.pop(context);
                                },
                                onCancel: () => Navigator.pop(context),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB00020),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "Delete",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
