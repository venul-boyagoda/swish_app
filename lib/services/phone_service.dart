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
    BackendData.shotMade = jsonResponse['shotMade'];
    print("Shot Made: ${jsonResponse['shot_made']}");
  } else {
    print("Error uploading video: ${response.statusCode}");
  }
}
