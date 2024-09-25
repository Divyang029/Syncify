import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:syncify_final/SongPlayer/song.dart';
import 'package:syncify_final/SongPlayer/song_player.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Song> songs = []; // Initialize an empty list for songs
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    fetchSongs();
  }

  void fetchSongs() async {
    // Fetch the songs from Firestore
    QuerySnapshot<Map<String, dynamic>> snapshot = await firestore.collection('songs').get();

    // Map the data from Firestore to your Song class
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
      songs = fetchedSongs; // Update the state with the fetched songs
    });
  }

  Future<void> addToLikes(String songId) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;

      // Check if the song is already in the wishlist
      QuerySnapshot<Map<String, dynamic>> wishlistQuery = await firestore
          .collection('likelists')
          .where('userId', isEqualTo: userId)
          .where('songId', isEqualTo: songId)
          .limit(1)
          .get();

      if (wishlistQuery.docs.isEmpty) {
        // If the song is not in the wishlist, add it
        await firestore.collection('likelists').add({
          'userId': userId,
          'songId': songId,
          'addedAt': FieldValue.serverTimestamp(),
        });

        // Show confirmation message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Song added to wishlist')));
      } else {
        // If the song is already in the wishlist, show a message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Song is already in the wishlist')));
      }
    } else {
      print("User not logged in");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 16, 10, 0),
        child: _songs(songs, addToLikes),
      ),
    );
  }
}

Widget _songs(List<Song> songs, Function(String) addToLikes) {
  return ListView.separated(
    itemBuilder: (context, index) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              // Navigate to the SongPlayer screen, passing the song ID
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
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      songs[index].artist,
                      style: TextStyle(
                        color: Colors.white,
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
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: () {
                  addToLikes(songs[index].id);
                },
                icon: Icon(Icons.add), // Use + icon for adding to wishlist
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
