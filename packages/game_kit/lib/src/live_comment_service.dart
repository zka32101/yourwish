import 'dart:async';
import 'dart:math';

/// 配信のライブコメントから視聴者の投票を受け取るための抽象インターフェース。
///
/// 本番でTikTok Liveなどと連携する際は、この抽象を実装するクラス
/// （例: `TikTokLiveCommentService`）をゲーム側で用意して差し替えるだけでよく、
/// ゲームの画面・進行ロジックは変更不要になるように設計している。
abstract class LiveCommentService {
  /// 投票キーワード（例: "1", "2"）が流れてくるストリーム。
  Stream<String> get voteStream;

  /// 現在のラウンドで有効な投票キーワードを更新する。
  /// 実装側は、有効なキーワード以外のコメントを無視する用途に使ってよい。
  void updateActiveKeywords(List<String> keywords);

  /// サービスを開始する（配信接続など）。
  Future<void> start();

  /// サービスを終了する（配信切断など）。
  Future<void> stop();

  /// リソースを解放する。
  void dispose();
}

/// 実際のSNS Live API連携が未実装の間、動作確認・デモ配信用に使う
/// モック実装。ランダムな間隔で、有効なキーワードをランダムに投票として流す。
class MockLiveCommentService implements LiveCommentService {
  MockLiveCommentService({this.interval = const Duration(milliseconds: 250)});

  /// モック投票を発生させる間隔。
  final Duration interval;

  final _controller = StreamController<String>.broadcast();
  final _random = Random();
  List<String> _activeKeywords = [];
  Timer? _timer;

  @override
  Stream<String> get voteStream => _controller.stream;

  @override
  void updateActiveKeywords(List<String> keywords) {
    _activeKeywords = keywords;
  }

  @override
  Future<void> start() async {
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) {
      if (_activeKeywords.isEmpty || _controller.isClosed) return;
      final keyword = _activeKeywords[_random.nextInt(_activeKeywords.length)];
      _controller.add(keyword);
    });
  }

  @override
  Future<void> stop() async {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}
