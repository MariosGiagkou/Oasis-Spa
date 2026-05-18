import 'package:flutter_test/flutter_test.dart';
import 'package:oasis/data/spa_menu_data.dart';

void main() {
  group('SpaTreatment Model', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 5,
        'title': 'Test Treatment',
        'description': 'A test description',
        'price_euros': 100,
        'duration_minutes': 90,
      };

      final treatment = SpaTreatment.fromJson(json);

      expect(treatment.id, 5);
      expect(treatment.title, 'Test Treatment');
      expect(treatment.description, 'A test description');
      expect(treatment.priceEuros, 100);
      expect(treatment.durationMinutes, 90);
    });

    test('spaMenuFallback contains expected static data', () {
      expect(spaMenuFallback.isNotEmpty, isTrue);
      // Verify at least one item has valid fields
      final first = spaMenuFallback.first;
      expect(first.title, isNotEmpty);
      expect(first.priceEuros, greaterThan(0));
      expect(first.durationMinutes, greaterThan(0));
    });
  });
}
