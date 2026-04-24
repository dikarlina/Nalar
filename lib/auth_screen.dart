import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'dashboard_admin.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLoginMode = true;
  bool isEmailEntered = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void toggleMode() {
    setState(() {
      isLoginMode = !isLoginMode;
      isEmailEntered = false;
      emailController.clear();
      passwordController.clear();
    });
  }

  void handleAction() {
    if (!isEmailEntered) {
      if (emailController.text.contains('@')) {
        setState(() => isEmailEntered = true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid email')),
        );
      }
    } else {
      final email = emailController.text.trim();

      // cek admin
      if (email == "mauvesagara@gmail.com") {
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
    }
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

              Image.asset('assets/logo1.png', height: screenHeight * 0.2),

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
                    ? 'Enter your email to login'
                    : 'Enter your email to sign up',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),

              const SizedBox(height: 25),

              TextField(
                controller: emailController,
                readOnly: isEmailEntered,
                decoration: InputDecoration(
                  hintText: 'email@domain.com',
                  filled: true,
                  fillColor: isEmailEntered ? Colors.grey[100] : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              if (isEmailEntered) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: handleAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF327CA0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    isEmailEntered
                        ? (isLoginMode ? 'Login' : 'Sign Up')
                        : 'Continue',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),
              const Text("or", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 15),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: Image.asset('assets/google.png', height: 20),
                  label: const Text(
                    'Continue with Google',
                    style: TextStyle(color: Colors.black87),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFF5F5F5),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              GestureDetector(
                onTap: toggleMode,
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black, fontSize: 13),
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
