class ImuData {
  static double shoulder_set = 0.0; // Shoulder set angle (deg)
  static double follow_accel = 0.0; // Follow-through acceleration (m/s^2)

  static void fromJson(Map<String, dynamic> json) {
    shoulder_set = json['shoulder_set']?.toDouble() ?? 0.0;
    follow_accel = json['follow_accel']?.toDouble() ?? 0.0;
  }
}