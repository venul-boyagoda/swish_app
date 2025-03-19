class ImuData {
  static double shoulderSet = 0.0; // Shoulder set angle (deg)
  static double followAccel = 0.0; // Follow-through acceleration (m/s^2)

  static void fromJson(Map<String, dynamic> json) {
    shoulderSet = json['shoulder_set']?.toDouble() ?? 0.0;
    followAccel = json['follow_accel']?.toDouble() ?? 0.0;
  }
}