import 'dart:async';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';

class BleService {
  final flutterReactiveBle = FlutterReactiveBle();

  // Device and UUIDs
  final String deviceId = "ED:C5:81:ED:70:84"; // Your actual MAC address
  final Uuid imuServiceUuid = Uuid.parse("12345678-1234-5678-1234-123456789abc");
  final Uuid imuCharacteristicUuid = Uuid.parse("87654321-4321-6789-4321-CBA987654321");

  bool _isConnected = false;
  Stream<List<int>>? imuDataStream;

  // Getters
  Stream<List<int>>? get imuData => imuDataStream;
  bool get isConnected => _isConnected;

  /// Request necessary permissions before scanning
  Future<bool> requestBlePermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    bool granted = statuses[Permission.bluetoothScan]!.isGranted &&
        statuses[Permission.bluetoothConnect]!.isGranted &&
        statuses[Permission.location]!.isGranted;

    if (!granted) {
      print("BLE Permissions Denied. Cannot proceed.");
    }

    return granted;
  }

  /// Connect to the IMU device
  Future<bool> connectToIMU() async {
    try {
      bool permissionsGranted = await requestBlePermissions();
      if (!permissionsGranted) {
        print("Permissions not granted. Cannot connect.");
        return false;
      }

      final connectionStream = flutterReactiveBle.connectToDevice(
        id: deviceId,
        connectionTimeout: Duration(seconds: 5),
      );

      connectionStream.listen((ConnectionStateUpdate connectionState) {
        print("Connection State: ${connectionState.connectionState}");

        if (connectionState.connectionState == DeviceConnectionState.connected) {
          _isConnected = true;
          print("Successfully connected to device: $deviceId");
          subscribeToIMUData();
        } else if (connectionState.connectionState == DeviceConnectionState.disconnected) {
          _isConnected = false;
          print("Disconnected from device: $deviceId");
          unsubscribeToIMUData();
        }
      }, onError: (error) {
        print("Error during connection: $error");
      });

      return true;
    } catch (e) {
      print("IMU CONNECTION ERROR: $e");
      return false;
    }
  }

  /// Subscribe to IMU data (broadcast stream only)
  void subscribeToIMUData() {
    if (imuDataStream != null) return;  // Prevent duplicate streams

    final characteristic = QualifiedCharacteristic(
      serviceId: imuServiceUuid,
      characteristicId: imuCharacteristicUuid,
      deviceId: deviceId,
    );

    imuDataStream = flutterReactiveBle
        .subscribeToCharacteristic(characteristic)
        .asBroadcastStream();

    print("IMU broadcast stream created ✅ for device $deviceId");
  }

  /// Unsubscribe from IMU data
  void unsubscribeToIMUData() {
    imuDataStream = null;
    print("IMU data stream reference cleared.");
  }

  /// Call this method when the training ends (button press)
  void endTraining() {
    unsubscribeToIMUData();
    print("Training ended. Stopped IMU data stream.");
  }
}
