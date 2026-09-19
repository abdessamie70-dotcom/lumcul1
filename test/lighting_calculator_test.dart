import 'package:flutter_test/flutter_test.dart';
import 'package:lumcal/models/room_model.dart';
import 'package:lumcal/providers/lighting_provider.dart';

void main() {
  group('اختبارات الحسابات الرياضية والهندسية للإضاءة', () {
    test('حساب المساحة، اللومين، اللمبات، والواط بدقة حسب معادلات Excel', () {
      final room = RoomCalculation(
        id: 'test_1',
        name: 'غرفة النوم الرئيسية',
        length: 5.0,
        width: 4.0,
        requiredLux: 150.0,
        bulbLumen: 806.0,
        bulbWattage: 9.0,
        createdAt: DateTime.now(),
      );

      // 1. المساحة = 5 * 4 = 20 م²
      expect(room.area, equals(20.0));

      // 2. إجمالي اللومين = 20 * 150 * 2 = 6000 لومين
      expect(room.totalRequiredLumens, equals(6000.0));

      // 3. عدد اللمبات النظري = 6000 / 806 ≈ 7.44416
      expect(room.nominalBulbs, closeTo(7.444, 0.001));

      // 4. عدد اللمبات المقترح عملياً = ceil(7.444) = 8 لمبات
      expect(room.practicalBulbs, equals(8));

      // 5. إجمالي الاستهلاك الكهربائي = 8 * 9 = 72 واط
      expect(room.totalWattage, equals(72.0));
    });

    test('التحقق من حالة الحساب لمطبخ بأبعاد 3م في 4م وشدة إضاءة 350 لوكس', () {
      final room = RoomCalculation(
        id: 'test_kitchen',
        name: 'المطبخ',
        length: 4.0,
        width: 3.0,
        requiredLux: 350.0,
        bulbLumen: 1050.0,
        bulbWattage: 12.0,
        createdAt: DateTime.now(),
      );

      expect(room.area, equals(12.0));
      expect(room.totalRequiredLumens, equals(8400.0));
      expect(room.nominalBulbs, equals(8.0));
      expect(room.practicalBulbs, equals(8));
      expect(room.totalWattage, equals(96.0));
    });

    test('التحقق من إدارة حالة موفر الإضاءة وتجميع إحصائيات مشروع المنزل', () {
      final provider = LightingProvider();

      provider.calculate(
        roomName: 'غرفة النوم',
        length: 5.0,
        width: 4.0,
        requiredLux: 150.0,
        bulbLumen: 806.0,
        bulbWattage: 9.0,
      );
      expect(provider.currentCalculation, isNotNull);
      final added1 = provider.addCurrentToProject();
      expect(added1, isTrue);

      provider.calculate(
        roomName: 'مجلس الضيوف',
        length: 6.0,
        width: 5.0,
        requiredLux: 200.0,
        bulbLumen: 1050.0,
        bulbWattage: 12.0,
      );
      final added2 = provider.addCurrentToProject();
      expect(added2, isTrue);

      expect(provider.totalRoomsCount, equals(2));
      expect(provider.totalProjectArea, equals(50.0));
      expect(provider.totalProjectLumens, equals(18000.0));
      expect(provider.totalProjectBulbs, equals(20));
      expect(provider.totalProjectWattage, equals(216.0));

      final report = provider.generateProjectReport();
      expect(report.contains('تقرير متطلبات الإضاءة للمنزل'), isTrue);
      expect(report.contains('مجلس الضيوف'), isTrue);
      expect(report.contains('216.0 واط'), isTrue);
    });
  });
}
