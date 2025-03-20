class ShotData {
  bool success;
  double release_angle;
  double elbow_follow;
  double elbow_set;
  double knee_set;

  // IMU Data fields
  double shoulder_set;
  double follow_accel;

  ShotData({
    required this.success,
    required this.release_angle,
    required this.elbow_follow,
    required this.elbow_set,
    required this.knee_set,
    required this.shoulder_set,   // ✅ NEW
    required this.follow_accel,   // ✅ NEW
  });

  factory ShotData.fromJson(Map<String, dynamic> json) {
    return ShotData(
      success: json['success'],
      release_angle: json['release_angle'].toDouble(),
      elbow_follow: json['elbow_follow'].toDouble(),
      elbow_set: json['elbow_set'].toDouble(),
      knee_set: json['knee_set'].toDouble(),
      shoulder_set: json['shoulder_set']?.toDouble() ?? 0.0,  // ✅ NEW
      follow_accel: json['follow_accel']?.toDouble() ?? 0.0,  // ✅ NEW
    );
  }
}
