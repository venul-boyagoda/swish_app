import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'dart:math';

import 'coordinates_translator.dart';

class PosePainter extends CustomPainter {
  PosePainter(
    this.poses,
    this.imageSize,
    this.rotation,
    this.cameraLensDirection,
  );

  final List<Pose> poses;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = Colors.green;

    final leftPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.yellow;

    final rightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.blueAccent;

    final angleArcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.red;


    final angleArcPaintElbow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.indigo;

    final angleArcPaintWrist = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.purple;

    final angleArcPaintShoulder = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.greenAccent;

    final angleArcPaintKnee = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.orangeAccent;

    final angleArcPaintHip = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.brown;      

    const angleTextStyle = TextStyle(
      color: Colors.red,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );

    const angleTextStyleElbow = TextStyle(
      color: Colors.indigo,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );

    const angleTextStyleWrist = TextStyle(
      color: Colors.purple,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );

    const angleTextStyleShoulder = TextStyle(
      color: Colors.greenAccent,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );

    const angleTextStyleKnee = TextStyle(
      color: Colors.orangeAccent,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );

    const angleTextStyleHip = TextStyle(
      color: Colors.brown,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );

    for (final pose in poses) {
      pose.landmarks.forEach((_, landmark) {
        canvas.drawCircle(
            Offset(
              translateX(
                landmark.x,
                size,
                imageSize,
                rotation,
                cameraLensDirection,
              ),
              translateY(
                landmark.y,
                size,
                imageSize,
                rotation,
                cameraLensDirection,
              ),
            ),
            1,
            paint);
      });

      void paintLine(
          PoseLandmarkType type1, PoseLandmarkType type2, Paint paintType) {
        final PoseLandmark joint1 = pose.landmarks[type1]!;
        final PoseLandmark joint2 = pose.landmarks[type2]!;
        canvas.drawLine(
            Offset(
                translateX(
                  joint1.x,
                  size,
                  imageSize,
                  rotation,
                  cameraLensDirection,
                ),
                translateY(
                  joint1.y,
                  size,
                  imageSize,
                  rotation,
                  cameraLensDirection,
                )),
            Offset(
                translateX(
                  joint2.x,
                  size,
                  imageSize,
                  rotation,
                  cameraLensDirection,
                ),
                translateY(
                  joint2.y,
                  size,
                  imageSize,
                  rotation,
                  cameraLensDirection,
                )),
            paintType);
      }

      double calculateJointAngle(
          double jointX,
          double jointY,
          double endpointOneX,
          double endpointOneY,
          double endpointTwoX,
          double endpointTwoY) {

        // Get x an y components of the 2 vectors
        final v1x = endpointOneX - jointX;
        final v1y = endpointOneY - jointY;
        final v2x = endpointTwoX - jointX;
        final v2y = endpointTwoY - jointY;

        // Determine angle using dot products and vector magnitude
        // dot product = |v1||v2|cos(theta)
        final dotProduct = (v1x * v2x) + (v1y * v2y);
        final magnitudeV1 = sqrt(pow(v1x, 2) + pow(v1y, 2));
        final magnitudeV2 = sqrt(pow(v2x, 2) + pow(v2y, 2));

        if (magnitudeV1 == 0 || magnitudeV2 == 0) return 0.0;

        final cosTheta = (dotProduct / (magnitudeV1 * magnitudeV2)).clamp(-1.0, 1.0);
        return acos(cosTheta) * (180 / pi);
      }

      void drawJointAngle({
          required PoseLandmarkType joint,
          required PoseLandmarkType endPointOne,
          required PoseLandmarkType endPointTwo,
          double radius = 40.0,
          Paint? paint,
          TextStyle textStyle = angleTextStyle}) {
        
        paint ??= angleArcPaint;
        final PoseLandmark jointLandmark = pose.landmarks[joint]!;
        final PoseLandmark endPointOneLandmark = pose.landmarks[endPointOne]!;
        final PoseLandmark endPointTwoLandmark = pose.landmarks[endPointTwo]!;

        // Calculate the joint angle
        final jointAngleDegrees = calculateJointAngle(
          jointLandmark.x,
          jointLandmark.y,
          endPointOneLandmark.x,
          endPointOneLandmark.y,
          endPointTwoLandmark.x,
          endPointTwoLandmark.y
        );

        final jointOffset = Offset(
          translateX(jointLandmark.x, size, imageSize, rotation, cameraLensDirection),
          translateY(jointLandmark.y, size, imageSize, rotation, cameraLensDirection),
        );

        final endPointOneOffset = Offset(
          translateX(endPointOneLandmark.x, size, imageSize, rotation, cameraLensDirection),
          translateY(endPointOneLandmark.y, size, imageSize, rotation, cameraLensDirection),
        );

        final endPointTwoOffset = Offset(
          translateX(endPointTwoLandmark.x, size, imageSize, rotation, cameraLensDirection),
          translateY(endPointTwoLandmark.y, size, imageSize, rotation, cameraLensDirection),
        );

        // Draw angle arc
        final rect = Rect.fromCircle(center: jointOffset, radius: radius);
        final startAngle = atan2(endPointOneOffset.dy - jointOffset.dy,
            endPointOneOffset.dx - jointOffset.dx);
        final endAngle = atan2(endPointTwoOffset.dy - jointOffset.dy,
            endPointTwoOffset.dx - jointOffset.dx);
        canvas.drawArc(rect, startAngle, endAngle - startAngle, false, paint);

        // Draw angle text
        final textSpan = TextSpan(
          text: '${jointAngleDegrees.toStringAsFixed(1)}°',
          style: textStyle,
        );
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(canvas, jointOffset + Offset(10, -30));

      }

      //Draw arms
      paintLine(
          PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow, leftPaint);
      paintLine(
          PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist, leftPaint);
      paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow,
          rightPaint);
      paintLine(
          PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist, rightPaint);

      //Draw Body
      paintLine(
          PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip, leftPaint);
      paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip,
          rightPaint);

      //Draw legs
      paintLine(PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee, leftPaint);
      paintLine(
          PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle, leftPaint);
      paintLine(
          PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee, rightPaint);
      paintLine(
          PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle, rightPaint);

      //Draw fingers
      paintLine(PoseLandmarkType.leftWrist, PoseLandmarkType.leftThumb, leftPaint);
      paintLine(PoseLandmarkType.leftWrist, PoseLandmarkType.leftIndex, leftPaint);
      paintLine(PoseLandmarkType.leftWrist, PoseLandmarkType.leftPinky, leftPaint);
      paintLine(PoseLandmarkType.rightWrist, PoseLandmarkType.rightThumb, rightPaint);
      paintLine(PoseLandmarkType.rightWrist, PoseLandmarkType.rightIndex, rightPaint);
      paintLine(PoseLandmarkType.rightWrist, PoseLandmarkType.rightPinky, rightPaint);

      // Draw elbow joint
      drawJointAngle(joint: PoseLandmarkType.leftElbow, endPointOne: PoseLandmarkType.leftShoulder, endPointTwo: PoseLandmarkType.leftWrist, paint: angleArcPaintElbow, textStyle: angleTextStyleElbow);
      drawJointAngle(joint: PoseLandmarkType.rightElbow, endPointOne: PoseLandmarkType.rightShoulder, endPointTwo: PoseLandmarkType.rightWrist, paint: angleArcPaintElbow, textStyle: angleTextStyleElbow);

      // Draw wrist joint
      drawJointAngle(joint: PoseLandmarkType.leftWrist, endPointOne: PoseLandmarkType.leftElbow, endPointTwo: PoseLandmarkType.leftIndex, paint: angleArcPaintWrist, textStyle: angleTextStyleWrist);
      drawJointAngle(joint: PoseLandmarkType.rightWrist, endPointOne: PoseLandmarkType.rightElbow, endPointTwo: PoseLandmarkType.rightIndex, paint: angleArcPaintWrist, textStyle: angleTextStyleWrist);

      // Draw shoulder joint
      drawJointAngle(joint: PoseLandmarkType.leftShoulder, endPointOne: PoseLandmarkType.leftHip, endPointTwo: PoseLandmarkType.leftElbow, paint: angleArcPaintShoulder, textStyle: angleTextStyleShoulder);
      drawJointAngle(joint: PoseLandmarkType.rightShoulder, endPointOne: PoseLandmarkType.rightHip, endPointTwo: PoseLandmarkType.rightElbow, paint: angleArcPaintShoulder, textStyle: angleTextStyleShoulder);
      
      // Draw knee joint
      drawJointAngle(joint: PoseLandmarkType.leftKnee, endPointOne: PoseLandmarkType.leftHip, endPointTwo: PoseLandmarkType.leftAnkle, paint: angleArcPaintKnee, textStyle: angleTextStyleKnee);
      drawJointAngle(joint: PoseLandmarkType.rightKnee, endPointOne: PoseLandmarkType.rightHip, endPointTwo: PoseLandmarkType.rightAnkle, paint: angleArcPaintKnee, textStyle: angleTextStyleKnee);

      // Draw hip joint
      drawJointAngle(joint: PoseLandmarkType.leftHip, endPointOne: PoseLandmarkType.leftShoulder, endPointTwo: PoseLandmarkType.leftKnee, paint: angleArcPaintHip, textStyle: angleTextStyleHip);
      drawJointAngle(joint: PoseLandmarkType.rightHip, endPointOne: PoseLandmarkType.rightShoulder, endPointTwo: PoseLandmarkType.rightKnee, paint: angleArcPaintHip, textStyle: angleTextStyleHip);

    }
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.imageSize != imageSize || oldDelegate.poses != poses;
  }
}