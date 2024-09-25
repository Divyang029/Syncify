// class Song {
//   final String title;
//   final String artist;
//   final String album;
//   final String albumArt;
//   Song({
//     required this.title,
//     required this.artist,
//     required this.album,
//     required this.albumArt,
//   });
// }

class Song {
  final String id;
  final String title;
  final String artist;
  final num duration;
  final String album;
  // final String albumArt;
  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.duration,
    required this.album,
    // required this.albumArt,
  });
}