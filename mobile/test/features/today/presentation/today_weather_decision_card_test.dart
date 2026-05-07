 import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lifeos_mobile/features/today/domain/model/today_weather_insight.dart';
import 'package:lifeos_mobile/features/today/presentation/widgets/today_weather_decision_card.dart';

void main() {
  testWidgets('shows static demo preview for placeholder weather', (
    tester,
  ) async {
    final insight = TodayWeatherInsight.placeholder(isSelectedToday: true);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: TodayWeatherDecisionCard(insight: insight)),
      ),
    );

    expect(find.text('Weather context'), findsOneWidget);
    expect(find.text('Later'), findsOneWidget);
    expect(find.text('Demo preview'), findsOneWidget);
    expect(find.text('18°C'), findsOneWidget);
    expect(find.text('20% rain'), findsOneWidget);
    expect(find.text('Light wind'), findsOneWidget);
  });
}
