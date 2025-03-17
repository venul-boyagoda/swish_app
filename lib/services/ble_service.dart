import 'dart:async';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';

class BleService {
  final flutterReactiveBle = FlutterReactiveBle();
  final String deviceId = "E1FA324C-88C7-9F34-E843-300825A6894C";
  final Uuid imuServiceUuid = Uuid.parse("87654321-4321-6789-4321-cba987654321");

  bool _isConnected = false;
  Stream<List<int>>? imuDataStream;

  //Getters
  Stream<List<int>>? get imuData => imuDataStream;
  bool get isConnected => _isConnected;

  /// Request necessary permissions before scanning
  Future<bool> requestBlePermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location
    ].request();

    bool granted = statuses[Permission.bluetoothScan]!.isGranted &&
        statuses[Permission.bluetoothConnect]!.isGranted &&
        statuses[Permission.location]!.isGranted;

    if (!granted) {
      print("BLE Permissions Denied. Cannot proceed.");
    }

    return granted;
  }

  Future<void> connectToIMU() async {
    if (!await requestBlePermissions()) return;

    try {
      print("Scanning for BNO055...");

      /// Declare scanSubscription before using it
      late StreamSubscription<DiscoveredDevice> scanSubscription;

      scanSubscription = flutterReactiveBle.scanForDevices(
        withServices: [imuServiceUuid],
        scanMode: ScanMode.lowLatency,
      ).listen((device) async {
        if (device.id == deviceId) {
          print("Found BNO055 IMU, connecting...");
          scanSubscription.cancel(); // Now this works correctly!

          final connectionStream = flutterReactiveBle.connectToDevice(id: deviceId);
          connectionStream.listen((connectionState) {
            if (connectionState.connectionState == DeviceConnectionState.connected) {
              print("Connected to BNO055!");
              subscribeToIMUData();
            }
          });
        }
      });
      _isConnected = true;
    } catch (e) {
      print("BLE Connection Error: $e");
    }
  }

  void subscribeToIMUData() {
    final characteristic = QualifiedCharacteristic(
      serviceId: imuServiceUuid,
      characteristicId: imuServiceUuid,
      deviceId: deviceId,
    );

    imuDataStream = flutterReactiveBle.subscribeToCharacteristic(characteristic);
    imuDataStream!.listen((data) {
      print("IMU Data Received: $data");
    });
  }
}
