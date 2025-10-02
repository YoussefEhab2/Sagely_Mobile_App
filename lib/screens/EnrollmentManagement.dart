
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/header.dart';
import '../widgets/footer.dart';
import '../widgets/sidebar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class EnrollmentManagement extends StatefulWidget {
  final Map<String, dynamic> course;
  final List<dynamic> requirements;

  const EnrollmentManagement({
    super.key,
    required this.course,
    required this.requirements,
  });

  @override
  State<EnrollmentManagement> createState() => _EnrollmentManagementState();
}

class _EnrollmentManagementState extends State<EnrollmentManagement> {
  final ApiService api = ApiService();
  final Map<int, String> files = {}; 
  bool isLoading = false; 

  Future<void> _submit() async {
    for (var req in widget.requirements) {
      if (!files.containsKey(req["id"])) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please upload all requested files!")),
        );
        return;
      }
    }

    setState(() {
      isLoading = true;
    });

    try {
      for (var req in widget.requirements) {
        await api.submitRequirement(
          req["id"].toString(),
          files[req["id"]]!, 
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Requirements submitted successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
        border: const Border(
          top: BorderSide(
            color: Color(0xFF800020),
            width: 6,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course title
          Text(
            "Course Title: ${widget.course["name"]}",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF800020),
            ),
          ),
          const SizedBox(height: 10),

          // Description
          Text(
            widget.course["description"] ?? "",
            style: const TextStyle(fontSize: 15, color: Colors.black87),
          ),
          const SizedBox(height: 20),

          // Requirements list
          Column(
            children: widget.requirements.map((req) {
              return RequirementCard(
                requirement: req,
                onFilePicked: (path) {
                  setState(() {
                    files[req["id"]] = path;
                  });
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 25),

          // Submit button OR loader
          isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF800020),
                  ),
                )
              : ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF800020),
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Submit Requirements",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
        ],
      ),
    );
  }
}



class RequirementCard extends StatefulWidget {
  final Map<String, dynamic> requirement;
  final Function(String path) onFilePicked;

  const RequirementCard({
    super.key,
    required this.requirement,
    required this.onFilePicked,
  });

  @override
  State<RequirementCard> createState() => _RequirementCardState();
}

class _RequirementCardState extends State<RequirementCard> {
  String? selectedFile;
  String? selectedFilePath;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedFile = result.files.single.name;
        selectedFilePath = result.files.single.path!;
      });
      widget.onFilePicked(result.files.single.path!);
    }
  }

  void _removeFile() {
    setState(() {
      selectedFile = null;
      selectedFilePath = null;
    });
    widget.onFilePicked(""); 
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color.fromARGB(127, 255, 255, 255),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
        border: Border.all(color: Colors.black12.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Requirement title
          Text(
            widget.requirement["title"] ?? "",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF800020),
            ),
          ),
          const SizedBox(height: 10),

          // Description
          Text(
            widget.requirement["description"] ?? "",
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 15),

          // File input style
          Row(
            children: [
              ElevatedButton(
                onPressed: _pickFile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF800020),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: Text(
                  selectedFile == null ? "Choose File" : "Change",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 10),

              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black26),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    selectedFile ?? "No file chosen",
                    style: TextStyle(
                      color: selectedFile == null
                          ? Colors.black45
                          : Colors.black87,
                    ),
                  ),
                ),
              ),

              if (selectedFile != null) ...[
                const SizedBox(width: 10),
                IconButton(
                  onPressed: _removeFile,
                  icon: const Icon(Icons.close, color: Colors.red),
                  tooltip: "Remove file",
                ),
              ]
            ],
          ),
        ],
      ),
    );
  }
}
