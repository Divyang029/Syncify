import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:syncify_final/SongPlayer/song.dart';
import 'package:syncify_final/SongPlayer/song_player.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  List<Song> wishlistSongs = [];
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    fetchWishlistSongs();
  }

  void fetchWishlistSongs() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;
      QuerySnapshot<Map<String, dynamic>> snapshot = await firestore.collection('likelists')
          .where('userId', isEqualTo: userId)
          .get();

      List<Song> fetchedSongs = await Future.wait(snapshot.docs.map((doc) async {
        DocumentSnapshot<Map<String, dynamic>> songDoc = await firestore.collection('songs').doc(doc['songId']).get();
        return Song(
          id: songDoc.id,
          title: songDoc['title'],
          artist: songDoc['artist'],
          duration: songDoc['duration'],
          album: songDoc['album'],
        );
      }));

      // Get distinct songs
      fetchedSongs = fetchedSongs.toSet().toList();

      setState(() {
        wishlistSongs = fetchedSongs;
      });
    }
  }

  Future<void> removeFromWishlist(String songId) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;
      QuerySnapshot<Map<String, dynamic>> wishlistQuery = await firestore
          .collection('likelists')
          .where('userId', isEqualTo: userId)
          .where('songId', isEqualTo: songId)
          .limit(1)
          .get();

      if (wishlistQuery.docs.isNotEmpty) {
        DocumentSnapshot<Map<String, dynamic>> wishlistDoc = wishlistQuery.docs.first;
        await firestore.collection('likelists').doc(wishlistDoc.id).delete();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${wishlistSongs.firstWhere((song) => song.id == songId).title} removed from wishlist')));
        fetchWishlistSongs(); // Refresh the wishlist
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: _wishlistSongs(wishlistSongs, removeFromWishlist),
      ),
    );
  }
}

Widget _wishlistSongs(List<Song> songs, Function(String) removeFromWishlist) {
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
          IconButton(
            onPressed: () {
              removeFromWishlist(songs[index].id);
            },
            icon: Icon(Icons.remove), // Use - icon for removing from wishlist
          ),
        ],
      );
    },
    separatorBuilder: (context, index) => const SizedBox(height: 18),
    itemCount: songs.length,
  );
}
