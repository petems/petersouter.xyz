#!/usr/bin/env bash
set -euo pipefail

TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/hugo-bluesky-shortcode.XXXXXX")"
LOG_FILE="$TMP_DIR/hugo.log"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

if ! hugo --destination "$TMP_DIR/public" >"$LOG_FILE" 2>&1; then
  cat "$LOG_FILE"
  echo "[bluesky-shortcode-smoke] Hugo build failed"
  exit 1
fi

if rg -q "bluesky shortcode: failed to fetch oEmbed" "$LOG_FILE"; then
  cat "$LOG_FILE"
  echo "[bluesky-shortcode-smoke] Bluesky oEmbed fetch warning detected"
  exit 1
fi

echo "[bluesky-shortcode-smoke] Passed"
