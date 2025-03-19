import 'package:swish_app/backend/shot_data.dart';

class SummaryScoreCalculator {
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

  static double calculateShotScore(ShotData shot) {
    double score = 0;

    const double successWeight = 30.0;
    const double releaseWeight = 20.0;
    const double elbowFollowWeight = 20.0;
    const double elbowSetWeight = 15.0;
    const double kneeSetWeight = 15.0;

    if (shot.success) {
      score += successWeight;
    }

    if (_inRange(shot.release_angle, releaseAngleMin, releaseAngleMax)) {
      score += releaseWeight;
    } else {
      double partial = _partialCredit(
        shot.release_angle,
        idealReleaseAngle,
        releaseAngleMin,
        releaseAngleMax,
      );
      score += releaseWeight * partial;
    }

    score += _applyPenalty(
      actual: shot.elbow_follow,
      ideal: idealElbowFollow,
      min: elbowFollowMin,
      max: elbowFollowMax,
      maxWeight: elbowFollowWeight,
    );

    score += _applyPenalty(
      actual: shot.elbow_set,
      ideal: idealElbowSet,
      min: elbowSetMin,
      max: elbowSetMax,
      maxWeight: elbowSetWeight,
    );

    score += _applyPenalty(
      actual: shot.knee_set,
      ideal: idealKneeSet,
      min: kneeSetMin,
      max: kneeSetMax,
      maxWeight: kneeSetWeight,
    );

    return score.clamp(0, 100);
  }

  static bool _inRange(double value, double min, double max) {
    return value >= min && value <= max;
  }

  static double _partialCredit(double actual, double ideal, double min, double max) {
    double totalRange = (max - min) / 2;
    double diff = (actual - ideal).abs();
    return (1 - (diff / totalRange)).clamp(0.0, 1.0);
  }

  static double _applyPenalty({
    required double actual,
    required double ideal,
    required double min,
    required double max,
    required double maxWeight,
  }) {
    double interval = (max - min) / 30;
    double diff = (actual - ideal).abs();
    int zone = (diff / interval).ceil();
    double penaltyRatio = zone / 15.0;
    double credit = (1 - penaltyRatio).clamp(0.0, 1.0);
    return maxWeight * credit;
  }
}
