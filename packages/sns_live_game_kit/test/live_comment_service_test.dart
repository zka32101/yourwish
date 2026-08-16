import 'package:flutter_test/flutter_test.dart';
import 'package:sns_live_game_kit/sns_live_game_kit.dart';

void main() {
  test('MockLiveCommentServiceは有効なキーワードのみを投票として流す', () async {
    final service = MockLiveCommentService(interval: const Duration(milliseconds: 10));
    service.updateActiveKeywords(['1', '2']);

    final received = <String>[];
    final sub = service.voteStream.listen(received.add);

    await service.start();
    await Future<void>.delayed(const Duration(milliseconds: 60));
    await service.stop();
    await sub.cancel();
    service.dispose();

    expect(received, isNotEmpty);
    expect(received.every((k) => k == '1' || k == '2'), isTrue);
  });
}
