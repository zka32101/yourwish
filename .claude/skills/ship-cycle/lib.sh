# ship-cycle 共通関数
RED=$'\033[31m'; YEL=$'\033[33m'; GRN=$'\033[32m'; NC=$'\033[0m'
[ -t 1 ] || { RED=; YEL=; GRN=; NC=; }
# パイプ先 while（サブシェル）でも数えられるようファイルに記録
SC_LOG=$(mktemp); trap 'rm -f "$SC_LOG"' EXIT
err()  { echo "${RED}❌ [$1] $2${NC}"; echo "E $1 $2" >> "$SC_LOG"; }
warn() { echo "${YEL}⚠️  [$1] $2${NC}"; echo "W $1 $2" >> "$SC_LOG"; }
ok()   { echo "${GRN}✅ $1${NC}"; }
summary() {
  local e w; e=$(grep -c '^E ' "$SC_LOG"); w=$(grep -c '^W ' "$SC_LOG")
  echo "---- $1: errors=$e warnings=$w"
  [ -n "${SC_OUT:-}" ] && cp "$SC_LOG" "$SC_OUT"
  [ "$e" -eq 0 ]
}

# 差分基準: BASE 指定 > origin/HEAD > origin/main > origin/master
default_base() {
  [ -n "${BASE:-}" ] && { echo "$BASE"; return; }
  local r; r=$(git symbolic-ref -q --short refs/remotes/origin/HEAD 2>/dev/null)
  [ -z "$r" ] && r=$(git remote show origin 2>/dev/null | sed -n 's/.*HEAD branch: //p' | sed 's|^|origin/|')
  for c in $r origin/main origin/master; do git rev-parse -q --verify "$c" >/dev/null && { echo "$c"; return; }; done
  echo HEAD
}

# 対象 Flutter パッケージ（pubspec.yaml のあるディレクトリ）を列挙。
# 複数パッケージがある場合は BASE との差分があるものだけ（ALL=1 で全件）。
target_packages() {
  local root="${1:-.}" all
  all=$(find "$root" -name pubspec.yaml -not -path '*/.dart_tool/*' -not -path '*/build/*' \
        -not -path '*/.pub-cache/*' -not -path '*/ios/*' -not -path '*/android/*' \
        -not -path '*/.symlinks/*' -not -path '*/example/*' | xargs -r -n1 dirname | sort)
  if [ "${ALL:-0}" = 1 ] || [ "$(echo "$all" | grep -c .)" -le 1 ]; then echo "$all"; return; fi
  local base changed top rel; base=$(cd "$root" && default_base)
  changed=$( { git -C "$root" diff --name-only "$base"...HEAD; git -C "$root" diff --name-only HEAD; } 2>/dev/null)
  [ -z "$changed" ] && { echo "$all"; return; }
  top=$(git -C "$root" rev-parse --show-toplevel)
  for p in $all; do
    rel=$(realpath --relative-to="$top" "$p")
    if [ "$rel" = "." ] || echo "$changed" | grep -q "^$rel/"; then echo "$p"; fi
  done
}
