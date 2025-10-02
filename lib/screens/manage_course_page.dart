
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/api_service.dart';
import '../widgets/confirm_modal.dart';
import '../widgets/base_layout.dart'; 

class ManageCoursePage extends StatefulWidget {
  final Map<String, dynamic>? course;
  const ManageCoursePage({super.key, this.course});

  @override
  State<ManageCoursePage> createState() => _ManageCoursePageState();
}

class _ManageCoursePageState extends State<ManageCoursePage> {
  final ApiService api = ApiService();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  List<Map<String, dynamic>> requirements = [];
  List<Map<String, dynamic>> fetchedRequirements = [];
  bool showError = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.course != null) {
      titleController.text = widget.course!["name"] ?? "";
      descriptionController.text = widget.course!["description"] ?? "";
      _loadRequirements();
    }
  }

  Future<void> _loadRequirements() async {
    try {
      final data = await api.getRequirementsByCourse(widget.course!['id']);
      setState(() {
        requirements = List<Map<String, dynamic>>.from(data);
        fetchedRequirements = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      print("Failed to load requirements: $e");
    }
  }

  void addRequirement() {
    setState(() {
      requirements.add({'title': '', 'description': '', 'id': null});
    });
  }

  void editRequirement(int index, String field, String value) {
    setState(() {
      requirements[index][field] = value;
    });
  }

  void deleteRequirement(int index) {
    setState(() {
      requirements.removeAt(index);
    });
  }

  Future<void> submit() async {
    if (titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        requirements.any(
          (r) =>
              r["title"].toString().isEmpty ||
              r["description"].toString().isEmpty,
        )) {
      setState(() {
        showError = true;
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      int courseId;
      final name = titleController.text;
      final description = descriptionController.text;

      if (widget.course != null) {
        final updated = await api.updateCourse(
          widget.course!['id'],
          name,
          description,
        );
        courseId = updated['course']['id'];
      } else {
        final created = await api.createCourse(name, description);
        courseId = created['course']['id'];
      }

      for (var req in requirements) {
        final body = {
          "title": req['title'],
          "description": req['description'],
          "courseID": courseId,
        };
        await api.storeRequirement(body);
      }

      for (var oldReq in fetchedRequirements) {
        await api.deleteRequirement(oldReq['id'].toString());
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      print("Submit failed: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteCourse() async {
    try {
      await api.deleteCourse(widget.course!['id']);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      print("Delete failed: $e");
    }
  }

  InputDecoration fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      activeRoute: "/courses",
      isLoggedIn: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      widget.course != null ? "Edit Course" : "Create Course",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF800020),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text("Title", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF800020))),
                  const SizedBox(height: 5),
                  TextField(controller: titleController, decoration: fieldDecoration("")),
                  const SizedBox(height: 10),
                  const Text("Description", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF800020))),
                  const SizedBox(height: 5),
                  TextField(controller: descriptionController, maxLines: 3, decoration: fieldDecoration("")),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Requirements", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF800020))),
                      ElevatedButton(
                        onPressed: addRequirement,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF800020),
                          minimumSize: const Size(44, 44),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const FaIcon(FontAwesomeIcons.plus, color: Colors.white, size: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Column(
                    children: List.generate(requirements.length, (index) {
                      final req = requirements[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Title", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF800020))),
                            const SizedBox(height: 5),
                            TextField(
                              controller: TextEditingController(text: req['title']),
                              onChanged: (val) => editRequirement(index, "title", val),
                              decoration: fieldDecoration(""),
                            ),
                            const SizedBox(height: 10),
                            const Text("Description", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF800020))),
                            const SizedBox(height: 5),
                            TextField(
                              controller: TextEditingController(text: req['description']),
                              onChanged: (val) => editRequirement(index, "description", val),
                              maxLines: 2,
                              decoration: fieldDecoration(""),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () => deleteRequirement(index),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                minimumSize: const Size(double.infinity, 40),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const FaIcon(FontAwesomeIcons.trash, color: Colors.white, size: 16),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                  if (showError) const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text("Please enter all fields!", style: TextStyle(color: Colors.red)),
                  ),
                  if (!isLoading)
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF800020),
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Text(widget.course != null ? "Save" : "Create", style: const TextStyle(color: Colors.white, fontSize: 16)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (widget.course != null)
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => ConfirmModal(
                                    title: "Confirm Delete",
                                    message: "Are you sure you want to delete this course?",
                                    confirmText: "Delete",
                                    onConfirm: () {
                                      Navigator.pop(context);
                                      deleteCourse();
                                    },
                                    onCancel: () => Navigator.pop(context),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text("Delete", style: TextStyle(color: Colors.white, fontSize: 16)),
                            ),
                          ),
                      ],
                    )
                  else
                    const Center(child: CircularProgressIndicator()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
