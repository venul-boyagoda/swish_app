import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleService {
  final String deviceId = "ED:C5:81:ED:70:84"; // Your actual MAC address
  final Guid imuServiceUuid = Guid("12345678-1234-5678-1234-123456789abc");
  final Guid imuCharacteristicUuid = Guid("87654321-4321-6789-4321-cba987654321");

  BluetoothDevice? _device;
  BluetoothCharacteristic? _imuCharacteristic;
  bool _isConnected = false;
  StreamController<List<int>> _imuDataController = StreamController.broadcast();

  Stream<List<int>> get imuData => _imuDataController.stream;
  bool get isConnected => _isConnected;

  Future<bool> connectToIMU() async {
    try {
      // Start scanning
      print("Scanning for $deviceId...");
      await FlutterBluePlus.startScan(timeout: Duration(seconds: 5));

      final scanResult = await FlutterBluePlus.scanResults
          .firstWhere((results) =>
              results.any((r) => r.device.remoteId.str.toUpperCase() == deviceId.toUpperCase()));

      await FlutterBluePlus.stopScan();

      final device = scanResult.firstWhere(
              (r) => r.device.remoteId.str.toUpperCase() == deviceId.toUpperCase())
          .device;

      _device = device;

      // Connect to device
      print("Connecting to ${device.remoteId.str}...");
      await device.connect(autoConnect: false);
      _isConnected = true;
      print("Connected to ${device.remoteId.str}");

      // Discover services & characteristics
      List<BluetoothService> services = await device.discoverServices();
      final imuService = services.firstWhere(
          (service) => service.serviceUuid == imuServiceUuid,
          orElse: () => throw Exception("IMU Service not found"));

      _imuCharacteristic = imuService.characteristics.firstWhere(
          (c) => c.characteristicUuid == imuCharacteristicUuid && c.properties.notify,
          orElse: () => throw Exception("IMU Characteristic not found or not notifiable"));

      // Subscribe to notifications
      await _imuCharacteristic!.setNotifyValue(true);
      _imuCharacteristic!.onValueReceived.listen((data) {
        print("IMU Data Received: $data");
        _imuDataController.add(data);
      });

      return true;
    } catch (e) {
      print("Connection error: $e");
      _isConnected = false;
      return false;
    }
  }

  Future<void> disconnect() async {
    if (_device != null) {
      await _device!.disconnect();
      _isConnected = false;
      _imuDataController.close();
      print("Disconnected from device");
    }
  }
}
