class ShotData {
  bool success;
  double release_angle;
  double elbow_follow;
  double elbow_set;
  double knee_set;

  ShotData({
    required this.success,
    required this.release_angle,
    required this.elbow_follow,
    required this.elbow_set,
    required this.knee_set,
  });

  factory ShotData.fromJson(Map<String, dynamic> json) {
    return ShotData(
      success: json['success'],
      release_angle: json['release_angle'].toDouble(),
      elbow_follow: json['elbow_follow'].toDouble(),
      elbow_set: json['elbow_set'].toDouble(),
      knee_set: json['knee_set'].toDouble(),
    );
  }
}
