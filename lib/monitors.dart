import 'package:windows_devices/windows_devices.dart';

final _kMonitorNameRe = RegExp(r'Generic Monitor \((.+)\)');

class MonitorInfo {
  final String id;
  final String name;

  MonitorInfo({required this.id, required this.name});
}

abstract class Monitors {
  static Future<List<MonitorInfo>> get() async {
    final devices = await DeviceInformation.findAllAsyncAqsFilter(
        DisplayMonitor.getDeviceSelector());
    final monitors = <MonitorInfo>[];
    for (int i = 0; i < devices.size; i++) {
      final device = devices.getAt(i)!;
      final name =
          _kMonitorNameRe.firstMatch(device.name)?.group(1) ?? device.name;
      monitors.add(MonitorInfo(id: device.id, name: name));
    }
    return monitors;
  }
}
