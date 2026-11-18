import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:enghlish/main.dart';
import 'package:enghlish/features/authentication/presentation/login_page.dart';

void main() {
  testWidgets('LingoMate AI khởi động thành công', (WidgetTester tester) async {
    await tester.pumpWidget(const LingoMateApp());

    // Không dùng pumpAndSettle vì màn hình loading có animation liên tục.
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Ứng dụng phải được khởi tạo.
    expect(find.byType(LingoMateApp), findsOneWidget);

    // Có thể đang ở màn hình đăng nhập hoặc đang kiểm tra phiên đăng nhập.
    final hasLoginPage = find.byType(LoginPage).evaluate().isNotEmpty;
    final hasLoading = find
        .byType(CircularProgressIndicator)
        .evaluate()
        .isNotEmpty;

    expect(
      hasLoginPage || hasLoading,
      isTrue,
      reason: 'Ứng dụng chưa hiển thị màn hình đăng nhập hoặc loading.',
    );
  });
}
