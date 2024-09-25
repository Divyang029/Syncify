import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncify_final/Authentication/login.dart';
import 'package:syncify_final/Pages/home_page.dart';
import 'package:syncify_final/Pages/library_page.dart';
import 'package:syncify_final/Pages/profile_page.dart';
import 'package:syncify_final/Pages/search_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex=0;

  Widget _getWidget(){
    switch(currentIndex){
      case 1:
        return SearchScreen();
      case 2:
        return LibraryPage();
      default:
        return Home();
    }
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear saved login state

    // Navigate back to login page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('S Y N C I F Y',style: TextStyle(color: Colors.white,),),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      drawer: Drawer(
        backgroundColor: Colors.grey.shade900,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              height: 130,
              child: DrawerHeader(
                decoration: BoxDecoration( color: Colors.black87,),
                child: Column(// Wrapping Text and Icon inside a Column
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Navigation Panel',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
              ) ,
            ),
            ListTile(
              leading: Icon(color: Colors.white70, size: 24, Icons.account_circle),
              title: Text('Profile', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
            ),
            ListTile(
              leading: Icon(color: Colors.white70, size: 25, Icons.logout),
              title: Text('Logout', style: TextStyle(color: Colors.white)),
              onTap: _logout, // Logout function
            ),
          ],
        ),
      ),

      body: Container(
        color: Colors.black,
        child: _getWidget(),
      ),
      bottomNavigationBar: Container(
        color: Colors.black,
        padding: EdgeInsets.fromLTRB(0, 18, 0, 0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30,vertical: 5),
          child: GNav(

            backgroundColor: Colors.black,
            color: Colors.white,
            activeColor: Colors.white,
            tabBackgroundColor: Colors.grey.shade900,
            iconSize: 24,
            padding: EdgeInsets.fromLTRB(25,18,25,18),
            gap: 5,
            onTabChange: (index){
              setState(() {
                currentIndex = index;
              });
            },
            tabs: [
              GButton(
                text: 'Home',
                icon: Icons.home_outlined,
              ),
              GButton(
                text: 'Search',
                icon: Icons.search_outlined,
              ),
              GButton(
                text: 'Library',
                icon: Icons.my_library_music_outlined,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
