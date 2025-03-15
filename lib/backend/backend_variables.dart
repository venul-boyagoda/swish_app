class BackendData {
  // IMU Data
  static const double velocity = 1; // Speed of the ball (m/s)
  static const double acceleration = 1; // Power/force onto the ball (m/s^2)

  // IMU Vx, Vy, Vz for two sensors
  static const List<double> imu1Velocity = [1, 2, 3];
  static const List<double> imu2Velocity = [1, 2, 3];

  // Release velocity (Average over duration)
  static const double releaseVelocity = 4;

  // IMU Ax, Ay, Az for two sensors
  static const List<double> imu1Acceleration = [1, 2, 3];
  static const List<double> imu2Acceleration = [1, 2, 3];

  // Power Calculation
  static const double power = 4; // Example computed value

  // New static variable to store the shot made status
  static bool shotMade = false;
}
