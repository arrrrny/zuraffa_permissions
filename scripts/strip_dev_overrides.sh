#!/bin/bash
set -e
# Strip the dev-only `dependency_overrides:` section from package pubspecs.
#
# The committed overrides point at sibling working copies that live OUTSIDE
# this repo (`path: ../../../zuraffa`), so a fresh clone/CI checkout cannot
# resolve without them. CI (and any build against published packages) runs
# this first; the deletion is never committed — the overrides stay dev-only
# state (see PUBLISH.md: pub strips dependency_overrides on publish).
#
# Usage: scripts/strip_dev_overrides.sh [pubspec.yaml ...]
#        With no arguments, every member (and the app package's example)
#        under packages/ is processed.

GREEN='\033[0;32m'; BLUE='\033[0;34m'; NC='\033[0m'

ROOT_DIR="$(cd "$(dirname "$0")/.." >/dev/null 2>&1; pwd -P)"

strip_one() {
    local pubspec="$1"
    if [ ! -f "$pubspec" ]; then
        echo "Not a file: $pubspec"; exit 1
    fi
    local name="${pubspec#"$ROOT_DIR"/packages/}"; name="${name%/pubspec.yaml}"
    if ! grep -q '^dependency_overrides:' "$pubspec"; then
        echo -e "${BLUE}${name}: no dependency_overrides — nothing to strip${NC}"
        return
    fi
    # Delete from the `dependency_overrides:` key to the next top-level key
    # (a non-indented, non-comment line) or end of file.
    awk '
        /^dependency_overrides:/ { dropping = 1; next }
        dropping && /^[^ #]/     { dropping = 0 }
        !dropping                { print }
    ' "$pubspec" > "$pubspec.tmp" && mv "$pubspec.tmp" "$pubspec"
    echo -e "${GREEN}${name}: dependency_overrides stripped${NC}"
}

if [ "$#" -gt 0 ]; then
    for pubspec in "$@"; do strip_one "$pubspec"; done
else
    for pubspec in "$ROOT_DIR"/packages/*/pubspec.yaml \
                   "$ROOT_DIR"/packages/*/example/pubspec.yaml; do
        [ -f "$pubspec" ] && strip_one "$pubspec"
    done
fi
