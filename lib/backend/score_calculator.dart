import 'package:swish_app/backend/shot_data.dart';

class SummaryScoreCalculator {
  // Ideal values
  static const double idealReleaseAngle = 50.9;
  static const double releaseAngleMin = 30.1;
  static const double releaseAngleMax = 72.2;

  static const double idealElbowFollow = 191.2;
  static const double elbowFollowMin = 151.2;
  static const double elbowFollowMax = 231.2;

  static const double idealElbowSet = 81.2;
  static const double elbowSetMin = 64.0;
  static const double elbowSetMax = 98.4;

  static const double idealKneeSet = 133.0;
  static const double kneeSetMin = 122.1;
  static const double kneeSetMax = 143.9;

  // Weights
  static const double accuracyWeight = 0.30; // 50% Accuracy
  static const double formWeight = 0.70; // 50% Form/Coordination

  static const double successSubWeight = 0.15;
  static const double releaseAngleSubWeight = 0.85;

  static const double elbowFollowWeight = 0.60;
  static const double elbowSetWeight = 0.25; // 33% of Form
  static const double kneeSetWeight = 0.15; // 33% of Form

  static double calculateShotScore(ShotData shot) {
    double totalScore = 100;

    // --------------------------
    // Accuracy Component (50%)
    // --------------------------
    double accuracyPenalty = 0;

    // 1. Shot Success (YES or NO)
    accuracyPenalty += shot.success ? 0 : (successSubWeight * accuracyWeight) * 100;

    // 2. Release Angle
    double releaseError = (shot.release_angle - idealReleaseAngle).abs() / idealReleaseAngle;
    accuracyPenalty += releaseError * (releaseAngleSubWeight * accuracyWeight) * 100;

    // --------------------------
    // Form/Coordination Component (50%)
    // --------------------------
    double formPenalty = 0;

    // 3. Elbow Follow Through
    double elbowFollowError = (shot.elbow_follow - idealElbowFollow).abs() / idealElbowFollow;
    formPenalty += elbowFollowError * elbowFollowWeight * formWeight * 100;

    // 4. Elbow Set
    double elbowSetError = (shot.elbow_set - idealElbowSet).abs() / idealElbowSet;
    formPenalty += elbowSetError * elbowSetWeight * formWeight * 100;

    // 5. Knee Set
    double kneeSetError = (shot.knee_set - idealKneeSet).abs() / idealKneeSet;
    formPenalty += kneeSetError * kneeSetWeight * formWeight * 100;

    // Final score after deductions
    totalScore -= (accuracyPenalty + formPenalty);
    return totalScore.clamp(0, 100);
  }
}
