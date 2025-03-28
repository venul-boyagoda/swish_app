import 'package:swish_app/backend/shot_data.dart';
import 'dart:math';

class SummaryScoreCalculator {
  // Ideal values
  static const double idealReleaseAngle = 50.9;
  static const double idealElbowFollow = 191.2;
  static const double idealElbowSet = 81.2;
  static const double idealKneeSet = 133.0;
  static const double idealElbowFlare = 10.0;
  static const double idealPower = 15.0;

  // Weights (form dominates, accuracy still matters slightly)
  static const double accuracyWeight = 0.35;
  static const double formWeight = 0.65;

  // Accuracy breakdown
  static const double successSubWeight = 0.50; // 25% of 20%
  static const double releaseAngleSubWeight = 0.50; // 75% of 20%

  // Form breakdown
  static const double elbowFollowWeight = 0.35;
  static const double elbowSetWeight = 0.15;
  static const double kneeSetWeight = 0.15;
  static const double shoulderSetWeight = 0.20;
  static const double followAccelWeight = 0.15;

  static double _scoreComponent({
    required double value,
    required double ideal,
    required double tolerance, // how much deviation is tolerated
  }) {
    final diff = (value - ideal).abs();
    final normalized = min(1.0, diff / tolerance); // 0 = perfect, 1 = worst
    return (1 - normalized) * 100;
  }

  static double calculateShotScore(ShotData shot) {
    // Accuracy scoring
    double accuracyScore = 0;
    if (shot.success) {
      accuracyScore += 100 * successSubWeight;
    }
    accuracyScore += _scoreComponent(
      value: shot.release_angle,
      ideal: idealReleaseAngle,
      tolerance: 20, // General degree tolerance
    ) *
        releaseAngleSubWeight;

    // Form scoring
    double formScore = 0;
    formScore += _scoreComponent(
      value: shot.elbow_follow,
      ideal: idealElbowFollow,
      tolerance: 30, // larger arm range
    ) * elbowFollowWeight;
    formScore += _scoreComponent(
      value: shot.elbow_set,
      ideal: idealElbowSet,
      tolerance: 30,
    ) * elbowSetWeight;
    formScore += _scoreComponent(
      value: shot.knee_set,
      ideal: idealKneeSet,
      tolerance: 20,
    ) * kneeSetWeight;
    formScore += _scoreComponent(
      value: shot.elbow_flare,
      ideal: idealElbowFlare,
      tolerance: 25, // tighter tolerance
    ) * shoulderSetWeight;
    formScore += _scoreComponent(
      value: shot.power,
      ideal: idealPower,
      tolerance: 15,
    ) * followAccelWeight;

    final totalScore =
        (formScore * formWeight) + (accuracyScore * accuracyWeight);

    return totalScore.clamp(0, 100);
  }
}
