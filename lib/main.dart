import 'dart:io';
import 'dart:ui';

import 'package:android_to_mac_drop/model/device.dart';
import 'package:android_to_mac_drop/provider/device_file_provider.dart';
import 'package:android_to_mac_drop/screens/drawer.dart';
import 'package:android_to_mac_drop/service/adb_service.dart';
import 'package:android_to_mac_drop/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';

import 'components/dialogue/download_dialogue.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await windowManager.ensureInitialized();
  //
  // // 1. Initialize MediaKit (Crucial step)
  // MediaKit.ensureInitialized();
  //
  // WindowOptions windowOptions = const WindowOptions(
  //   size: Size(1280, 720),
  //   center: true,
  //   title: "UDP Mirror Receiver",
  // );
  //
  // windowManager.waitUntilReadyToShow(windowOptions, () async {
  //   await windowManager.show();
  //   await windowManager.focus();
  // });
  List<Device> devices = [];
  var adbStatus = false;
  try {
    // final res = await AdbService.run(["--version"]);
    devices = await AdbService.getDevices();
    adbStatus = true;
  } catch (e) {
    print("error $e");
    if (e.toString().contains("No such file or directory")) {
      adbStatus = false;
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DeviceFileProvider()),
        // ChangeNotifierProvider(create: (_) => FileItemProvider()),
      ],
      child: ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: ThemeMode.system,
          debugShowCheckedModeBanner: false,
          home: adbStatus ? MobileStyleDrawerScreen(devices: devices) : MyApp(),
        ),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final List<Device> devices = [];
  var logs = "Setting Environment";
@override
  void initState() {
    // TODO: implement initState
  getDevices();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Center(
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.44),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(0.15)),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ListView(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              logs,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void getDevices() async {
    try {
      final res = await AdbService.run(["--version"]);
      print("result version $res");
    } catch (e) {
      print("error $e");
      if (e.toString().contains("No such file or directory")) {
        installAdbWithProgress(
          onLog: (val) {
            logs = "$logs\n $val";
            print(logs);
            setState(() {});
          },
          onFinish: (status) async{
            final devices = await AdbService.getDevices();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => MobileStyleDrawerScreen(devices: devices),
              ),
                  (route) => false,
            );
          },
        );
      }
    }


  }

  Future<void> installAdbWithProgress({
    required void Function(String log) onLog,
    required void Function(bool success) onFinish,
  }) async {
    try {
      final process = await Process.start('brew', [
        'install',
        'android-platform-tools',
      ], runInShell: true);

      // stdout (normal progress)
      process.stdout.transform(SystemEncoding().decoder).listen((data) {
        onLog(data);
      });

      // stderr (warnings/errors)
      process.stderr.transform(SystemEncoding().decoder).listen((data) {
        onLog(data);
      });

      final exitCode = await process.exitCode;
      onFinish(exitCode == 0);
    } catch (e) {
      onLog(e.toString());
      onFinish(false);
    }
  }
}

// class RunMacCmd extends StatefulWidget {
//   const RunMacCmd({super.key});
//
//   @override
//   State<RunMacCmd> createState() => _RunMacCmdState();
// }
//
// class _RunMacCmdState extends State<RunMacCmd> {
//   final TextEditingController _controller = TextEditingController(text: "ls -la");
//   var output ="";
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Column(
//           children: [
//             const Text("Run Mac Cmd"),
//             TextField(
//               controller: _controller,
//             ),
//             SizedBox(height: 20,),
//             Text("Output: ${output}"),
//             SizedBox(height: 20,),
//             ElevatedButton(onPressed: ()async{
//                final output =  AdbService.getDevices();
//                final files = parseLs(output);
//                Navigator.push(context, MaterialPageRoute(builder: (context)=>FileSystemScreen(files: files)));
//             }, child: Text("Run Cmd"))
//           ],
//         ),
//       ),
//     );
//   }
//
//   List<DeviceFile> parseLs(String output) {
//     return output
//         .split('\n')
//         .where((l) => l.isNotEmpty)
//         .map((line) {
//       final parts = line.split(RegExp(r'\s+'));
//       return DeviceFile(
//         name: parts.last,
//         isDirectory: line.startsWith('d'),
//       );
//     }).toList();
//   }
//   Future<String> runCommand(String command) async {
//     final result = await Process.run(
//       '/bin/zsh',          // macOS default shell
//       ['-c', command],
//     );
//
//     if (result.exitCode != 0) {
//       throw Exception(result.stderr);
//     }
//
//     return result.stdout;
//   }
// }

// class MirrorScreen extends StatefulWidget {
//   const MirrorScreen({super.key});
//
//   @override
//   State<MirrorScreen> createState() => _MirrorScreenState();
// }
//
// class _MirrorScreenState extends State<MirrorScreen> {
//   // Create the Player
//   late final Player player = Player(
//     configuration: const PlayerConfiguration(
//       logLevel: MPVLogLevel.debug, // Change from default to debug
//     ),
//   );
//   // Create the VideoController (binds player to UI)
//   late final VideoController controller = VideoController(player);
//
//   final TextEditingController _portController = TextEditingController(text: "5000");
//   bool _isPlaying = false;
//
//   @override
//   void initState() {
//     super.initState();
//
//     // Listen to internal MediaKit/MPV logs
//     player.stream.log.listen((event) {
//       // This will print everything libmpv is doing
//       debugPrint("MPV [${event.prefix}]: ${event.text}");
//     });
//
//     // Listen for errors specifically
//     player.stream.error.listen((error) {
//       debugPrint("STREAM ERROR: $error");
//     });
//
//     if (player.platform is NativePlayer) {
//       (player.platform as NativePlayer).setProperty('hwdec', 'auto');
//     }
//   }
//
//   Future<void> _startStream() async {
//     _checkRawUdpTraffic(5000);
//     if (player.platform is NativePlayer) {
//       final native = player.platform as NativePlayer;
//       await native.setProperty('profile', 'low-latency');
//       await native.setProperty('cache', 'no');
//       await native.setProperty('fps', '60'); // Force a frame rate if known
//       await native.setProperty('demuxer-lavf-o', 'protocol_whitelist=[udp,rtp,file],fflags=nobuffer');
//     }
//
//     // Use the 'br:' prefix or force the demuxer
//     await player.open(
//       Media(
//         'udp://127.0.0.1:5000', // Try 127.0.0.1 or @:5000
//         extras: {
//           '--demuxer-lavf-format': 'h264', // Or 'hevc' if sending H265
//           '--demuxer-lavf-analyzeduration': '0.1',
//           '--demuxer-lavf-probesize': '32',
//         },
//       ),
//     );
//     setState(() {
//       _isPlaying = true;
//     });
//   }
//
//   Future<void> _stopStream() async {
//     await player.stop();
//     setState(() {
//       _isPlaying = false;
//     });
//   }
//
//   @override
//   void dispose() {
//     player.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF1E1E1E),
//       body: Row(
//         children: [
//           // --- Sidebar Controls ---
//           Container(
//             width: 250,
//             color: const Color(0xFF252525),
//             padding: const EdgeInsets.all(24),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text("CONNECTION",
//                     style: TextStyle(color: Colors.white54, letterSpacing: 1.5, fontSize: 12)
//                 ),
//                 const SizedBox(height: 16),
//                 TextField(
//                   controller: _portController,
//                   style: const TextStyle(color: Colors.white),
//                   decoration: InputDecoration(
//                     labelText: "UDP Port",
//                     filled: true,
//                     fillColor: Colors.white10,
//                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 SizedBox(
//                   width: double.infinity,
//                   height: 50,
//                   child: ElevatedButton(
//                     onPressed: _isPlaying ? _stopStream : _startStream,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: _isPlaying ? Colors.redAccent : Colors.blueAccent,
//                       foregroundColor: Colors.white,
//                     ),
//                     child: Text(_isPlaying ? "STOP SERVER" : "START SERVER"),
//                   ),
//                 ),
//                 const Spacer(),
//                 if (_isPlaying)
//                   const Center(
//                     child: Text("● RECEIVING DATA",
//                         style: TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold)
//                     ),
//                   ),
//               ],
//             ),
//           ),
//
//           // --- Video Display ---
//           Expanded(
//             child: Center(
//               child: Container(
//                 color: Colors.black,
//                 child: Video(
//                   controller: controller,
//                   // 'contain' ensures we see the whole phone screen
//                   fit: BoxFit.contain,
//                   controls: NoVideoControls, // Hide play/pause buttons for mirror mode
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//
//
//   void _checkRawUdpTraffic(int port) async {
//     try {
//       // Bind to the same port to see if packets exist
//       // Note: You may need to stop the player first as they both can't bind to the same port
//       // unless 'reuseAddress' is true.
//       final socket = await RawDatagramSocket.bind('10.39.177.44', port, reuseAddress: true);
//       debugPrint("CHECKER: Listening for raw packets on $port...");
//
//       socket.listen((RawSocketEvent event) {
//         if (event == RawSocketEvent.read) {
//           final dg = socket.receive();
//           if (dg != null) {
//             debugPrint("CHECKER: Received ${dg.data.length} bytes from ${dg.address.address}");
//             // After confirming 1 packet, we can close this to free the port for the player
//             socket.close();
//           }
//         }
//       });
//     } catch (e) {
//       debugPrint("CHECKER ERROR: $e");
//     }
//   }
// }
