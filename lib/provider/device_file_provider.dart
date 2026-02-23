import 'dart:io';

import 'package:flutter/material.dart';
import '../model/device.dart';
import '../model/device_file.dart';
import '../screens/drawer.dart';
import '../service/adb_service.dart';

class DeviceFileProvider extends ChangeNotifier {
  Device? selectedDevice;
  List<DeviceFile> files = [];
  String currentPath = '/sdcard/';
  bool isLoading = false;



  Future<void> init(List<Device> devices) async {
    if (devices.isEmpty) return;
    selectedDevice = devices.first;
    await loadFiles();
  }


  Future<void> selectDevice(Device device) async {
    selectedDevice = device;
    currentPath = '/sdcard/';
    await loadFiles();
  }

  Future<void> loadFiles() async {
    if (selectedDevice == null) return;

    isLoading = true;
    notifyListeners();

    files = await AdbService.listFiles(
      currentPath,
      selectedDevice!.id,
    );

    isLoading = false;
    notifyListeners();
  }

  Future<void> openDirectory(DeviceFile file) async {
    if (!file.isDirectory) return;

    final safeName = file.name.replaceAll(' ', r' ');
    currentPath = '$currentPath$safeName/';
    await loadFiles();
  }
}