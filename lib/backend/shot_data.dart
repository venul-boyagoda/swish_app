class ShotData {
  final int follow_frame;
  final int end;
  final double elbow_follow;
  final double elbow_set;
  final double knee_set;
  final bool success;
  final double release_angle;

  //IMU data
  double elbow_flare;
  double power;

  ShotData({
    required this.follow_frame,
    required this.end,
    required this.elbow_follow,
    required this.elbow_set,
    required this.knee_set,
    required this.success,
    required this.release_angle,
    required this.elbow_flare,
    required this.power,
  });

  // Factory to parse from backend response
  factory ShotData.fromJson(Map<String, dynamic> json) {
    return ShotData(
      follow_frame: json['follow_frame'],
      end: json['end'],
      elbow_follow: json['elbow_follow'],
      elbow_set: json['elbow_set'],
      knee_set: json['knee_set'],
      success: json['success'],
      release_angle: json['release_angle'],
      elbow_flare: json['elbow_flare'].toDouble(),
      power: json['power'].toDouble(),
    );
  }
}

