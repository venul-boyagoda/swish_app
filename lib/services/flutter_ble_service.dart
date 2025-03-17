import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class ThingyImuService {
  final flutterReactiveBle = FlutterReactiveBle();

  final String deviceId = "ED:C5:81:ED:70:84";
  final Uuid imuServiceUuid = Uuid.parse("12345678-1234-5678-1234-123456789abc");
  final Uuid imuCharacteristicUuid = Uuid.parse("87654321-4321-6789-4321-cba987654321");

  StreamSubscription<ConnectionStateUpdate>? _connectionSubscription;
  StreamSubscription<List<int>>? _notificationSubscription;

  Future<void> connectAndListen({required Function(List<List<double>> matrix) onMatrixReceived}) async {
    print("Connecting to $deviceId...");

    _connectionSubscription = flutterReactiveBle.connectToDevice(
      id: deviceId,
      connectionTimeout: const Duration(seconds: 10),
    ).listen((connectionState) {
      print("Connection state: ${connectionState.connectionState}");

      if (connectionState.connectionState == DeviceConnectionState.connected) {
        print("Connected to $deviceId");

        // 🟢 Add the delay right here:
        Future.delayed(const Duration(seconds: 1), () {
          print("SUBSCRIBE TO NOTIFICATIONS FUNCTION");
          _subscribeToNotifications(onMatrixReceived);
        });
      } else if (connectionState.connectionState == DeviceConnectionState.disconnected) {
        print("Disconnected from $deviceId");
      }
    }, onError: (error) {
      print("BLE Connection Error: $error");
    });
  }

  void _subscribeToNotifications(Function(List<List<double>> matrix) onMatrixReceived) {
    final characteristic = QualifiedCharacteristic(
      serviceId: imuServiceUuid,
      characteristicId: imuCharacteristicUuid,
      deviceId: deviceId,
    );

    print("Subscribing to Characteristic UUID: $imuCharacteristicUuid on Service UUID: $imuServiceUuid");

    _notificationSubscription = flutterReactiveBle
        .subscribeToCharacteristic(characteristic)
        .listen((data) {
      print("🔥 NOTIFICATION RECEIVED: ${data.length} bytes");
      print("🔵 RAW: ${data.map((e) => e.toRadixString(16).padLeft(2, '0')).join(' ')}");

      final matrix = _decodeRotationMatrix(data);
      print("🟢 Decoded matrix:");
      for (final row in matrix) {
        print(row);
      }
      onMatrixReceived(matrix);
    }, onError: (error) {
      print("❌ Notification Error: $error");
    });
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
    await _connectionSubscription?.cancel();
    print("Cleaned up BLE resources.");
  }
}