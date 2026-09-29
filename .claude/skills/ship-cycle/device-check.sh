#!/usr/bin/env bash
# ローカル実機テスト（Windows Git Bash / Linux + USB 実機）。10観点チェックの薄いラッパー。
#   bash device-check.sh <app_dir> [release_apk] [待機秒]
# APK を渡すと release 版をそのまま検証（ストア配信版に近い）。省略時は debug で全画面ツアーまで実行。
HERE="$(cd "$(dirname "$0")" && pwd)"
APP="${1:-.}"; [ -n "${2:-}" ] && export APK="$(realpath "$2")" APK_GIVEN=1; export WAIT="${3:-20}"
exec bash "$HERE/device-10check.sh" android "$APP"
