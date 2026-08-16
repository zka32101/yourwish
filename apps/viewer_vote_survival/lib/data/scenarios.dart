import 'package:sns_live_game_kit/sns_live_game_kit.dart';

/// サンプルシナリオ集（漂流島サバイバル）。
///
/// 実運用では配信内容やイベントに応じて自由に差し替え・追加してよい。
/// 各ラウンドは2択で、視聴者はコメントで "1" か "2" を投票する想定。
const List<VoteScenario> survivalScenarios = [
  VoteScenario(
    prompt: '目を覚ますと見知らぬ島の浜辺にいた。目の前に2つの道がある。',
    choices: [
      VoteChoice(label: '① 山道を行く', voteKeyword: '1', successRate: 0.6),
      VoteChoice(label: '② 海岸沿いを行く', voteKeyword: '2', successRate: 0.7),
    ],
  ),
  VoteScenario(
    prompt: '喉が渇いてきた。何を飲む？',
    choices: [
      VoteChoice(label: '① 泉の水を飲む', voteKeyword: '1', successRate: 0.5),
      VoteChoice(label: '② ヤシの実を割る', voteKeyword: '2', successRate: 0.8),
    ],
  ),
  VoteScenario(
    prompt: '日が暮れてきた。夜をどう過ごす？',
    choices: [
      VoteChoice(label: '① 洞窟で眠る', voteKeyword: '1', successRate: 0.7),
      VoteChoice(label: '② 焚き火を起こす', voteKeyword: '2', successRate: 0.6),
    ],
  ),
  VoteScenario(
    prompt: '遠くに小屋のようなものが見える。',
    choices: [
      VoteChoice(label: '① 小屋に近づく', voteKeyword: '1', successRate: 0.5),
      VoteChoice(label: '② 遠回りして様子を見る', voteKeyword: '2', successRate: 0.75),
    ],
  ),
  VoteScenario(
    prompt: '茂みの奥から大きな音が聞こえた。',
    choices: [
      VoteChoice(label: '① 音のする方へ向かう', voteKeyword: '1', successRate: 0.4),
      VoteChoice(label: '② 音から離れる', voteKeyword: '2', successRate: 0.75),
    ],
  ),
  VoteScenario(
    prompt: '脱出できそうな筏を見つけた。',
    choices: [
      VoteChoice(label: '① すぐに漕ぎ出す', voteKeyword: '1', successRate: 0.55),
      VoteChoice(label: '② 補強してから漕ぎ出す', voteKeyword: '2', successRate: 0.7),
    ],
  ),
];
