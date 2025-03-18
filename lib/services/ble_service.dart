import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleService {
  final String deviceId = "ED:C5:81:ED:70:84"; // Your actual MAC address
  final Guid imuServiceUuid = Guid("12345678-1234-5678-1234-123456789abc");
  final Guid imuCharacteristicUuid = Guid("87654321-4321-6789-4321-cba987654321");

  BluetoothDevice? _device;
  BluetoothCharacteristic? _imuCharacteristic;
  StreamSubscription<BluetoothConnectionState>? _connectionSub;
  StreamController<List<int>> _imuDataController = StreamController.broadcast();

  bool _isConnected = false;

  Stream<List<int>> get imuData => _imuDataController.stream;
  bool get isConnected => _isConnected;

  Future<bool> connectToIMU() async {
    try {
      // Try direct connection first
      print("🔗 Trying direct connection to $deviceId...");
      _device = BluetoothDevice(remoteId: DeviceIdentifier(deviceId));

      await _device!.connect(autoConnect: true);
      _setupConnectionListener(_device!);
      await _setupIMUNotifications();
      print("✅ Direct connection successful!");
      return true;

    } catch (e) {
      print("⚠️ Direct connection failed: $e");
      return _fallbackScanConnect();
    }
  }

  Future<bool> _fallbackScanConnect() async {
    try {
      print("🔄 Scanning for $deviceId...");
      await FlutterBluePlus.startScan(timeout: Duration(seconds: 5));

      final scanResult = await FlutterBluePlus.scanResults.firstWhere((results) =>
          results.any((r) => r.device.remoteId.str.toUpperCase() == deviceId.toUpperCase()));

      await FlutterBluePlus.stopScan();

      final device = scanResult.firstWhere(
              (r) => r.device.remoteId.str.toUpperCase() == deviceId.toUpperCase())
          .device;

      _device = device;

      print("🔗 Connecting to ${device.remoteId.str} via scan...");
      await device.connect(autoConnect: false);
      _setupConnectionListener(device);
      await _setupIMUNotifications();

      print("✅ Connected via fallback scan!");
      return true;

    } catch (e) {
      print("❌ Fallback scan failed: $e");
      _isConnected = false;
      return false;
    }
  }

  Future<void> _setupIMUNotifications() async {
    List<BluetoothService> services = await _device!.discoverServices();
    final imuService = services.firstWhere(
          (service) => service.serviceUuid == imuServiceUuid,
      orElse: () => throw Exception("IMU Service not found"),
    );

    _imuCharacteristic = imuService.characteristics.firstWhere(
          (c) => c.characteristicUuid == imuCharacteristicUuid && c.properties.notify,
      orElse: () => throw Exception("IMU Characteristic not found or not notifiable"),
    );

    await _imuCharacteristic!.setNotifyValue(true);
    _imuCharacteristic!.onValueReceived.listen((data) {
      if (!_imuDataController.isClosed) {
        _imuDataController.add(data);
      }
    });

    _isConnected = true;
  }

  void _setupConnectionListener(BluetoothDevice device) {
    _connectionSub?.cancel(); // clean old listener
    _connectionSub = device.connectionState.listen((state) {
      print("🔄 Connection state: $state");
      if (state == BluetoothConnectionState.disconnected) {
        _isConnected = false;
        print("❌ Device disconnected");
      } else if (state == BluetoothConnectionState.connected) {
        _isConnected = true;
        print("🟢 Device connected");
      }
    });
  }

  Future<void> disconnect() async {
    try {
      await _connectionSub?.cancel();
      if (_imuCharacteristic != null) {
        await _imuCharacteristic!.setNotifyValue(false);
      }
      if (_device != null) {
        await _device!.disconnect();
      }
      _isConnected = false;
      if (!_imuDataController.isClosed) {
        await _imuDataController.close();
      }
      print("🛑 Fully disconnected from device");
    } catch (e) {
      print("⚠️ Error during disconnect: $e");
    }
  }
}
