import 'package:flutter_test/flutter_test.dart';

import 'package:vo_cuc_phuong_app/main.dart';

void main() {
  testWidgets('App boots without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const VoCucPhuongApp());
    expect(find.byType(VoCucPhuongApp), findsOneWidget);
  });
}
