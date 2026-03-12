

import 'package:flutter/material.dart';
import '../model/device.dart';
import '../model/device_file.dart';
import '../service/adb_service.dart';
import '../stack/stack.dart';

class DeviceFileProvider extends ChangeNotifier {
  Device? selectedDevice;
  List<Device>? devices;
  List<DeviceFile> files = [];
  String currentPath = '/sdcard/';
  bool isLoading = false;
  var stack = StringStack();



  Future<void> init(List<Device> devicess) async {
    if (devicess.isEmpty) {
      devices = [];
      files =[];
      notifyListeners();
      return;
    }
    devices = devicess;
    selectedDevice = devicess.first;
    currentPath = '/sdcard/';
    stack = StringStack();
    stack.push(currentPath);
    await loadFiles();
  }


  Future<void> selectDevice(Device device) async {
    selectedDevice = device;
    currentPath = '/sdcard/';
    stack = StringStack();
    stack.push(currentPath);
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

    // final safeName = file.name.replaceAll(' ', r' ');
    print("safe name $file");
    currentPath = '$currentPath${file.name}/';
    stack.push(currentPath);
    await loadFiles();
  }

  Future<void> exitDirectory()async{
    stack.pop();
    currentPath = stack.peek() ?? "/sdcard/";
    await loadFiles();
  }
}