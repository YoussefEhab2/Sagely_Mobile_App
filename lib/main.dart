
import 'package:flutter/material.dart';
 import 'screens/signup_page.dart';
 import 'screens/courses.dart';
 import 'screens/login_page.dart';
 import 'screens/profile_page.dart'; 
import 'screens/announcements_page.dart';
import 'screens/chatbot_page.dart';
import 'screens/home_page.dart';
import 'screens/Notifications_Page.dart';
import 'services/api_service.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService.loadToken();
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    
    

    return MaterialApp(
      title: 'Announcements App',
      debugShowCheckedModeBanner: false,
      
      initialRoute: "/",
      routes: {
          "/": (context) => HomePage(),
         "/announcements": (context) => AnnouncementsPage(),
        "/courses": (context) => CoursesPage(),
        // "/files": (context) => FilesPage(),
         "/notifications": (context) => NotificationsPage(),
         "/chatbot": (context) => ChatbotPage(firstName: "Sara"),
        "/profile": (context) => ProfilePage(),
        "/login_page": (context) => LoginPage(),
        
      },
    
      theme: ThemeData(
        primaryColor: const Color(0xFF800020),
        scaffoldBackgroundColor: const Color(0xFFF6F6F7),
        fontFamily: 'Roboto',
      ),
    // home:LoginPage(),
    );
  }
}
