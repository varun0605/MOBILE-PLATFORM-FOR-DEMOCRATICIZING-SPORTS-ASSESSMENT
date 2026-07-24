import 'dart:math' as math;

/// Calculate the angle between three points (A, B, C) where B is the vertex.
/// Returns the angle in degrees between 0 and 180.
double angleBetweenPoints({
  required double ax,
  required double ay,
  required double bx,
  required double by,
  required double cx,
  required double cy,
}) {
  // Vector BA
  final baX = ax - bx;
  final baY = ay - by;
  
  // Vector BC
  final bcX = cx - bx;
  final bcY = cy - by;

  // Dot product
  final dotProduct = (baX * bcX) + (baY * bcY);

  // Magnitudes
  final magBA = math.sqrt(baX * baX + baY * baY);
  final magBC = math.sqrt(bcX * bcX + bcY * bcY);

  if (magBA == 0 || magBC == 0) return 0.0;

  // Cosine of angle
  var cosAngle = dotProduct / (magBA * magBC);
  
  // Clamp to [-1, 1] to avoid floating point errors with acos
  cosAngle = cosAngle.clamp(-1.0, 1.0);

  // Angle in radians
  final angleRad = math.acos(cosAngle);

  // Convert to degrees
  return angleRad * 180 / math.pi;
}

class AngleSmoother {
  final int windowSize;
  final List<double> _values = [];

  AngleSmoother({this.windowSize = 5});

  double get smoothedAngle {
    if (_values.isEmpty) return 0.0;
    final sum = _values.fold(0.0, (a, b) => a + b);
    return sum / _values.length;
  }

  void add(double value) {
    _values.add(value);
    if (_values.length > windowSize) {
      _values.removeAt(0);
    }
  }
}
