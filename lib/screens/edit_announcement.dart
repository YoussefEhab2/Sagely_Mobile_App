
// EditAnnouncementPage
import 'package:flutter/material.dart';
import '../widgets/manage_announcement.dart';

class EditAnnouncementPage extends StatelessWidget {
  final int announcementId;
  final bool isAdmin;

  const EditAnnouncementPage({
    super.key,
    required this.announcementId,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    return ManageAnnouncementPage(
      announcementId: announcementId,
      isAdmin: isAdmin,
    );
  }
}