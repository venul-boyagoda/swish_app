import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class ThingyImuService {
  final FlutterBluePlus flutterBlue = FlutterBluePlus();
  BluetoothDevice? _device;
  BluetoothCharacteristic? _imuCharacteristic;
  StreamSubscription<List<int>>? _notificationSubscription;

  final String deviceId = "ED:C5:81:ED:70:84";
  final Guid imuServiceUuid = Guid("12345678-1234-5678-1234-123456789abc");
  final Guid imuCharacteristicUuid = Guid("87654321-4321-6789-4321-cba987654321");

  Future<void> connectAndListen({required Function(List<List<double>> matrix) onMatrixReceived}) async {
    print("[flutter_blue_plus] Checking permissions...");
    await _checkPermissions();

    print("[flutter_blue_plus] Scanning for device...");
    await FlutterBluePlus.startScan(timeout: Duration(seconds: 5));

    await for (ScanResult r in FlutterBluePlus.scanResults.expand((r) => r)) {
      if (r.device.remoteId.str == deviceId) {
        _device = r.device;
        await FlutterBluePlus.stopScan();
        print("[flutter_blue_plus] Found device: ${r.device.remoteId.str}");
        break;
      }
    }

    if (_device != null) {
      await _device!.connect(autoConnect: false);
      print("[flutter_blue_plus] Connected to device.");

      List<BluetoothService> services = await _device!.discoverServices();
      for (var service in services) {
        if (service.uuid == imuServiceUuid) {
          for (var char in service.characteristics) {
            if (char.uuid == imuCharacteristicUuid) {
              _imuCharacteristic = char;
              await char.setNotifyValue(true);
              _notificationSubscription = char.lastValueStream.listen((data) {
                print("[flutter_blue_plus] 🔥 Notification received: ${data.length} bytes");
                final matrix = _decodeRotationMatrix(data);
                onMatrixReceived(matrix);
              });
              print("[flutter_blue_plus] Subscribed to IMU notifications.");
              break;
            }
          }
        }
      }
    } else {
      print("[flutter_blue_plus] Device not found.");
    }
  }

  Future<void> _checkPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location
    ].request();

    if (statuses.values.any((status) => !status.isGranted)) {
      throw Exception("[flutter_blue_plus] BLE permissions not granted.");
    }
  }

  List<List<double>> _decodeRotationMatrix(List<int> data) {
    if (data.length != 36) {
      throw Exception("Expected 36 bytes, got ${data.length}");
    }

    List<double> floats = [];
    final byteData = ByteData.sublistView(Uint8List.fromList(data));

    for (int i = 0; i < 9; i++) {
      floats.add(byteData.getFloat32(i * 4, Endian.little));
    }

    return [
      floats.sublist(0, 3),
      floats.sublist(3, 6),
      floats.sublist(6, 9),
    ];
  }

  Future<void> disconnect() async {
    await _notificationSubscription?.cancel();
    if (_imuCharacteristic != null) {
      await _imuCharacteristic!.setNotifyValue(false);
    }
    await _device?.disconnect();
    print("[flutter_blue_plus] Disconnected and cleaned up.");
  }
}