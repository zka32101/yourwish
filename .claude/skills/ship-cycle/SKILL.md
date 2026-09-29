---
name: ship-cycle
description: 開発→テスト→リリース準備を低リソースで自動実行する。Flutter アプリの改修後・PR 前・CI 失敗の予防・リリース前チェック・実機テスト・不具合調査で使う。「チェックして」「テストして」「リリース準備」「PR前確認」「実機テスト」「スクショ」「原因調べて」でトリガー。
---

# ship-cycle（入口のみ）

本体と方針は shared_core の 1 か所だけにある（ここにはコピーしない）。

1. 本体の場所を決める:
   `S=$(ls -d ../shared_core/.claude/skills/ship-cycle ~/.claude/shared_core/.claude/skills/ship-cycle 2>/dev/null | head -1)`
   見つからなければ `git clone --depth 1 https://github.com/zka32101/shared_core ../shared_core` してから再実行する。
2. `$S/SKILL.md` を読み、その手順に従う（方針は `shared_core/docs/DEV_PLAYBOOK.md`）。
