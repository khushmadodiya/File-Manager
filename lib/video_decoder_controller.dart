// import 'package:flutter/material.dart';
// import 'package:fvp/fvp.dart';
//
//
// class VideoDecoderController extends ChangeNotifier {
//   Fvp? _player;
//   int? _textureId;
//   bool _isConnected = false;
//   String _status = "Idle";
//
//   // Getters for UI
//   int? get textureId => _textureId;
//   bool get isConnected => _isConnected;
//   String get status => _status;
//
//   Future<void> initialize() async {
//     // Register the FVP plugin with Flutter's video texture system
//     registerWith();
//   }
//
//   Future<void> startListening(int port) async {
//     if (_isConnected) await stop();
//
//     _updateStatus("Initializing Player...");
//
//     try {
//       _player = Fvp();
//
//       // 1. Set the URL. using @ to bind to all interfaces
//       // 'udp://@:5000' is the standard way to listen in ffmpeg
//       final url = 'udp://@:$port';
//
//       // 2. CRITICAL: Set low-latency flags (Matches your ffplay command)
//       // These map directly to FFmpeg options
//       _player!.setProperty('avdict', 'flags', 'low_delay');
//       _player!.setProperty('avdict', 'fflags', 'nobuffer');
//       _player!.setProperty('avdict', 'probesize', '32'); // Start immediately
//       _player!.setProperty('avdict', 'analyzeduration', '0');
//       _player!.setProperty('avdict', 'format', 'h264'); // Hint the format
//       _player!.setProperty('avdict', 'protocol_whitelist', 'file,udp,rtp');
//
//       // 3. Create the texture
//       _textureId = await _player!.createTexture();
//
//       // 4. Start the stream
//       await _player!.setMedia(url);
//       await _player!.play();
//
//       _isConnected = true;
//       _updateStatus("Listening on Port $port (UDP)...");
//       notifyListeners();
//
//     } catch (e) {
//       _updateStatus("Error: $e");
//       stop();
//     }
//   }
//
//   Future<void> stop() async {
//     if (_player != null) {
//       await _player!.stop();
//       _player = null; // Fvp disposes internally on stop/release usually
//     }
//     _textureId = null;
//     _isConnected = false;
//     _updateStatus("Stopped");
//     notifyListeners();
//   }
//
//   void _updateStatus(String msg) {
//     _status = msg;
//     notifyListeners();
//   }
// }