
import 'package:flutter/material.dart';
import '../widgets/header.dart';
import '../widgets/sidebar.dart';
import '../widgets/footer.dart';

class BaseLayout extends StatelessWidget {
  final Widget child;
  final String activeRoute;
  final bool isLoggedIn;

  const BaseLayout({
    super.key,
    required this.child,
    required this.activeRoute,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Sidebar(
        isLoggedIn: isLoggedIn,
        activeRoute: activeRoute,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Header(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: child,
                    ),
                    const SizedBox(height: 20),
                     Footer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
