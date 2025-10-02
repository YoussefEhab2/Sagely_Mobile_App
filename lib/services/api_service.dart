
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  //static const String baseUrl = "http://10.0.2.2:8000/api"; 
  //static const String baseUrl = "http://localhost:8000/api";
  static const String baseUrl =
      "http://192.168.12.206:8080/api"; 
  // static const String baseUrl = "https://916c10a15fff.ngrok-free.app/api";

  static String? token;

  ApiService() {
    loadToken(); 
  }

  static Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString("token");
  }

  Future<void> saveToken(String? newToken) async {
    final prefs = await SharedPreferences.getInstance();
    if (newToken != null) {
      await prefs.setString("token", newToken);
    } else {
      await prefs.remove("token");
    }
    token = newToken;
  }

  static Map<String, String> getHeaders({bool withAuth = false}) {
    return {
      "Content-Type": "application/json",
      "Accept": "application/json",
      if (withAuth && token != null) "Authorization": "Bearer $token",
    };
  }

  Future<bool> isAdminUser() async {
    try {
      final user = await getUserOnly();
      if (user == null) return false;

      final role = user["role"]?.toString().toLowerCase() ?? "";
      
      return role == "admin";
    } catch (e) {
      print("Error in isAdminUser: $e");
      return false;
    }
  }

  // ================= AUTH =================
  Future<Map<String, dynamic>> signup(
    String name,
    String email,
    String password,
    String? phone,
  ) async {
    final url = Uri.parse("$baseUrl/signup");
    final response = await http.post(
      url,
      headers: getHeaders(),
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
        "phoneNumber": phone,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      await saveToken(data["token"]);
      return data;
    } else {
      throw Exception("Signup failed: ${response.body}");
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse("$baseUrl/login");
    final response = await http.post(
      url,
      headers: getHeaders(),
      body: jsonEncode({"email": email, "password": password}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      await saveToken(data["token"]);
      return data;
    } else {
      throw Exception("Login failed: ${response.body}");
    }
  }

  Future<void> logout() async {
    final url = Uri.parse("$baseUrl/logout");
    final response = await http.post(url, headers: getHeaders(withAuth: true));
    if (response.statusCode == 200) {
      await saveToken(null); 
    } else {
      throw Exception("Logout failed: ${response.body}");
    }
  }

  Future<Map<String, dynamic>> me() async {
    final url = Uri.parse("$baseUrl/me");
    final response = await http.get(url, headers: getHeaders(withAuth: true));

    if (response.statusCode == 200) {
      return jsonDecode(response.body); 
    } else {
      throw Exception("Fetch me failed: ${response.body}");
    }
  }

  Future<Map<String, dynamic>> getUserOnly() async {
    final data = await me();
    if (data["success"] == true && data["user"] != null) {
      return data["user"]; 
    } else {
      throw Exception("Invalid user response: $data");
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    String? phone,
    bool? emailPref,
    bool? sitePref,
  }) async {
    final url = Uri.parse("$baseUrl/profile/update");
    final response = await http.put(
      url,
      headers: getHeaders(withAuth: true),
      body: jsonEncode({
        "phoneNumber": phone,
        "emailNotificationPreferences": emailPref,
        "siteNotificationPreferences": sitePref,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Update profile failed: ${response.body}");
    }
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    final url = Uri.parse("$baseUrl/change-password");
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "old_password": oldPassword,
        "new_password": newPassword,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        jsonDecode(response.body)["error"] ?? "Failed to change password",
      );
    }
  }

  // ================= ANNOUNCEMENTS =================
  Future<List<dynamic>> getAnnouncements() async {
    final url = Uri.parse("$baseUrl/announcements");
    final response = await http.get(url, headers: getHeaders());

    if (response.statusCode == 200) {
      return jsonDecode(response.body)["announcements"];
    } else {
      throw Exception("Failed to load announcements: ${response.body}");
    }
  }

  Future<Map<String, dynamic>> getAnnouncementById(int id) async {
    final url = Uri.parse("$baseUrl/announcements/$id");
    final response = await http.get(url, headers: getHeaders());

    if (response.statusCode == 200) {
      return jsonDecode(response.body)["announcement"];
    } else {
      throw Exception("Failed: ${response.body}");
    }
  }

  Future<Map<String, dynamic>> createAnnouncement(
    String title,
    String content,
    String? category,
    int? courseId,
  ) async {
    final url = Uri.parse("$baseUrl/announcements");
    final response = await http.post(
      url,
      headers: getHeaders(withAuth: true),
      body: jsonEncode({
        "title": title,
        "content": content,
        "category": category,
        "courseID": courseId,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Create failed: ${response.body}");
    }
  }

  Future<void> editAnnouncement(String id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/announcements/$id'),
      headers: getHeaders(withAuth: true),
      body: jsonEncode(data),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to edit announcement');
    }
  }

  Future<void> deleteAnnouncement(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/announcements/$id'),
      headers: getHeaders(withAuth: true),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete announcement');
    }
  }

  Future<List<dynamic>> getAnnouncementsByCourse(String courseId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/courses/$courseId/announcements'),
      headers: getHeaders(withAuth: true),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load announcements by course');
    }
  }

  // ================= COURSES =================
  Future<List<dynamic>> getCourses() async {
    final url = Uri.parse("$baseUrl/courses");
    final response = await http.get(url, headers: getHeaders());

    if (response.statusCode == 200) {
      return jsonDecode(response.body)["courses"];
    } else {
      throw Exception("Failed to load courses: ${response.body}");
    }
  }

  Future<Map<String, dynamic>> getCourseById(int id) async {
    final url = Uri.parse("$baseUrl/courses/$id");
    final response = await http.get(url, headers: getHeaders());

    if (response.statusCode == 200) {
      return jsonDecode(response.body)["course"];
    } else {
      throw Exception("Failed: ${response.body}");
    }
  }

  Future<Map<String, dynamic>> createCourse(
    String name,
    String description,
  
  ) async {
    final url = Uri.parse("$baseUrl/courses");
    final response = await http.post(
      url,
      headers: getHeaders(withAuth: true), 
      body: jsonEncode({
        "name": name,
        "description": description,
        
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Create course failed: ${response.body}");
    }
  }

  Future<Map<String, dynamic>> updateCourse(
    int id,
    String name,
    String description,
  
  ) async {
    final url = Uri.parse("$baseUrl/courses/$id");
    final response = await http.put(
      url,
      headers: getHeaders(withAuth: true), 
      body: jsonEncode({
        "name": name,
        "description": description,
      
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Update course failed: ${response.body}");
    }
  }

  Future<void> deleteCourse(int id) async {
    final url = Uri.parse("$baseUrl/courses/$id");
    final response = await http.delete(
      url,
      headers: getHeaders(withAuth: true), 
    );

    if (response.statusCode == 200) {
      
      final data = jsonDecode(response.body);
      print(data['message']);
    } else {
      throw Exception("Delete course failed: ${response.body}");
    }
  }

  // ================= ENROLLMENTS =================
  Future<Map<String, dynamic>> enrollInCourse(int courseId) async {
    final url = Uri.parse("$baseUrl/courses/$courseId/enroll");
    final response = await http.post(url, headers: getHeaders(withAuth: true));

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Enroll failed: ${response.body}");
    }
  }

  Future<List<dynamic>> getStudentsByCourse(String courseId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/courses/$courseId/students'),
      headers: getHeaders(withAuth: true),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load students');
    }
  }


  Future<List<dynamic>> getMyEnrolledCourses() async {
    final url = Uri.parse("$baseUrl/course/enrolled");
    final response = await http.get(url, headers: getHeaders(withAuth: true));

    if (response.statusCode == 200) {
      return jsonDecode(response.body)["courses"]; // ترجع list
    } else {
      throw Exception("Failed to load enrolled courses: ${response.body}");
    }
  }


  Future<List<dynamic>> getStudentsOfCourse(int courseId) async {
    final url = Uri.parse("$baseUrl/courses/$courseId/students");
    final response = await http.get(url, headers: getHeaders(withAuth: true));

    if (response.statusCode == 200) {
      return jsonDecode(response.body)["students"];
    } else {
      throw Exception("Failed to load students: ${response.body}");
    }
  }

  
  Future<Map<String, dynamic>> enrollStudentByAdmin(
    int courseId,
    int studentId,
    bool replaceSubmission,
  ) async {
    final url = Uri.parse("$baseUrl/course/$courseId/enroll/$studentId");
    final response = await http.post(
      url,
      headers: getHeaders(withAuth: true),
      body: jsonEncode({"replaceSubmission": replaceSubmission}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Enroll by admin failed: ${response.body}");
    }
  }

  // ================= REQUIREMENTS =================
  Future<List<dynamic>> getRequirementsByCourse(int courseId) async {
    final url = Uri.parse("$baseUrl/courses/$courseId/requirements");
    final response = await http.get(url, headers: getHeaders(withAuth: true));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed: ${response.body}");
    }
  }

  Future<void> storeRequirement(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/requirements'),
      headers: getHeaders(withAuth: true),
      body: jsonEncode(data),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to create requirement');
    }
  }

  Future<void> updateRequirement(String id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/requirements/$id'),
      headers: getHeaders(withAuth: true),
      body: jsonEncode(data),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update requirement');
    }
  }

  Future<void> deleteRequirement(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/requirements/$id'),
      headers: getHeaders(withAuth: true),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete requirement');
    }
  }

  // ----------------- Requirement Submissions -----------------
  Future<void> submitRequirement(String id, String filePath) async {
    var url = Uri.parse('$baseUrl/requirements/$id/submit');

    var request = http.MultipartRequest('POST', url);

    
    final headers = getHeaders(withAuth: true);
    headers.remove('Content-Type');
    request.headers.addAll(headers);

    
    request.files.add(await http.MultipartFile.fromPath('file', filePath));

    request.fields['requirementId'] = id;

    
    var response = await request.send();

    if (response.statusCode != 201) {
      throw Exception(
        'Failed to submit requirement (status: ${response.statusCode})',
      );
    }
  }

  Future<List<dynamic>> getRequirementSubmissions(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/requirements/$id/submissions'),
      headers: getHeaders(withAuth: true),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load submissions');
    }
  }

  Future<List<dynamic>> getSubmissionsByCourse(int courseId) async {
    final url = Uri.parse("$baseUrl/requirements/$courseId/course/submissions");
    final response = await http.get(url, headers: getHeaders(withAuth: true));

    if (response.statusCode == 200) {
      return jsonDecode(response.body)["submissions"];
    } else {
      throw Exception("Failed: ${response.body}");
    }
  }

  // ================= SUBMISSIONS =================
  Future<List<dynamic>> getMySubmissions() async {
    final url = Uri.parse("$baseUrl/me/submissions");
    final response = await http.get(url, headers: getHeaders(withAuth: true));

    if (response.statusCode == 200) {
      return jsonDecode(response.body)["submissions"];
    } else {
      throw Exception("Failed: ${response.body}");
    }
  }

  // ================= NOTIFICATIONS =================
  Future<List<dynamic>> getMyNotifications() async {
    final url = Uri.parse("$baseUrl/notifications/me");
    final response = await http.get(url, headers: getHeaders(withAuth: true));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed: ${response.body}");
    }
  }

  Future<void> notifyCourseStudents(
    String courseId,
    Map<String, dynamic> data,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/courses/$courseId/notify"),
      headers: getHeaders(withAuth: true),
      body: jsonEncode(data),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to notify students');
    }
  }

  Future<void> notifyStudent(
    String studentId,
    Map<String, dynamic> data,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/students/$studentId/notify'),
      headers: getHeaders(withAuth: true),
      body: jsonEncode(data),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to notify student');
    }
  }

  Future<void> markNotificationAsRead(String id) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/notifications/$id/read'),
      headers: getHeaders(withAuth: true),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to mark notification as read');
    }
  }

  Future<void> sendEmailNotification(
    int studentId,
    String subject,
    String message,
  ) async {
    final url = Uri.parse("$baseUrl/notifications/email/$studentId");
    final response = await http.post(
      url,
      headers: getHeaders(withAuth: true),
      body: jsonEncode({"subject": subject, "message": message}),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to send email: ${response.body}");
    }
  }
Future<Map<String, dynamic>> notifyAll({
  required String type,
  required String message,
}) async {
  final url = Uri.parse("$baseUrl/notify/all");

  final response = await http.post(
    url,
    headers: getHeaders(withAuth: true),
    body: jsonEncode({
      "type": type,
      "message": message,
    }),
  );
  

  final data = jsonDecode(response.body);

  if (response.statusCode == 200) {
    return data; 
  } else {
    throw Exception("Notify all failed: ${response.body}");
  }
}
  // ================= DOWNLOADABLE FILES =================
  Future<Map<String, dynamic>> uploadFile(
    int courseId,
    String name,
    String? description,
    String filePath,
  ) async {
    var url = Uri.parse("$baseUrl/courses/$courseId/files");
    var request = http.MultipartRequest("POST", url);

    final headers = getHeaders(withAuth: true);
    headers.remove("Content-Type"); 
    request.headers.addAll(headers);

    request.fields["name"] = name;
    if (description != null) request.fields["description"] = description;

    request.files.add(await http.MultipartFile.fromPath("file", filePath));

    var response = await request.send();
    final respStr = await response.stream.bytesToString();

    if (response.statusCode == 201) {
      return jsonDecode(respStr);
    } else {
      throw Exception("Upload failed: $respStr");
    }
  }

  Future<Map<String, dynamic>> updateFile(
    int courseId,
    int fileId, {
    String? name,
    String? description,
    String? filePath,
  }) async {
    var url = Uri.parse("$baseUrl/courses/$courseId/files/$fileId");
    var request = http.MultipartRequest("PUT", url);

    final headers = getHeaders(withAuth: true);
    headers.remove("Content-Type");
    request.headers.addAll(headers);

    if (name != null) request.fields["name"] = name;
    if (description != null) request.fields["description"] = description;
    if (filePath != null) {
      request.files.add(await http.MultipartFile.fromPath("file", filePath));
    }

    var response = await request.send();
    final respStr = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return jsonDecode(respStr);
    } else {
      throw Exception("Update failed: $respStr");
    }
  }

  Future<void> deleteFile(int courseId, int fileId) async {
    final url = Uri.parse("$baseUrl/courses/$courseId/files/$fileId");
    final response = await http.delete(
      url,
      headers: getHeaders(withAuth: true),
    );

    if (response.statusCode != 200) {
      throw Exception("Delete failed: ${response.body}");
    }
  }

  Future<Map<String, dynamic>> downloadFile(int fileId) async {
    final url = Uri.parse("$baseUrl/files/$fileId/download");
    final response = await http.get(url, headers: getHeaders(withAuth: true));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Download failed: ${response.body}");
    }
  }

  Future<List<dynamic>> getFilesByCourse(int courseId) async {
    final url = Uri.parse("$baseUrl/courses/$courseId/files");
    final response = await http.get(url, headers: getHeaders(withAuth: true));

    if (response.statusCode == 200) {
      return jsonDecode(response.body)["files"];
    } else {
      throw Exception("Failed: ${response.body}");
    }
  }




// Send notification
Future<void> sendNotification(int studentId, String message, String type) async {
  final res = await http.post(
    Uri.parse("$baseUrl/students/$studentId/notify"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "message": message,
      "type": type,
    }),
  );

  if (res.statusCode != 200) {
    throw Exception("Failed to send notification");
  }
}

  // 🔹 Get student submissions
  Future<List<dynamic>> getStudentSubmission(int courseId, int studentId) async {
    final res = await http.get(
      Uri.parse("$baseUrl/courses/$courseId/students/$studentId/submissions"),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Failed to load submissions");
    }
  }

  Future<void> approveSubmission(int courseId, int studentId) async {
  final res = await http.post(
    Uri.parse("$baseUrl/course/$courseId/enroll/$studentId"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"replaceSubmission": true}),
  );

  if (res.statusCode != 200) {
    throw Exception("Failed to approve submission");
  }

  // ✅ Send notification
  await sendNotification(studentId, "Your enrollment request has been approved", "APPROVAL");
}

Future<void> rejectSubmission(int courseId, int studentId) async {
  final res = await http.post(
    Uri.parse("$baseUrl/course/$courseId/enroll/$studentId"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"replaceSubmission": false}),
  );

  if (res.statusCode != 200) {
    throw Exception("Failed to reject submission");
  }

  // ✅ Send notification
  await sendNotification(studentId, "Your enrollment request has been rejected", "REJECTION");
}

}
