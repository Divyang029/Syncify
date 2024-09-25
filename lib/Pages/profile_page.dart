import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:syncify_final/Pages/change_password.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _dpUrl;
  String? _email;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // Load the email and DP from SharedPreferences
  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _dpUrl = prefs.getString('dpUrl');
      _email = prefs.getString('email');
    });
  }

  // Pick an image and upload it to Firebase Storage
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null && _email != null) {
      final file = File(pickedFile.path);

      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_pics/$_email'); // Use email as the filename

        // Upload the file to Firebase Storage
        await storageRef.putFile(file);
        final dpUrl = await storageRef.getDownloadURL();

        // Save DP URL locally
        await _saveDpLocally(dpUrl);

        setState(() {
          _dpUrl = dpUrl;
        });
      } catch (e) {
        print("Error uploading image: $e");
      }
    }
  }

  // Save DP URL to SharedPreferences
  Future<void> _saveDpLocally(String dpUrl) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('dpUrl', dpUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(color: Colors.white), // Set title color to white
        ),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(95, 50, 50, 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child:  CircleAvatar(
                          radius: 80,
                          backgroundImage: _dpUrl != null
                              ? NetworkImage(_dpUrl!)
                              : AssetImage('assets/images/default_dp.jpg')
                                  as ImageProvider,
                        ),
                ),
                SizedBox(height: 16),

                // Display the logged-in user's email
                Text(
                  _email ?? 'Loading email...',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 16),
                SizedBox(height: 16),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(65, 10, 30,15),
            child: ElevatedButton(
              onPressed: () {
                // Navigate to the change password page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangePasswordPage(),
                  ),
                );
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.white24), // Background color
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white), // Text color
              ),
              child: Text('Change Password'),
            ),

          ),
        ],
      ),


    );
  }
}
