import 'package:swish_app/backend/shot_data.dart';

/// Mistake Model
class Mistake {
  final String description;
  final String effect;

  Mistake(this.description, this.effect);
}

/// Ideal Values for Each Metric
class IdealValues {
  static const double idealReleaseAngle = 45.0;
  static const double idealElbowFollow = 182.0;
  static const double idealElbowSet = 89.0;
  static const double idealKneeSet = 122.0;
  static const double idealElbowFlare = 14.0;
  static const double idealPower = 12.0;
}

/// Retrieves the ideal value for the given metric
double getIdealByKey(String key) {
  switch (key) {
    case 'release_angle':
      return IdealValues.idealReleaseAngle;
    case 'elbow_follow':
      return IdealValues.idealElbowFollow;
    case 'elbow_set':
      return IdealValues.idealElbowSet;
    case 'knee_set':
      return IdealValues.idealKneeSet;
    case 'shoulder_set':
      return IdealValues.idealElbowFlare;
    case 'follow_accel':
      return IdealValues.idealPower;
    default:
      return 0;
  }
}

/// Retrieves the actual value from the shot by key
double getValueByKey(ShotData shot, String key) {
  switch (key) {
    case 'release_angle':
      return shot.release_angle;
    case 'elbow_follow':
      return shot.elbow_follow;
    case 'elbow_set':
      return shot.elbow_set;
    case 'knee_set':
      return shot.knee_set;
    case 'shoulder_set':
      return shot.elbow_flare;
    case 'follow_accel':
      return shot.power;
    default:
      return 0;
  }
}

/// Generates feedback based on actual vs. ideal values
String getFeedback(String key, double actualValue, double idealValue) {
  final difference = actualValue - idealValue;

  switch (key) {
    case 'release_angle':
      return difference > 0
          ? 'Release angle is too high — try aiming lower, and focus on a specific point on the rim.'
          : 'Release angle is too low — try aiming higher, and focus on a consistent target above the rim.';
    case 'elbow_follow':
      return difference > 0
          ? 'Follow-through elbow is too high — try extending your arm in a straight line without lifting too far.'
          : 'Follow-through elbow is too low — ensure full arm extension and a relaxed wrist finish.';
    case 'elbow_set':
      return difference > 0
          ? 'Set elbow is too high — bring the ball closer to your head and keep the elbow more tucked.'
          : 'Set elbow is too low — avoid bringing the ball too close to your body and form a 90° shooting angle.';
    case 'knee_set':
      return difference > 0
          ? 'Knee bend is too deep — try not to squat excessively before the shot.'
          : 'Knee bend is too shallow — bend your knees more to build power in your shot.';
    case 'shoulder_set':
      return difference > 0
          ? 'Shoulder angle is too open — tuck your elbow in more to maintain vertical alignment.'
          : 'Shoulder angle is too tight — relax the shoulder slightly and allow natural motion upward.';
    case 'follow_accel':
      return difference > 0
          ? 'Wrist acceleration is too high — try releasing with more control and less snap.'
          : 'Wrist acceleration is too low — add a stronger wrist flick to generate a better arc.';
    default:
      return 'Adjust this aspect of your form for more consistent shooting.';
  }
}

/// Generates a list of mistakes based on shot metrics
List<Mistake> generateMistakes(ShotData shot) {
  List<Mistake> mistakes = [];

  final keys = [
    'release_angle',
    'elbow_follow',
    'elbow_set',
    'knee_set',
    'elbow_flare',
    'power',
  ];

  for (var key in keys) {
    double actualValue = getValueByKey(shot, key);
    double idealValue = getIdealByKey(key);

    if ((actualValue - idealValue).abs() > 5.0) {
      // Add to mistakes if deviation is significant (> 5 degrees or units)
      mistakes.add(Mistake(key.replaceAll('_', ' ').toUpperCase(), getFeedback(key, actualValue, idealValue)));
    }
  }

  return mistakes;
}
