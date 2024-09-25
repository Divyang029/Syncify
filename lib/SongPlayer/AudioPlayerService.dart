import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Streams to listen for position and duration changes
  final Stream<Duration> onAudioPositionChanged = AudioPlayer().onPositionChanged;
  final Stream<Duration> onDurationChanged = AudioPlayer().onDurationChanged;

  factory AudioPlayerService() {
    return _instance;
  }

  AudioPlayerService._internal();

  Future<void> play(String url) async {
    await _audioPlayer.play(UrlSource(url));
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  bool isPlaying() {
    return _audioPlayer.state == PlayerState.playing;
  }

  // Seek to a specific position
  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  // Get the current position of the audio
  Future<Duration> getCurrentPosition() async {
    Duration? position = await _audioPlayer.getCurrentPosition();
    return position ?? Duration.zero; // Return Duration.zero if null
  }

// Get the duration of the audio
  Future<Duration> getDuration() async {
    Duration? duration = await _audioPlayer.getDuration();
    return duration ?? Duration.zero; // Return Duration.zero if null
  }
}
