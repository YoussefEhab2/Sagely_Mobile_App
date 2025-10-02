import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
   Footer({super.key});

  final Color mainColor = Color(0xFF800020); 
  final Color secondColor = Colors.white;
  final Color thirdColor = Color(0xFFB8860B); 

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: mainColor,
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top section
          LayoutBuilder(builder: (context, constraints) {
            bool isMobile = constraints.maxWidth < 620;
            return Flex(
              direction: isMobile ? Axis.vertical : Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "SAGE",
                      style: TextStyle(
                        fontSize: isMobile ? 25 : 26,
                        fontWeight: FontWeight.bold,
                        color: secondColor,
                      ),
                    ),
                    Text(
                      "L",
                      style: TextStyle(
                        fontSize: isMobile ? 25 : 26,
                        fontWeight: FontWeight.bold,
                        color: thirdColor,
                      ),
                    ),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Text(
                          "Y",
                          style: TextStyle(
                            fontSize: isMobile ? 25 : 26,
                            fontWeight: FontWeight.bold,
                            color: thirdColor,
                          ),
                        ),
                        Positioned(
                          top: isMobile ? -8 : -13,
                          left: isMobile ? 10 : 89,
                          child: Image.asset(
                            "assets/graduate-hat.png",
                            height: isMobile ? 17 : 22,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: isMobile ? 15 : 0),
                // Links
                Wrap(
                  spacing: 20,
                  children: [
                    _footerLink("About"),
                    _footerLink("Contact"),
                    _footerLink("Privacy Policy"),
                    _footerLink("Terms of Service"),
                  ],
                ),
              ],
            );
          }),
          const SizedBox(height: 15),
          // Bottom section
          Text(
            "© 2025 Sagely - Cairo University. All rights reserved.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: secondColor.withOpacity(0.585),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _footerLink(String text) {
    return GestureDetector(
      onTap: () {
      
      },
      child: Text(
        text,
        style: TextStyle(
          color: secondColor,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}
