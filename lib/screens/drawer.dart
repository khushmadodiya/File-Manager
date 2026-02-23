import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/BubbleWidget.dart';
import '../components/context_menue.dart';
import '../model/context_menu_item.dart';
import '../provider/states/file_itme_state.dart';
import 'components/file_grid_item.dart';
import '../model/device.dart';
import '../provider/device_file_provider.dart';

class MobileStyleDrawerScreen extends StatefulWidget {
  final List<Device> devices;

  const MobileStyleDrawerScreen({super.key, required this.devices});

  @override
  State<MobileStyleDrawerScreen> createState() =>
      _MobileStyleDrawerScreenState();
}

class _MobileStyleDrawerScreenState extends State<MobileStyleDrawerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DeviceFileProvider>().init(widget.devices);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DeviceFileProvider>();

    return Scaffold(
      body: Row(
        children: [
          // SIDEBAR
          BubbleWidget(
            child: SizedBox(
              width: 260,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 22),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey, width: 1),
                      ),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(Icons.usb, size: 40),
                        SizedBox(height: 10),
                        Text('Device Manager', style: TextStyle(fontSize: 20)),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  ...widget.devices.map(
                    (device) => ListTile(
                      hoverColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      leading: Icon(
                        device.type == 'android'
                            ? Icons.android
                            : Icons.phone_iphone,
                      ),
                      title: Text(device.name),
                      subtitle: Text(device.ip),
                      selected: provider.selectedDevice == device,
                      onTap: () => provider.selectDevice(device),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // CONTENT
          Expanded(
            child: provider.selectedDevice == null
                ? const Center(child: Text('Select a device'))
                : provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Listener(
                    behavior: HitTestBehavior.translucent,
                    onPointerDown: (event) {
                      if (event.kind == PointerDeviceKind.mouse &&
                          event.buttons == kSecondaryMouseButton && provider.isLoading) {
                        // This only fires when click is NOT handled by children
                        // showContextMenu(context, event.position);
                      }
                    },
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.files.length,
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 130,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.85,
                          ),
                      itemBuilder: (_, index) {
                        final file = provider.files[index];
                        return ChangeNotifierProvider(
                          create: (_) => DeviceFileProvider(),
                          child: FileItem(
                            file: file,
                            devicePath: provider.currentPath,
                            onOpen: file.isDirectory
                                ? () => provider.openDirectory(file)
                                : null,
                            reload: provider.loadFiles,
                            deviceId: provider.selectedDevice?.id ?? "",
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void showContextMenu(BuildContext context, Offset position) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () => entry.remove(),
              onDoubleTap: () {
                entry.remove();
              },
              onSecondaryTapUp: (val) => entry.remove(),
              onSecondaryTapDown: (val) => entry.remove(),

              behavior: HitTestBehavior.translucent,
            ),
          ),
          Positioned(
            left: position.dx,
            top: position.dy,
            child: MacosContextMenu(
              items: [
                ContextMenuItem(
                  label: 'New folder',
                  icon: Icons.create_new_folder_outlined,
                  onTap: () {
                    entry.remove();
                  },
                ),
                ContextMenuItem(divider: true, label: '', icon: Icons.clear),
              ],
            ),
          ),
        ],
      ),
    );

    overlay.insert(entry);
  }
}
