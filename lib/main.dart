import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'auth_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Supabase.initialize(
    url: 'https://bxqycvzutmloiuszdrtx.supabase.co',
    anonKey: 'sb_publishable_6B1xzgl5KURFpQinkntgkw_OT8Hh1kN',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NALAR',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F9FB),

        // ── Font lebih menarik, berlaku otomatis ke semua Text() ──
        // karena TextStyle di seluruh app tidak set fontFamily sendiri.
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          Theme.of(context).textTheme,
        ),

        // ── Transisi antar halaman jadi halus (slide + fade) ──
        // berlaku ke semua Navigator.push(MaterialPageRoute(...))
        // yang sudah ada di seluruh app, tanpa perlu diubah satu-satu.
        pageTransitionsTheme: PageTransitionsTheme(
          builders: const {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      home: const AuthScreen(),
    );
  }
}