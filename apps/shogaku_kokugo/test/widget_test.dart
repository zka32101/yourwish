import 'package:flutter_test/flutter_test.dart';

import 'package:sns_game_template/main.dart';

void main() {
  testWidgets('起動するとテンプレート画面が表示される', (tester) async {
    await tester.pumpWidget(const SnsGameTemplateApp());
    await tester.pump();

    expect(find.text('SNS配信ゲーム テンプレート'), findsWidgets);
  });
}
