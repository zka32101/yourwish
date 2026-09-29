// 画面台帳（DEVICE_TEST_POLICY.md §3）。ship-cycle bootstrap で自動生成。
// MaterialApp.routes の画面は自動でツアーされる。ここには追加分・除外分だけ書く。

/// routes に無い画面（go_router 等）で、引数なしで pushNamed できるルート名
const extraRoutes = <String>[];

/// ツアー対象外（引数必須・課金実行・外部遷移など）。初回実行の SHIP_CYCLE_WARN を見て追加する
const skipRoutes = <String>{};
