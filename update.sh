#!/usr/bin/env bash
# curated-skills updater / installer. Works with bash 3.2+ (macOS) and Linux. Requires: git, jq, rsync.
#
# Usage:
#   ./update.sh [update] [--dry-run] [skill-name]   refresh automatic entries; skip manual adaptations
#   ./update.sh install [--dry-run] [skill-name]    copy skills into ~/.claude/skills and ~/.agents/skills
#                                                   (source-only skills are fetched from upstream at the pinned commit)
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
SRC="$ROOT/sources.json"
MODE=update; DRY=0; ONLY=""
for a in "$@"; do
  case "$a" in
    update|install) MODE="$a" ;;
    --dry-run|-n) DRY=1 ;;
    -h|--help) sed -n '2,8p' "$0"; exit 0 ;;
    *) ONLY="$a" ;;
  esac
done
for c in git jq rsync; do command -v "$c" >/dev/null || { echo "missing: $c" >&2; exit 1; }; done
TMP="$(mktemp -d "${TMPDIR:-/tmp}/curated-skills.XXXXXX")"; trap 'rm -rf "$TMP"' EXIT
EXCLUDES=(--exclude .git --exclude '*.mp4')

names() { if [ -n "$ONLY" ]; then jq -e --arg n "$ONLY" '.[]|select(.name==$n)|.name' "$SRC" >/dev/null || { echo "unknown skill: $ONLY" >&2; exit 1; }; echo "$ONLY"; else jq -r '.[].name' "$SRC"; fi; }
field() { jq -r --arg n "$1" --arg f "$2" '.[]|select(.name==$n)|.[$f]' "$SRC"; }
expand() { echo "${1/#\~/$HOME}"; }

# fetch <url> [sha] -> prints checkout dir (cached per url+sha)
fetch() {
  local url="$1" sha="${2:-}" d; d="$TMP/$(echo "$url$sha" | tr -c 'A-Za-z0-9' '_')"
  if [ ! -d "$d" ]; then
    if [ -z "$sha" ]; then git clone -q --depth 1 "$url" "$d"
    else git init -q "$d"; git -C "$d" remote add origin "$url"
         git -C "$d" fetch -q --depth 1 origin "$sha" && git -C "$d" checkout -q FETCH_HEAD; fi
  fi
  echo "$d"
}

do_update() {
  local n url path old vend d new src dst
  for n in $(names); do
    if [ "$(field "$n" update_policy)" = "manual" ]; then
      echo "== $n  manual adaptation; review upstream changes before updating"
      continue
    fi
    url=$(field "$n" upstream_url); path=$(field "$n" path_in_upstream); old=$(field "$n" commit_sha); vend=$(field "$n" vendored)
    d=$(fetch "$url"); new=$(git -C "$d" rev-parse HEAD); src="$d/$path"
    echo "== $n  ${old:0:12} -> ${new:0:12}  (vendored=$vend)"
    if [ "$old" != "$new" ] && [ "$old" != "null" ] && git -C "$d" cat-file -e "$old" 2>/dev/null; then
      git -C "$d" diff --stat "$old" "$new" -- "$path" | tail -n 20
    elif [ "$old" != "$new" ]; then
      echo "   (old commit not in shallow clone; upstream changed: $url/compare/${old}...${new})"
    fi
    if [ "$vend" = "true" ]; then
      dst="$ROOT/skills/$n"
      if [ "$DRY" = 1 ]; then
        echo "   [dry-run] local vs upstream:"; rsync -rcn --delete --itemize-changes "${EXCLUDES[@]}" "$src/" "$dst/" | { grep -v "^\.[fd]\.\.[tT]\.\.\.\.\.* " || echo "(no content changes)"; } | sed 's/^/     /' | tail -n 30
      else
        mkdir -p "$dst"; rsync -a --delete "${EXCLUDES[@]}" "$src/" "$dst/"
      fi
    fi
    if [ "$DRY" = 1 ]; then echo "   [dry-run] would set commit_sha=$new"
    else jq --arg n "$n" --arg s "$new" 'map(if .name==$n then .commit_sha=$s else . end)' "$SRC" > "$TMP/s.json" && mv "$TMP/s.json" "$SRC"; fi
  done
  [ "$DRY" = 1 ] || { echo; git -C "$ROOT" status --short 2>/dev/null || true; }
}

do_install() {
  local n vend src t dir
  for n in $(names); do
    vend=$(field "$n" vendored)
    if [ "$vend" = "true" ]; then src="$ROOT/skills/$n"
    else src="$(fetch "$(field "$n" upstream_url)" "$(field "$n" commit_sha)")/$(field "$n" path_in_upstream)"; fi
    for t in $(jq -r --arg n "$n" '.[]|select(.name==$n)|.installed_to[]' "$SRC"); do
      dir="$(expand "$t")/$n"
      if [ "$DRY" = 1 ]; then echo "[dry-run] $n -> $dir"
      else mkdir -p "$dir"; rsync -a --delete "${EXCLUDES[@]}" "$src/" "$dir/"; echo "installed $n -> $dir"; fi
    done
  done
}

if [ "$MODE" = install ]; then do_install; else do_update; fi
