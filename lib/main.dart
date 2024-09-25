import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:syncify_final/Authentication/login.dart';
import 'package:syncify_final/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncify_final/home.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

Future<Widget> checkLoginStatus() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  if (isLoggedIn) {
    // Return HomeScreen if the user is already logged in
    return HomeScreen();
  } else {
    // Return LoginPage if the user is not logged in
    return LoginPage();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<Widget>(
        future: checkLoginStatus(),  // Call the function to check login status
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading indicator while checking login status
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            // Return the appropriate screen based on login status
            return snapshot.data!;
          } else {
            // Fallback in case of an error (though unlikely)
            return LoginPage();
          }
        },
      ),
    );
  }
}
