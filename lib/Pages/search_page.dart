import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:syncify_final/SongPlayer/song.dart';
import 'package:syncify_final/SongPlayer/song_player.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Song> allSongs = []; // All songs fetched from Firestore
  List<Song> filteredSongs = []; // Filtered songs based on the search query
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchSongs();
  }

  void fetchSongs() async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await firestore.collection('songs').get();

    List<Song> fetchedSongs = snapshot.docs.map((doc) {
      return Song(
        id: doc.id,
        title: doc['title'],
        artist: doc['artist'],
        duration: doc['duration'],
        album: doc['album'],
      );
    }).toList();

    setState(() {
      allSongs = fetchedSongs; // Store all songs
      filteredSongs = allSongs; // Initially show all songs
    });
  }

  void _filterSongs(String query) {
    List<Song> filtered = allSongs.where((song) {
      return song.title.toLowerCase().contains(query.toLowerCase()) ||
          song.artist.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredSongs = filtered;
    });
  }

  Future<void> addToLikes(String songId) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;

      QuerySnapshot<Map<String, dynamic>> wishlistQuery = await firestore
          .collection('likelists')
          .where('userId', isEqualTo: userId)
          .where('songId', isEqualTo: songId)
          .limit(1)
          .get();

      if (wishlistQuery.docs.isEmpty) {
        await firestore.collection('likelists').add({
          'userId': userId,
          'songId': songId,
          'addedAt': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Song added to wishlist')));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Song is already in the wishlist')));
      }
    } else {
      print("User not logged in");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set the background color to black
      appBar: AppBar(
        title: Text('Search Songs',
          style: TextStyle(
            color: Colors.white, // Set duration text color to white
          ),),
        backgroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // Search field
              TextField(
                controller: _searchController,
                onChanged: (value) {
                  _filterSongs(value.trim());
                },
                style: TextStyle(color: Colors.white), // Set input text color to white
                decoration: InputDecoration(
                  labelText: 'Search Songs',
                  labelStyle: TextStyle(color: Colors.white), // Label text color to white
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white), // Border color to white
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white), // Border color when focused
                  ),
                  prefixIcon: Icon(Icons.search, color: Colors.white), // Icon color to white
                ),
              ),
              SizedBox(height: 20),
              // Display the filtered list of songs
              Expanded(
                child: _songs(filteredSongs, addToLikes),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Reuse the _songs widget for the search page, same as in home.dart
Widget _songs(List<Song> songs, Function(String) addToLikes) {
  return ListView.separated(
    itemBuilder: (context, index) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SongPlayer(songId: songs[index].id),
                ),
              );
            },
            child: Row(
              children: [
                Container(
                  height: 45,
                  width: 45,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade800,
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: const Color(0xff959595),
                  ),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      songs[index].title,
                      style: TextStyle(
                        color: Colors.white, // Set song title color to white
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      songs[index].artist,
                      style: TextStyle(
                        color: Colors.white, // Set artist name color to white
                        fontWeight: FontWeight.w100,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              Text(
                songs[index].duration.toString().replaceAll('.', ':'),
                style: TextStyle(
                  color: Colors.white, // Set duration text color to white
                ),
              ),
              IconButton(
                onPressed: () {
                  addToLikes(songs[index].id);
                },
                icon: Icon(Icons.add, color: Colors.white), // Add icon color to white
              ),
            ],
          ),
        ],
      );
    },
    separatorBuilder: (context, index) => const SizedBox(height: 18),
    itemCount: songs.length,
  );
}