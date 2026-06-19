import 'package:chat_app/colors/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

final _firebase = FirebaseAuth.instance;

class OnboardScreen extends StatefulWidget {
  const OnboardScreen({super.key});

  @override
  State<OnboardScreen> createState() => _OnboardScreenState();
}

class _OnboardScreenState extends State<OnboardScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isValidating = false;
  // ignore: prefer_final_fields
  bool _signUp = true;

  // onboarding data ====================================================
  String? _email;
  String? _password;
  String? _userName;
  // onboarding data ====================================================

  // input fields controller ===================================================================================
  final _emailInputController = TextEditingController();
  final _passwordInputController = TextEditingController();
  final _userNameInputController = TextEditingController();

  @override
  void dispose() {
    // Always clean up your controllers!
    _emailInputController.dispose();
    _passwordInputController.dispose();
    _userNameInputController.dispose();
    super.dispose();
  }
  // input fields controller ===================================================================================

  // sign up and login ======================================================================

  void _toggleMode() {
    setState(() {
      _signUp = !_signUp;
    });
  }

  Future<void> _submitAuth() async {
    if (_isValidating) return;

    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;

    setState(() {
      _isValidating = true;
    });

    try {
      if (_signUp) {
        // Sign up a new user
        final response = await _firebase.createUserWithEmailAndPassword(
          email: _email!,
          password: _password!,
        );

        final userId = response.user!.uid;

        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'userName': _userName!,
          'userEmail': _email!,
        });
        debugPrint('Signup Success: ${response.user!.uid}');
      } else {
        // Log in an existing user
        final response = await _firebase.signInWithEmailAndPassword(
          email: _email!,
          password: _password!,
        );
        debugPrint('Login Success: ${response.user?.uid}');
      }
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message ?? 'Authentication failed.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isValidating = false;
        });
      }
    }
  }
  // sign up and login ======================================================================

  // vaLidators ================================================================================================
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'please fill this field';
    } else if (!value.trim().contains('@')) {
      return 'please enter valid email';
    } else {
      return null;
    }
  }

  String? _validateUserName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'please fill this field';
    } else if (value.trim().length <= 3) {
      return 'user name must be of 4+ characters';
    } else {
      return null;
    }
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'please fill this field';
    } else if (value.trim().length <= 8) {
      return 'password must be of 9+ characters';
    } else {
      return null;
    }
  }

  Future<void> _validateAndSave() async {
    final isValid = _formKey.currentState!.validate();
    debugPrint('isValid : ${isValid.toString()}');

    if (isValid) {
      _formKey.currentState!.save();
      debugPrint('email : $_email');
      debugPrint('password : $_password');
      debugPrint('userName : $_userName');

      await _submitAuth();

      debugPrint('submitted');
    }
  }

  // vaLidators ===================================================================================================

  // saving data ============================================================================================
  void _saveEmail(String? email) {
    _email = email;
  }

  void _savePassword(String? password) {
    _password = password;
  }

  void _saveUserName(String? userName) {
    _userName = userName;
  }
  // saving data =============================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Expanded(
          child: Container(
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/backgroundImage.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Whose'App",
                  style: GoogleFonts.bricolageGrotesque(
                    color: AppColors.brandGreen,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.white, // Shadow color and opacity
                        offset: const Offset(2.0, 0.0), // X and Y displacement
                        blurRadius: 0.0,
                      ),
                    ],
                    fontSize: 24,
                  ),
                ),
                Container(
                  height: 300,
                  margin: EdgeInsets.all(20),
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  alignment: Alignment.center,

                  child: _isValidating
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.neutralGray,
                          ),
                        )
                      : Form(
                          key: _formKey,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                TextFormField(
                                  controller: _emailInputController,
                                  validator: _validateEmail,
                                  keyboardType: TextInputType.emailAddress,
                                  cursorColor: AppColors.neutralGray,
                                  onSaved: _saveEmail,
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    hintText: 'user123@gmail.com',
                                    labelStyle: TextStyle(
                                      color: AppColors.neutralGray,
                                    ),

                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        width: 1,
                                        color: AppColors.neutralGray,
                                      ),
                                    ),

                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        width: 1,
                                        color: AppColors.neutralGray,
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(height: 20),

                                TextFormField(
                                  controller: _passwordInputController,
                                  validator: _validatePassword,
                                  onSaved: _savePassword,
                                  cursorColor: AppColors.neutralGray,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    hintText: 'name@123',
                                    labelStyle: TextStyle(
                                      color: AppColors.neutralGray,
                                    ),

                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        width: 1,
                                        color: AppColors.neutralGray,
                                      ),
                                    ),

                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        width: 1,
                                        color: AppColors.neutralGray,
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(height: 20),

                                if (_signUp)
                                  TextFormField(
                                    controller: _userNameInputController,
                                    validator: _validateUserName,
                                    onSaved: _saveUserName,
                                    cursorColor: AppColors.neutralGray,

                                    decoration: InputDecoration(
                                      labelText: 'User Name',
                                      hintText: 'Gandalf',
                                      labelStyle: TextStyle(
                                        color: AppColors.neutralGray,
                                      ),

                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          width: 1,
                                          color: AppColors.neutralGray,
                                        ),
                                      ),

                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          width: 1,
                                          color: AppColors.neutralGray,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                ),
                Column(
                  children: [
                    FilledButton(
                      onPressed: _validateAndSave,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.brandGreen,
                      ),
                      child: _isValidating
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _signUp
                                    ? Text("Signing you in")
                                    : Text("Logging you in"),
                                SizedBox(width: 10),
                                LoadingAnimationWidget.waveDots(
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ],
                            )
                          : _signUp
                          ? Text("Sign-in")
                          : Text("Log-in"),
                    ),

                    SizedBox(height: 10),

                    TextButton.icon(
                      onPressed: _toggleMode,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.neutralGray,
                        backgroundColor: Colors.transparent,
                        overlayColor: Colors.transparent,
                      ),
                      label: _signUp
                          ? Text("Are you a registered User?")
                          : Text("Are you a new User?"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
