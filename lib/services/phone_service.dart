import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:swish_app/backend/imu_data.dart';
import 'package:swish_app/backend/shot_data.dart';

ShotData? latestShot;

Future<void> uploadTrainingSession({
  required File videoFile,
  required List<Map<String, dynamic>> imuPackets,
  required String handedness,
  required double videoStartTime,
}) async {
  var request = http.MultipartRequest(
    'POST',
    Uri.parse('http://172.20.10.8:8000/upload/'),
  );

  // Attach video file
  request.files.add(await http.MultipartFile.fromPath('file', videoFile.path));

  // Add handedness as a form field
  request.fields['handedness'] = handedness;

  // Add IMU data as JSON stringified form field
  request.fields['imu_data'] = jsonEncode(imuPackets);

  request.fields['video_start_time'] = videoStartTime.toString();

  try {
    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseData);

      // ✅ Create instance from json
      latestShot = ShotData.fromJson(jsonResponse);

      print("Shot Made: \${latestShot!.success}");
    } else {
      print("Error uploading session: \${response.statusCode}");
    }
  } catch (e) {
    print("Exception: \$e");
  }
}
