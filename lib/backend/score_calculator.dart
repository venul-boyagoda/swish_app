import 'package:swish_app/backend/shot_data.dart';

class SummaryScoreCalculator {
  // Ideal values
  static const double idealReleaseAngle = 50.9;

  static const double idealElbowFollow = 191.2;
  static const double idealElbowSet = 81.2;
  static const double idealKneeSet = 133.0;

  // IMU Ideal values
  static const double idealShoulderSet = 10.0; // Example ideal value, adjust as needed
  static const double idealFollowAccel = 15.0; // Example ideal value, adjust as needed

  // Weights
  static const double accuracyWeight = 0.30; // 30% Accuracy
  static const double formWeight = 0.70;     // 70% Form/Coordination

  // Accuracy breakdown
  static const double successSubWeight = 0.15;
  static const double releaseAngleSubWeight = 0.85;

  // Form breakdown
  static const double elbowFollowWeight = 0.35;
  static const double elbowSetWeight = 0.15;
  static const double kneeSetWeight = 0.15;
  static const double shoulderSetWeight = 0.20;
  static const double followAccelWeight = 0.15;

  static double calculateShotScore(ShotData shot) {
    double totalScore = 100;

    // --------------------------
    // Accuracy Component (30%)
    // --------------------------
    double accuracyPenalty = 0;

    accuracyPenalty += shot.success ? 0 : (successSubWeight * accuracyWeight) * 100;

    double releaseError = (shot.release_angle - idealReleaseAngle).abs() / idealReleaseAngle;
    accuracyPenalty += releaseError * (releaseAngleSubWeight * accuracyWeight) * 100;

    // --------------------------
    // Form/Coordination Component (70%)
    // --------------------------
    double formPenalty = 0;

    double elbowFollowError = (shot.elbow_follow - idealElbowFollow).abs() / idealElbowFollow;
    formPenalty += elbowFollowError * elbowFollowWeight * formWeight * 100;

    double elbowSetError = (shot.elbow_set - idealElbowSet).abs() / idealElbowSet;
    formPenalty += elbowSetError * elbowSetWeight * formWeight * 100;

    double kneeSetError = (shot.knee_set - idealKneeSet).abs() / idealKneeSet;
    formPenalty += kneeSetError * kneeSetWeight * formWeight * 100;

    double shoulderSetError = (shot.shoulder_set - idealShoulderSet).abs() / idealShoulderSet;
    formPenalty += shoulderSetError * shoulderSetWeight * formWeight * 100;

    double followAccelError = (shot.follow_accel - idealFollowAccel).abs() / idealFollowAccel;
    formPenalty += followAccelError * followAccelWeight * formWeight * 100;

    // Final score after deductions
    totalScore -= (accuracyPenalty + formPenalty);
    return totalScore.clamp(0, 100);
  }
}
