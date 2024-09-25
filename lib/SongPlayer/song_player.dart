import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncify_final/SongPlayer/AudioPlayerService.dart';

class SongPlayer extends StatefulWidget {
  final String songId; // Add songId parameter

  const SongPlayer({required this.songId, Key? key}) : super(key: key);

  @override
  _SongPlayerState createState() => _SongPlayerState();
}

class _SongPlayerState extends State<SongPlayer> {
  String? songUrl; // URL for the song
  String? coverUrl; // URL for the cover image
  String? title; // Title of the song
  String? album; // Album of the song
  String? artist; // Artist of the song
  bool isLoading = false; // To control the play button loader
  bool isPlaying = false; // To control play/pause state
  Duration currentPosition = Duration.zero; // Current position of the song
  Duration ? songDuration; // Duration of the song

  @override
  void initState() {
    super.initState();
    fetchSongDetails(widget.songId); // Use the provided songId to fetch details
    if (AudioPlayerService().isPlaying()) {
      AudioPlayerService().stop(); // Stop previous song if playing
    }

    // Listen for audio player position updates
    AudioPlayerService().onAudioPositionChanged.listen((duration) {
      setState(() {
        currentPosition = duration;
      });
    });
    // Listen for audio player duration updates
    AudioPlayerService().onDurationChanged.listen((duration) {
      setState(() {
        songDuration = duration;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Fetch the song details from Firestore using songId
  Future<void> fetchSongDetails(String songId) async {
    try {
      DocumentSnapshot songSnapshot = await FirebaseFirestore.instance
          .collection('songs')
          .doc(songId) // Directly use songId here
          .get();

      if (songSnapshot.exists) {
        // Extract song data from the document
        final songData = songSnapshot.data() as Map<String, dynamic>;

        // Extract relevant fields
        songUrl = songData['songurl'];
        title = songData['title'];
        album = songData['album'];
        artist = songData['artist'];
        coverUrl = songData['songimg']; // Assuming songimg is an image URL

        // Convert double duration to Duration object
        double durationInMinutes = songData['duration']; // This should be your double value
        int minutes = durationInMinutes.toInt();
        int seconds = ((durationInMinutes - minutes) * 60).round();
        songDuration = Duration(minutes: minutes, seconds: seconds);

        if (isPlaying) {
          await AudioPlayerService().stop();
          setState(() {
            isPlaying = false;
          }); // Stop the currently playing song
        }
        // Play the song if songUrl is available
        if (songUrl != null) {
          fetchSongUrl(songUrl!);
        }
      } else {
        print('Song not found');
      }
    } catch (e) {
      print('Error fetching song details: $e');
    }
  }

  // Fetches the song URL and plays it
  Future<void> fetchSongUrl(String url) async {
    setState(() {
      isLoading = true; // Show loader on play button
    });

    try {
      // Play the song
      await AudioPlayerService().play(url);
      setState(() {
        isLoading = false; // Hide loader after fetching song
        isPlaying = true; // Mark the song as playing
      });
    } catch (e) {
      setState(() {
        isLoading = false; // Hide loader if there's an error
      });
      print('Error playing song: $e');
    }
  }

  // Play/Pause functionality
  void togglePlayPause() {
    if (isPlaying) {
      AudioPlayerService().pause();
      setState(() {
        isPlaying = false;
      });
    } else {
      if (songUrl != null) {
        fetchSongUrl(songUrl!);
      }
    }
  }

  // Seek to a specific position
  void seekTo(double value) {
    final newPosition = Duration(milliseconds: value.toInt());
    AudioPlayerService().seek(newPosition);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: Text(
          'Song Player',
          style: TextStyle(color: Colors.white), // Set title color to white
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white), // Set back button color to white
      ),
      backgroundColor: Colors.black, // Set background color to black
      body: songUrl == null
          ? Center(child: CircularProgressIndicator()) // Show loader while fetching songs
          : Center( // Wrap the Column with Center to align it in the center
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center the Column's children vertically
          crossAxisAlignment: CrossAxisAlignment.center, // Center the Column's children horizontally
          children: [
            // Display cover image if available
            coverUrl != null
                ? Image.network(
              coverUrl!,
              width: 230,
              height: 230,
              fit: BoxFit.cover,
            )
                : Container(
              width: 200,
              height: 200,
              color: Colors.grey,
              child: Icon(Icons.music_note, size: 100),
            ),
            SizedBox(height: 20),

            // Display song info
            Center( // Center the title
              child: Text(
                title ?? 'Unknown Title',
                style: TextStyle(fontSize: 24, color: Colors.white), // Set text color to white
              ),
            ),
            Center( // Center the album
              child: Text(
                album ?? 'Unknown Album',
                style: TextStyle(fontSize: 20, color: Colors.grey), // Set text color to white
              ),
            ),
            Center( // Center the artist
              child: Text(
                artist ?? 'Unknown Artist',
                style: TextStyle(fontSize: 18, color: Colors.grey), // Set text color to white
              ),
            ),
            SizedBox(height: 20),

            // Seek bar
            Slider(
              activeColor: Colors.white,
              inactiveColor: Colors.grey,
              value: currentPosition.inMilliseconds.toDouble(),
              min: 0,
              max: songDuration?.inMilliseconds.toDouble() ?? 0,
              onChanged: (value) {
                setState(() {
                  currentPosition = Duration(milliseconds: value.toInt());
                });
                seekTo(value);
              },
            ),

            // Control buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Previous song button
                IconButton(
                  icon: Icon(Icons.skip_previous),
                  onPressed: (){},
                  iconSize: 48,
                ),
                IconButton(
                  icon: isLoading
                      ? CircularProgressIndicator()
                      : Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 48,
                    color: Colors.white, // Set icon color to white
                  ),
                  onPressed: togglePlayPause,
                ),
                IconButton(
                  icon: Icon(Icons.skip_next),
                  onPressed: (){},
                  iconSize: 48,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
