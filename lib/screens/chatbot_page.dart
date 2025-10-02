
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../widgets/base_layout.dart';

class ChatbotPage extends StatefulWidget {
  final String firstName;

  const ChatbotPage({super.key, required this.firstName});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> messages = [];

  void sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      messages.add({"message": _controller.text.trim(), "bot": false});
      messages.add({
        "message": "Thanks for your message! I’ll get back to you on that.",
        "bot": true
      });
    });

    _controller.clear();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double boxWidth = MediaQuery.of(context).size.width > 1000
        ? 750
        : MediaQuery.of(context).size.width * 0.95;

    return BaseLayout(
      isLoggedIn: true,
      activeRoute: '/chatbot',
      child: Center(
        child: Container(
          width: boxWidth,
          margin: const EdgeInsets.all(5),
          child: Column(
            mainAxisSize: MainAxisSize.min, 
            children: [
              // Chat Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                decoration: BoxDecoration(
                  color: const Color(0xFF800020),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    FaIcon(FontAwesomeIcons.robot,
                        color: Color(0xFFB8860B), size: 22),
                    const SizedBox(width: 15),
                    const Text(
                      "Chatbot Support",
                      style: TextStyle(
                        color: Color(0xFFF9FAFB),
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Chat Area
              Container(
                constraints: const BoxConstraints(maxHeight: 500), 
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _MessageBubble(
                        message:
                            "Hello ${widget.firstName}!👋 I’m your Sagely assistant. How can I help you today?",
                        bot: true,
                      );
                    }
                    final msg = messages[index - 1];
                    return _MessageBubble(
                      message: msg["message"],
                      bot: msg["bot"],
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),

              // Input + Send Button
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 4)
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: "Type your message...",
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: sendMessage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF800020),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const FaIcon(
                      FontAwesomeIcons.paperPlane,
                      color: Color(0xFFF9FAFB),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String message;
  final bool bot;

  const _MessageBubble({required this.message, required this.bot});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: bot ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: bot
              ? const Color.fromARGB(30, 128, 0, 32)
              : const Color(0xFF800020),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message,
          style: TextStyle(
            color: bot ? const Color(0xFF800020) : const Color(0xFFF9FAFB),
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
