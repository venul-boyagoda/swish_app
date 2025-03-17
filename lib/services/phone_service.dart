import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:swish_app/backend/backend_variables.dart';

Future<void> uploadVideo(File videoFile) async {
  var request = http.MultipartRequest(
    'POST',
    Uri.parse('http://172.20.10.8:8000/upload/'), // Replace with your server IP
  );

  request.files.add(await http.MultipartFile.fromPath('file', videoFile.path));

  var response = await request.send();

  if (response.statusCode == 200) {
    var responseData = await response.stream.bytesToString();
    var jsonResponse = jsonDecode(responseData);
    BackendData.shotMade = jsonResponse['shot_made'];
    print("Shot Made: ${jsonResponse['shot_made']}");
  } else {
    print("Error uploading video: ${response.statusCode}");
  }
}

Future<void> uploadIMUData(List<List<double>> imuData) async {
  // Prepare the IMU data to send as a JSON object
  Map<String, dynamic> data = {
    // Assuming imuData is a list of quaternions, each being a 4-element list
    // Example: imuData[0] is quaternion from first IMU sensor
    'imu_1': {
      'w': imuData[0][0], // w component of the quaternion
      'x': imuData[0][1], // x component of the quaternion
      'y': imuData[0][2], // y component of the quaternion
      'z': imuData[0][3], // z component of the quaternion
    },
    // Example: imuData[1] is quaternion from second IMU sensor
    'imu_2': {
      'w': imuData[1][0], // w component of the quaternion
      'x': imuData[1][1], // x component of the quaternion
      'y': imuData[1][2], // y component of the quaternion
      'z': imuData[1][3], // z component of the quaternion
    }
  };

  // Set up the HTTP request to send the data to your server
  var request = http.MultipartRequest(
    'POST',
    Uri.parse('http://172.20.10.8:8000/uploadIMUData/'), // Replace with your server's IP and endpoint
  );

  // Send the data as JSON in the body
  request.headers.addAll({'Content-Type': 'application/json'}); // Ensure the correct content type
  request.fields['data'] = jsonEncode(data); // Add IMU data as JSON in the body

  try {
    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseData);
      BackendData.imu1Velocity = jsonResponse['imu1_velocity'];
      print("IMU 1 (BNO055): ${jsonResponse['imu2_velocity']}");
      BackendData.imu2Velocity = jsonResponse['imu2_velocity'];
      print("IMU 1 (BMI270): ${jsonResponse['imu2_velocity']}");
    } else {
      print("Error uploading IMU data: ${response.statusCode}");
    }
  } catch (e) {
    print("Exception: $e");
  }
}

