import 'package:flutter/material.dart';
import 'package:image_test/auth/auth_gate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  //supabase setup
  await Supabase.initialize(
    url: 'https://uizfhchubrpxgeqlkkbd.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVpemZoY2h1YnJweGdlcWxra2JkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQ4NDIzMzQsImV4cCI6MjA1MDQxODMzNH0._odU3yGmtJYG55uyzDF6HMOcuTOzCVboz_QaVCi4OvI',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthGate(),
    );
  }
}
