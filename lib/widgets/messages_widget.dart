import 'package:chat_app/colors/app_colors.dart';
import 'package:chat_app/widgets/chat_bubbles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final myUserId = FirebaseAuth.instance.currentUser!.uid;

class MessagesWidget extends StatelessWidget {
  const MessagesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chats')
          // 1. CHANGED: order by descending: true so newest messages come first in the array
          .orderBy('sentAt', descending: true)
          .snapshots(),
      builder: (ctx, chatSnapshots) {
        if (chatSnapshots.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty) {
          return const Center(
            child: Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.message_rounded,
                    color: AppColors.brandGreen,
                    size: 32,
                  ),
                  SizedBox(height: 10),
                  Text('No Chats Yet')
                ],
              ),
            ),
          );
        }

        if (chatSnapshots.hasError) {
          return const Center(child: Text('oh oh! something went wrong'));
        }

        final loadedMessages = chatSnapshots.data!.docs;
        final itemCount = loadedMessages.length;

        return ListView.builder(
          // 2. CHANGED: Reverses the list alignment (Index 0 stays at the bottom)
          reverse: true,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          itemCount: itemCount,
          itemBuilder: (ctx, index) {
            final currentMsgData = loadedMessages[index].data();
            final message = currentMsgData['message'] ?? '';
            final uid = currentMsgData['userId'] ?? '';
            final userName = currentMsgData['userName'] ?? 'Anonymous';
            final isMe = uid == myUserId;

            // 3. CHANGED: In a reversed list, the message visually "next" (lower down)
            // is actually at (index - 1) in the descending array.
            final nextVisualMessageData = (index - 1 >= 0)
                ? loadedMessages[index - 1].data()
                : null;
            final nextVisualUserId = nextVisualMessageData != null
                ? nextVisualMessageData['userId']
                : null;
            final bool isLastInSequence = nextVisualUserId != uid;

            final firstLetter = userName.isNotEmpty
                ? userName[0].toUpperCase()
                : '?';

            return Row(
              mainAxisAlignment: isMe
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!isMe)
                  Container(
                    margin: const EdgeInsets.only(right: 8, bottom: 4),
                    child: isLastInSequence
                        ? CircleAvatar(
                            backgroundColor: Colors.blueGrey.shade300,
                            radius: 16,
                            child: Text(
                              firstLetter,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : const SizedBox(width: 32),
                  ),

                // Wrapped in Flexible to prevent long texts from overflowing horizontally
                Flexible(
                  child: ChatBubble(
                    message: message,
                    UserName: userName,
                    isMe: isMe,
                  ),
                ),

                if (isMe)
                  Container(
                    margin: const EdgeInsets.only(left: 8, bottom: 4),
                    child: isLastInSequence
                        ? CircleAvatar(
                            backgroundColor: Colors.blueAccent.shade100,
                            radius: 16,
                            child: Text(
                              firstLetter,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : const SizedBox(width: 32),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
