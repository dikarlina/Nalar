import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'home_screen.dart';
import 'dashboard_admin.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLoginMode = true;
  bool isLoading = false;
  bool isPasswordVisible = false;

  final TextEditingController nameController = TextEditingController(); // <-- tambahan
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FocusNode nameFocusNode = FocusNode(); // <-- tambahan
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  @override
  void dispose() {
    nameController.dispose(); // <-- tambahan
    emailController.dispose();
    passwordController.dispose();
    nameFocusNode.dispose(); // <-- tambahan
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  void toggleMode() {
    setState(() {
      isLoginMode = !isLoginMode;
      isPasswordVisible = false;
      nameController.clear(); // <-- tambahan
      emailController.clear();
      passwordController.clear();
    });
  }

  Future<void> handleAction() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final name = nameController.text.trim(); // <-- tambahan

    if (!email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid email")),
      );
      return;
    }

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password wajib diisi")),
      );
      return;
    }

    if (!isLoginMode && name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama wajib diisi")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      if (isLoginMode) {
        // LOGIN
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        String userEmail = userCredential.user?.email ?? "";

        if (userEmail == "mauvesagara@gmail.com") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DashboardAdmin()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      } else {
        // REGISTER
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Simpan data user baru ke Firestore dengan field 'nama'
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'nama': name,           // <-- field nama baru
          'email': email,
          'role': 'user',
          'createdAt': Timestamp.now(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Akun berhasil dibuat")),
        );

        setState(() {
          isLoginMode = true;
          isPasswordVisible = false;
          nameController.clear(); // <-- tambahan
          passwordController.clear();
        });
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;

      switch (e.code) {
        case 'user-not-found':
          errorMessage = "Akun tidak ditemukan. Silakan daftar terlebih dahulu.";
          break;
        case 'wrong-password':
          errorMessage = "Password salah. Silakan coba lagi.";
          break;
        case 'invalid-email':
          errorMessage = "Format email tidak valid.";
          break;
        case 'user-disabled':
          errorMessage = "Akun ini telah dinonaktifkan.";
          break;
        default:
          errorMessage = "Terjadi kesalahan: ${e.message}";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }

    setState(() => isLoading = false);
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.05),
              const Text(
                'NALAR',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF327CA0),
                  letterSpacing: 2,
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              Image.asset(
                'assets/logo1.png',
                height: screenHeight * 0.2,
              ),
              SizedBox(height: screenHeight * 0.03),
              Text(
                isLoginMode ? 'Login' : 'Create an account',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isLoginMode
                    ? 'Enter your credentials to login'
                    : 'Fill in your details to sign up',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 25),

              // Nama field (hanya saat Sign Up)
              if (!isLoginMode) ...[
                _AnimatedTextField(
                  controller: nameController,
                  focusNode: nameFocusNode,
                  hintText: 'Nama lengkap',
                ),
                const SizedBox(height: 12),
              ],

              // Email field
              _AnimatedTextField(
                controller: emailController,
                focusNode: emailFocusNode,
                hintText: 'email@domain.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),

              // Password field
              _AnimatedPasswordField(
                controller: passwordController,
                focusNode: passwordFocusNode,
                hintText: 'Enter your password',
                isVisible: isPasswordVisible,
                onToggleVisibility: () {
                  setState(() => isPasswordVisible = !isPasswordVisible);
                },
              ),
              const SizedBox(height: 20),

              // Action button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: ElevatedButton(
                    onPressed: isLoading ? null : handleAction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF327CA0),
                      disabledBackgroundColor:
                          const Color(0xFF327CA0).withOpacity(0.6),
                      elevation: isLoading ? 0 : 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            isLoginMode ? 'Login' : 'Sign Up',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // Toggle login/register
              GestureDetector(
                onTap: toggleMode,
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                    ),
                    children: [
                      TextSpan(
                        text: isLoginMode
                            ? "Don't have an account yet? "
                            : "Already have an account? ",
                      ),
                      TextSpan(
                        text: isLoginMode ? "Sign Up" : "Login",
                        style: const TextStyle(
                          color: Color(0xFF327CA0),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedTextField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final TextInputType keyboardType;

  const _AnimatedTextField({
    required this.controller,
    required this.focusNode,
    required this.hintText,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<_AnimatedTextField> createState() => __AnimatedTextFieldState();
}

class __AnimatedTextFieldState extends State<_AnimatedTextField> {
  bool isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(() {
      setState(() => isFocused = widget.focusNode.hasFocus);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: const Color(0xFF327CA0).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                )
              ]
            : [],
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        keyboardType: widget.keyboardType,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(color: Colors.grey[400]),
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: Color(0xFF327CA0), width: 1.5),
          ),
        ),
      ),
    );
  }
}

class _AnimatedPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final bool isVisible;
  final VoidCallback onToggleVisibility;

  const _AnimatedPasswordField({
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.isVisible,
    required this.onToggleVisibility,
  });

  @override
  State<_AnimatedPasswordField> createState() =>
      __AnimatedPasswordFieldState();
}

class __AnimatedPasswordFieldState extends State<_AnimatedPasswordField> {
  bool isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(() {
      setState(() => isFocused = widget.focusNode.hasFocus);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: const Color(0xFF327CA0).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                )
              ]
            : [],
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        obscureText: !widget.isVisible,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(color: Colors.grey[400]),
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: Color(0xFF327CA0), width: 1.5),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              widget.isVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey[500],
            ),
            onPressed: widget.onToggleVisibility,
          ),
        ),
      ),
    );
  }
}