import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/services/report_service.dart';

void main() {
  late FakeFirebaseFirestore db;

  setUp(() {
    db = FakeFirebaseFirestore();
    ReportService.instance.debugDb = db;
  });

  tearDown(() => ReportService.instance.debugDb = null);

  test('createReport grava os campos exigidos em reports', () async {
    await ReportService.instance.createReport(
      authorId: 'autor_1',
      targetId: 'pet_1',
      reason: 'Spam ou anúncio duplicado',
    );

    final reports = await db.collection('reports').get();
    expect(reports.docs, hasLength(1));
    final data = reports.docs.single.data();
    expect(data['autorId'], 'autor_1');
    expect(data['alvoId'], 'pet_1');
    expect(data['motivo'], 'Spam ou anúncio duplicado');
    expect(data['timestamp'], isNotNull);
  });
}
