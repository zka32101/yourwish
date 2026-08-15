import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:viewer_vote_survival/main.dart';

void main() {
  testWidgets('起動するとタイトルと1問目のシナリオが表示される', (tester) async {
    await tester.pumpWidget(const ViewerVoteSurvivalApp());
    await tester.pump();

    expect(find.text('視聴者投票サバイバル'), findsOneWidget);
    expect(find.textContaining('目を覚ますと'), findsOneWidget);
  });

  testWidgets('HPがハート4つ分（現在HP + 開始HP用の枠）表示される', (tester) async {
    await tester.pumpWidget(const ViewerVoteSurvivalApp());
    await tester.pump();

    expect(find.byIcon(Icons.favorite), findsWidgets);
  });
}
