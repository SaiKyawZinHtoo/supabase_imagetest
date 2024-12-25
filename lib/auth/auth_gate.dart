import 'package:flutter/material.dart';
import 'package:image_test/pages/login_page.dart';
import 'package:image_test/pages/profile_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        //Listen to the auth state change
        stream: Supabase.instance.client.auth.onAuthStateChange,

        //Build appropriate widget based on the auth state
        builder: (context, snapshot) {
          //Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          //check if there is a valid session currently
          final session = snapshot.hasData ? snapshot.data!.session : null;
          if (session != null) {
            return ProfilePage();
          } else {
            return LoginPage();
          }
        });
  }
}
