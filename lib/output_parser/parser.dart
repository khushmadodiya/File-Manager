import '../model/device.dart';
import '../screens/drawer.dart';

class OutputParser {
 static List<Device> parseAdbOutput(String output) {
    List<Device> devices = [];

    // 1. Split by new lines and remove empty lines
    final lines = output.trim().split('\n');

    // 2. Skip the first line ("List of devices attached")
    for (var line in lines) {
      if (line.startsWith('List of devices') || line.trim().isEmpty) {
        continue;
      }

      // 3. Split by whitespace to get parts
      // Using RegExp to handle multiple spaces between columns
      final parts = line.split(RegExp(r'\s+'));

      if (parts.length < 2) continue; // Skip invalid lines

      String id = parts[0];
      String name = "Unknown Android";
      String connectionType = "Network"; // Default
      String type = "android";

      // 4. Extract details from the parts
      for (var part in parts) {
        if (part.startsWith("model:")) {
          // Extract "SM_S931B" and replace underscores with spaces
          name = part.substring(6).replaceAll('_', ' ');
        }
        if (part.startsWith("usb:")) {
          connectionType = "USB";
        }
      }

      // Special check: If the ID looks like an IP address, use it as the IP
      if (id.contains('.') && id.contains(':')) {
        connectionType = id; // It's a wireless connection
      } else if (id.startsWith("emulator")) {
        connectionType = "Emulator";
      }

      devices.add(Device(id: id, name: name, type: type, ip: connectionType));
    }

    return devices;
  }
}
