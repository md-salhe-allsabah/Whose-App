import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    required this.message,
    required this.UserName, // Fixed: Added missing comma here
    this.isMe = false,
    super.key,
  });

  final bool isMe;
  final String message;
  final String UserName;

  @override
  Widget build(BuildContext context) {
    final maxBubbleWidth = MediaQuery.of(context).size.width * 0.75;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        constraints: BoxConstraints(maxWidth: maxBubbleWidth),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: !isMe
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFE3F2FD), 
                    Color(0xFFBBDEFB), 
                  ],
                )
              : null,
          color: isMe ? const Color(0xFFF1F5F9) : null,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          border: isMe 
              ? Border.all(color: const Color(0xFFE2E8F0), width: 0.5)
              : null,
        ),
        // Re-introduced Column to stack UserName and Message vertically
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Only renders the username if the message is from someone else
            if (!isMe) ...[
              Text(
                UserName,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1565C0), // Darker vibrant blue for identity
                ),
              ),
              const SizedBox(height: 4), // Small gap between name and message
            ],
            Text(
              message,
              style: TextStyle(
                fontSize: 15,
                height: 1.4,
                color: isMe ? const Color(0xFF475569) : const Color(0xFF0D47A1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
