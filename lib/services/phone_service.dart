import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:swish_app/backend/backend_variables.dart';

Future<void> uploadVideo(File videoFile) async {
  var request = http.MultipartRequest(
    'POST',
    Uri.parse('http://172.20.10.8:8000/upload/'),
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

Future<void> uploadIMUData(List<List<List<double>>> matrixData) async {
  Map<String, dynamic> data = {
    'matrices': matrixData.map((matrix) {
      return {
        'row1': matrix[0],
        'row2': matrix[1],
        'row3': matrix[2],
      };
    }).toList(),
  };

  var request = http.MultipartRequest(
    'POST',
    Uri.parse('http://172.20.10.8:8000/uploadIMUData/'),
  );

  request.headers.addAll({'Content-Type': 'application/json'});
  request.fields['data'] = jsonEncode(data);

  try {
    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseData);
      BackendData.imu1Velocity = jsonResponse['imu1_velocity'];
      BackendData.imu2Velocity = jsonResponse['imu2_velocity'];
      print("IMU 1 Velocity: ${jsonResponse['imu1_velocity']}");
      print("IMU 2 Velocity: ${jsonResponse['imu2_velocity']}");
    } else {
      print("Error uploading IMU data: ${response.statusCode}");
    }
  } catch (e) {
    print("Exception: $e");
  }
}


Future<void> uploadArmInfo(String selectedArm) async {
  Map<String, dynamic> data = {
    'arm': selectedArm,
  };

  var response = await http.post(
    Uri.parse('http://172.20.10.8:8000/uploadArm/'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(data),
  );

  if (response.statusCode == 200) {
    print("Arm info uploaded successfully: $selectedArm");
  } else {
    print("Error uploading arm info: ${response.statusCode}");
  }
}
