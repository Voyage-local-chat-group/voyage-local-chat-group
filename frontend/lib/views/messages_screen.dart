import 'package:flutter/material.dart';
import '../palette.dart';

class MessagesScreen extends StatefulWidget {
	const MessagesScreen({super.key});

	@override
	State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  // Mock messages for UI demonstration
  final List<Map<String, dynamic>> _mockMessages = [
    {"text": "Hey everyone! Anyone going to the park later?", "isMe": false, "sender": "Alice"},
    {"text": "I might go around 5 PM if the weather holds up.", "isMe": false, "sender": "Bob"},
    {"text": "Sounds good! I'll see you there then.", "isMe": true, "sender": "Me"},
    {"text": "Awesome, don't forget the frisbee!", "isMe": false, "sender": "Alice"},
    {"text": "Got it in my bag already 😎", "isMe": true, "sender": "Me"},
  ];

  final TextEditingController _msgController = TextEditingController();

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                itemCount: _mockMessages.length,
                itemBuilder: (context, index) {
                  final msg = _mockMessages[index];
                  return _MessageBubble(
                    text: msg['text'],
                    isMe: msg['isMe'],
                    senderName: msg['sender'],
                  );
                },
              ),
            ),
            _buildMessageInput(),
      ],
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: offWhite,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: TextField(
                  controller: _msgController,
                  decoration: const InputDecoration(
                    hintText: "Type a message...",
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 66, 61, 63),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: () {
                  // Non-functional for now
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final String senderName;

  const _MessageBubble({
    required this.text,
    required this.isMe,
    required this.senderName,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4, left: 8, right: 8),
            child: Text(
              senderName,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isMe ? primaryColour : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(isMe ? 20 : 0),
                bottomRight: Radius.circular(isMe ? 0 : 20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              text,
              style: TextStyle(
                color: isMe ? Colors.white : darkGrey,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}