import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/app_state.dart';
import 'package:mobile/main.dart';

void main() {
  testWidgets('App loads login screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      AppStateProvider(
        notifier: AppState(),
        child: const MyApp(),
      ),
    );

    // Verify that our login screen loads and contains the app name.
    expect(find.text('MediApp'), findsOneWidget);
    expect(find.text('Correo Electrónico'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);
  });
}
