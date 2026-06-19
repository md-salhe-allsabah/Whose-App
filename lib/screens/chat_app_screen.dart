import 'package:chat_app/colors/app_colors.dart';
import 'package:chat_app/widgets/message_input_bar.dart';
import 'package:chat_app/widgets/messages_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatAppScreen extends StatefulWidget {
  const ChatAppScreen({super.key});

  @override
  State<ChatAppScreen> createState() => _ChatAppScreenState();
}
class _ChatAppScreenState extends State<ChatAppScreen> {

  void setUpPushNotification() async{
    final fireBaseMessaging = FirebaseMessaging.instance;

    // final token = await fireBaseMessaging.requestPermission() ;
    fireBaseMessaging.subscribeToTopic('chat');
  }

    @override 
  void initState() {
    super.initState() ;

    setUpPushNotification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: AppColors.darkHeader,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.only(
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10),
          )
        ),
        title: Text(
          "Whose'App",
          style: GoogleFonts.bricolageGrotesque(
            color: AppColors.brandGreen,
            fontWeight: FontWeight.bold,
            fontSize: 24,
            shadows: [
              Shadow(
                color: AppColors.lightBubble, // Shadow color and opacity
                offset: const Offset(1.0, 0.0), // X and Y displacement
                blurRadius: 0.0,
              ),
            ],
          ),
        ),

        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: const Icon(
              Icons.logout_rounded,
              color: AppColors.lightBubble,
              size: 24,
            ),
          ),
        ],
      ),
      // 1. Removed Center widget to let Container expand fully
      body: Container(
        // Use double.infinity to make sure background fills the whole screen
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            // 2. Fixed Image.asset usage inside DecorationImage
            image: AssetImage('assets/backgroundImage.jpg'),
            fit: BoxFit.cover, // Makes image fill screen beautifully
          ),
        ),
        child: Column(
          // 3. Removed MainAxisSize.min so Expanded can function properly
          children: const [
            Expanded(child: MessagesWidget()),
            MessageInputBar(),
          ],
        ),
      ),
    );
  }
}
