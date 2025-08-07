class MovementStats {
  final int totalMovingTime;
  final int totalStoppedTime;
  final int totalIdlingTime;

  MovementStats({
    required this.totalMovingTime,
    required this.totalStoppedTime,
    required this.totalIdlingTime,
  });
}

class MetricsSummary {
  final double totalDistance;
  final int totalDuration;
  final double averageSpeed;
  final double maxSpeed;
  final double minSpeed;
  final MovementStats movementStats;

  MetricsSummary({
    required this.totalDistance,
    required this.totalDuration,
    required this.averageSpeed,
    required this.maxSpeed,
    required this.minSpeed,
    required this.movementStats,
  });
}
