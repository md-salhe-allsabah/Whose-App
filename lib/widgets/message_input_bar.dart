import 'package:chat_app/colors/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 1. REQUIRED: For accessing LogicalKeyboardKey

class MessageInputBar extends StatefulWidget {
  const MessageInputBar({super.key});

  @override
  State<MessageInputBar> createState() => _MessageInputBarState();
}

class _MessageInputBarState extends State<MessageInputBar> {
  final _messageInputController = TextEditingController();
  bool _doesMessagePayloadExists = false;

  @override
  void dispose() {
    _messageInputController.dispose();
    super.dispose();
  }

  void _submitMessage() async {
    final message = _messageInputController.text.trim();
    debugPrint(message);

    if (message.isEmpty) return;

    _messageInputController.clear();
    setState(() {
      _doesMessagePayloadExists = false;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return; 
      final userId = user.uid;

      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!userSnapshot.exists || userSnapshot.data() == null) return;
      final userName = userSnapshot.data()!['userName'] ?? 'Anonymous';

      FirebaseFirestore.instance.collection('chats').add({
        'message': message,
        'sentAt': Timestamp.now(),
        'userId': userId,
        'userName': userName,
      });
    } catch (e) {
      debugPrint("Failed to send message: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // 2. Added CallbackShortcuts to bind the physical Enter key to _submitMessage
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.enter): _submitMessage,
      },
      // 3. Focus widget keeps the keyboard listener active for this widget layout block
      child: Focus(
        child: Container(
          margin: const EdgeInsets.all(0),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColors.neutralGray.withAlpha(50), width: 1)
            )
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 1,
                  maxLines: 3,
                  controller: _messageInputController,
                  cursorColor: AppColors.darkBubble,
                  onChanged: (value) {
                    final isTextPresent = value.trim().isNotEmpty;
                    if (isTextPresent) {
                      setState(() {
                        _doesMessagePayloadExists = true;
                      });
                    } else {
                      setState(() {
                        _doesMessagePayloadExists = false;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'Write message here...', 
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: AppColors.darkBubble,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(
                        width: 2,
                        color: AppColors.darkBubble,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              if (_doesMessagePayloadExists)
                IconButton(
                  onPressed: _submitMessage,
                  icon: CircleAvatar(
                    backgroundColor: AppColors.darkHeader.withAlpha(50),
                    radius: 20,
                    child: const Icon(Icons.send_rounded, color: AppColors.darkBubble),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
