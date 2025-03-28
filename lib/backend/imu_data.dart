class ImuData {
  static double elbow_flare = 0.0; // Shoulder set angle (deg)
  static double power = 0.0; // Follow-through acceleration (m/s^2)

  static void fromJson(Map<String, dynamic> json) {
    elbow_flare = json['shoulder_set']?.toDouble() ?? 0.0;
    power = json['follow_accel']?.toDouble() ?? 0.0;
  }
}