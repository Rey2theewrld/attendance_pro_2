import 'package:flutter_test/flutter_test.dart';
import 'package:attendance_pro/main.dart';

void main() {
  testWidgets('Attendance Pro app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AttendanceProApp());

    // Verify that the title on the login screen is displayed.
    expect(find.text('Attendance Pro'), findsOneWidget);
    expect(find.text('Student Accountability System'), findsOneWidget);
  });
}

