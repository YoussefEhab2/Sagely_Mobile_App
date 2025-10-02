

import '../widgets/base_layout.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/api_service.dart';

import '../widgets/confirm_modal.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ApiService api = ApiService();

  String fullName = "";
  String email = "";
  String phone = "";
  bool isLoading = true;

  TextEditingController phoneController = TextEditingController();
  bool isEditingPhone = false;
  String phoneError = "";

  bool showPasswordModal = false;
  TextEditingController oldPassword = TextEditingController();
  TextEditingController newPassword = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
  List<String> passwordErrors = ["", "", ""];

  bool showNotificationModal = false;
  bool emailNotification = true;
  bool siteNotification = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final data = await api.me();
      final user = data["user"];
      setState(() {
        fullName = user["name"] ?? "";
        email = user["email"] ?? "";
        phone = user["phoneNumber"] ?? "";
        emailNotification = user["emailNotificationPreferences"] ?? true;
        siteNotification = user["siteNotificationPreferences"] ?? true;
        phoneController.text = user["phoneNumber"] ?? "";
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching profile: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _savePhone() async {
    try {
      await api.updateProfile(phone: phoneController.text);
      setState(() {
        phone = phoneController.text;
        isEditingPhone = false;
        phoneError = "";
      });
    } catch (e) {
      print("Error updating phone: $e");
    }
  }

  Future<void> _saveNotifications() async {
    try {
      await api.updateProfile(
        emailPref: emailNotification,
        sitePref: siteNotification,
      );
      await _loadUserData();
      setState(() => showNotificationModal = false);
    } catch (e) {
      print("Error updating notifications: $e");
    }
  }

  Future<void> _savePassword() async {
    setState(() {
      passwordErrors = ["", "", ""];
    });

    if (newPassword.text != confirmPassword.text) {
      setState(() => passwordErrors[2] = "Passwords do not match");
      return;
    }

    try {
      await api.changePassword(oldPassword.text, newPassword.text);
      setState(() {
        showPasswordModal = false;
        oldPassword.clear();
        newPassword.clear();
        confirmPassword.clear();
      });
    } catch (e) {
      print("Error changing password: $e");
      setState(() => passwordErrors[0] = "Invalid old password");
    }
  }

  String _getNotificationText() {
    List<String> selected = [];
    if (emailNotification) selected.add("Email");
    if (siteNotification) selected.add("In-App");
    return selected.isEmpty ? "Mute Notifications" : selected.join(", ");
  }

  Widget _buildLabelValue(
    String label,
    String value, {
    bool editable = false,
    TextEditingController? controller,
    String errorText = "",
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 5),
          editable
              ? TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    border: const UnderlineInputBorder(),
                    errorText: errorText.isNotEmpty ? errorText : null,
                    contentPadding: const EdgeInsets.symmetric(vertical: 5),
                  ),
                  keyboardType: TextInputType.phone,
                  style: TextStyle(color: Colors.grey.shade600),
                )
              : Text(
                  value,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return BaseLayout(
      activeRoute: "/profile",
      isLoggedIn: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              fullName.split(" ").take(2).join(" "),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF800020),
              ),
            ),
            const SizedBox(height: 20),

            // Personal Info
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: const [
                            FaIcon(
                              FontAwesomeIcons.userCircle,
                              color: Color(0xFFB8860B),
                            ),
                            SizedBox(width: 10),
                            Text(
                              "Personal Information",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF800020),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            if (isEditingPhone) {
                              if (RegExp(
                                r'^01[0-2,5]{1}[0-9]{8}$',
                              ).hasMatch(phoneController.text)) {
                                _savePhone();
                              } else {
                                phoneError =
                                    "Please enter a valid phone number!";
                              }
                            } else {
                              isEditingPhone = true;
                            }
                          });
                        },
                        icon: FaIcon(
                          isEditingPhone
                              ? FontAwesomeIcons.check
                              : FontAwesomeIcons.edit,
                          size: 14, 
                          color: Color(0xFFB8860B),
                        ),
                        label: Text(
                          isEditingPhone ? "Save" : "Edit",
                          style: TextStyle(fontSize: 14), 
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF800020),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 13,
                            vertical: 8,
                          ), 
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              8,
                            ),
                          ),
                          minimumSize: const Size(
                            0,
                            0,
                          ), 
                          tapTargetSize: MaterialTapTargetSize
                              .shrinkWrap, 
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Full Name
                  _buildLabelValue("Full Name", fullName, editable: false),
                  // Email
                  _buildLabelValue("Email", email, editable: false),
                  // Phone Number
                  _buildLabelValue(
                    "Phone Number",
                    phoneController.text,
                    editable: isEditingPhone,
                    controller: phoneController,
                    errorText: phoneError,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Account Settings
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      FaIcon(FontAwesomeIcons.cog, color: Color(0xFFB8860B)),
                      SizedBox(width: 10),
                      Text(
                        "Account Settings",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF800020),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Password
                  Text(
                    "Password",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: List.generate(
                      8,
                      (index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Text(
                          "•",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  ElevatedButton.icon(
                    icon: const FaIcon(FontAwesomeIcons.key),
                    label: const Text("Change Password"),
                    onPressed: () => setState(() => showPasswordModal = true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF800020),
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Notifications
                  Text(
                    "Notification Preference",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _getNotificationText(),
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 5),
                  ElevatedButton.icon(
                    icon: const FaIcon(FontAwesomeIcons.bell),
                    label: const Text("Manage Notifications"),
                    onPressed: () =>
                        setState(() => showNotificationModal = true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF800020),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Modals
            if (showPasswordModal) _buildPasswordModal(context),
            if (showNotificationModal) _buildNotificationModal(context),
          ],
        ),
      ),
    );
  }

  // Password Modal
  Widget _buildPasswordModal(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () => setState(() => showPasswordModal = false),
          child: Container(color: Colors.black38),
        ),
        Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Reset Password",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF800020),
                  ),
                ),
                const SizedBox(height: 15),
                _buildPasswordField(
                  "Old Password",
                  oldPassword,
                  passwordErrors[0],
                ),
                _buildPasswordField(
                  "New Password",
                  newPassword,
                  passwordErrors[1],
                ),
                _buildPasswordField(
                  "Confirm Password",
                  confirmPassword,
                  passwordErrors[2],
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () =>
                          setState(() => showPasswordModal = false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF800020),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(150, 40),
                      ),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: _savePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF800020),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(150, 40),
                      ),
                      child: const Text("Save"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(
    String label,
    TextEditingController controller,
    String error,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
            obscureText: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              errorText: error.isNotEmpty ? error : null,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Notification Modal
  Widget _buildNotificationModal(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () => setState(() => showNotificationModal = false),
          child: Container(color: Colors.black38),
        ),
        Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Manage Notifications",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF800020),
                  ),
                ),
                const SizedBox(height: 15),
                CheckboxListTile(
                  title: const Text("Email Notifications"),
                  value: emailNotification,
                  onChanged: (val) =>
                      setState(() => emailNotification = val ?? true),
                ),
                CheckboxListTile(
                  title: const Text("In-App Notifications"),
                  value: siteNotification,
                  onChanged: (val) =>
                      setState(() => siteNotification = val ?? true),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () =>
                          setState(() => showNotificationModal = false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF800020),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(150, 40),
                      ),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: _saveNotifications,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF800020),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(150, 40),
                      ),
                      child: const Text("Save"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
