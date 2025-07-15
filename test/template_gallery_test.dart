import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';

import 'package:habit_hero_project/routes/app_router.dart';
import 'package:habit_hero_project/core/services/template_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final getIt = GetIt.instance;

  setUp(() {
    getIt.reset();
    getIt.registerLazySingleton<TemplateService>(() => TemplateService());
  });

  testWidgets('template fills add habit form', (tester) async {
    final router = createRouter(true, GlobalKey<NavigatorState>());
    await tester.pumpWidget(
      Provider<TemplateService>.value(
        value: getIt<TemplateService>(),
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    router.go('/add_habit');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Browse templates'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Miracle Morning').first);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, 'Miracle Morning'), findsOneWidget);
  });
}
