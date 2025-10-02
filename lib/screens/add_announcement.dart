import 'package:flutter/material.dart';
import '../widgets/manage_announcement.dart';

class AddAnnouncementPage extends StatelessWidget {
  final bool isAdmin;

  const AddAnnouncementPage({super.key, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    return ManageAnnouncementPage(
      announcementId: null, 
      isAdmin: isAdmin,
    );
  }
}