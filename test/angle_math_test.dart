import 'package:flutter_test/flutter_test.dart';
import 'package:sih/utils/angle_math.dart';

void main() {
  group('angleBetweenPoints', () {
    test('Straight line should be 180 degrees', () {
      final angle = angleBetweenPoints(
        ax: 0, ay: 0,
        bx: 0, by: 1, // vertex
        cx: 0, cy: 2,
      );
      expect(angle, closeTo(180.0, 0.1));
    });

    test('Right angle should be 90 degrees', () {
      final angle = angleBetweenPoints(
        ax: 1, ay: 0,
        bx: 0, by: 0, // vertex
        cx: 0, cy: 1,
      );
      expect(angle, closeTo(90.0, 0.1));
    });

    test('Acute angle (45 degrees)', () {
      final angle = angleBetweenPoints(
        ax: 1, ay: 1,
        bx: 0, by: 0, // vertex
        cx: 1, cy: 0,
      );
      expect(angle, closeTo(45.0, 0.1));
    });

    test('Overlapping points should return 0 to handle div by zero gracefully', () {
      final angle = angleBetweenPoints(
        ax: 0, ay: 0,
        bx: 0, by: 0,
        cx: 0, cy: 0,
      );
      expect(angle, 0.0);
    });
  });
}
