class Indicators {
  final double roll;
  final double pitch;
  final double percentage;
  final String orientation;
  final int fovx;

  Indicators({
    required this.roll,
    required this.pitch,
    required this.percentage,
    required this.orientation,
    required this.fovx,
  });

  // Factory method to create an instance from JSON
  factory Indicators.fromJson(Map<String, dynamic> json) {
    return Indicators(
      roll: (json['roll'] as num).toDouble(),
      pitch: (json['pitch'] as num).toDouble(),
      percentage: (json['percentage'] as num).toDouble(),
      orientation: json['orientation'] == -1 ? 'LTR' : 'RTL',
      fovx: json['fovx'] as int,
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'roll': roll,
      'pitch': pitch,
      'percentage': percentage,
      'orientation': orientation == 'LTR' ? -1 : 1,
      'fovx': fovx,
    };
  }

  @override
  String toString() {
    return 'Indicators(roll: $roll, pitch: $pitch, percentage: $percentage, orientation: $orientation, fovx: $fovx)';
  }
}
