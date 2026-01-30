import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:api_factory/main.dart';
import 'package:api_factory/features/animator_workbench/presentation/widgets/storyboard_workbench.dart';
import 'package:api_factory/features/animator_workbench/presentation/widgets/script_workbench.dart';
import 'package:api_factory/features/animator_workbench/presentation/widgets/character_workbench.dart';

void main() {
  testWidgets('WorkbenchPage navigation test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    // Verify that StoryboardWorkbench is shown initially
    expect(find.byType(StoryboardWorkbench), findsOneWidget);
    expect(find.byType(ScriptWorkbench), findsNothing);
    expect(find.byType(CharacterWorkbench), findsNothing);

    // Tap the Script navigation icon
    await tester.tap(find.text('剧本'));
    await tester.pumpAndSettle();

    // Verify that ScriptWorkbench is shown
    expect(find.byType(StoryboardWorkbench), findsNothing);
    expect(find.byType(ScriptWorkbench), findsOneWidget);

    // Tap the Characters navigation icon
    await tester.tap(find.text('角色'));
    await tester.pumpAndSettle();

    // Verify that CharacterWorkbench is shown
    expect(find.byType(ScriptWorkbench), findsNothing);
    expect(find.byType(CharacterWorkbench), findsOneWidget);

    // Tap the Settings navigation icon
    await tester.tap(find.text('设置'));
    await tester.pumpAndSettle();

    // Verify that Settings placeholder is shown
    expect(find.text('设置 (开发中)'), findsOneWidget);

    // Tap the Storyboard navigation icon
    await tester.tap(find.text('分镜'));
    await tester.pumpAndSettle();

    // Verify that StoryboardWorkbench is shown again
    expect(find.byType(StoryboardWorkbench), findsOneWidget);
  });
}
