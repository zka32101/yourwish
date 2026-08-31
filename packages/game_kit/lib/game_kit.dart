/// SNS配信（TikTok Liveなど）向け視聴者参加型ゲームの共通部品集。
///
/// 新しいゲーム環境を追加する際は、このパッケージをpath依存に追加し、
/// ここに含まれる部品を組み合わせて実装する。ゲーム固有のロジック
/// （シナリオ内容、勝敗条件など）だけを各 `apps/<ゲーム名>/` に書けばよい。
library;

export 'src/live_comment_service.dart';
export 'src/models/vote_scenario.dart';
export 'src/widgets/comment_ticker.dart';
export 'src/widgets/lives_row.dart';
export 'src/widgets/vote_bar_list.dart';
