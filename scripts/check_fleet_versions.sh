#!/bin/bash
set -e
# Fleet version parity check (spec 1205 FR-11 / US5).
#
# Fails — naming the offending member — unless:
#   1. every federated member's pubspec version equals the fleet version,
#   2. the in-family dependency constraints (including the family `zuraffa`
#      constraint in the app package) read ^<fleet version>,
#   3. the root README's install guide shows the fleet version.
#
# Releases only ever move versions via the fleet mono bump
# (`../zuraffa/scripts/update_fleet.sh`), so any drift here means a member
# was touched outside the family — never publish out of family (PUBLISH.md).

GREEN='\033[0;32m'; RED='\033[0;31m'; NC='\033[0m'

ROOT_DIR="$(cd "$(dirname "$0")/.." >/dev/null 2>&1; pwd -P)"
cd "$ROOT_DIR"

MEMBERS="zuraffa_permissions zuraffa_permissions_platform_interface zuraffa_permissions_android zuraffa_permissions_ios zuraffa_permissions_macos"

fail() { echo -e "${RED}fleet parity FAIL: $1${NC}"; exit 1; }

version_of() { grep '^version:' "packages/$1/pubspec.yaml" | sed 's/version: //' | tr -d '[:space:]'; }

VERSION="$(version_of zuraffa_permissions)"
[ -n "$VERSION" ] || fail "cannot read the fleet version from packages/zuraffa_permissions/pubspec.yaml"

for member in $MEMBERS; do
    v="$(version_of "$member")"
    [ "$v" = "$VERSION" ] || fail "member $member is at $v, fleet is at $VERSION — mono versions must agree"
done

grep -q "^  zuraffa: \^$VERSION$" packages/zuraffa_permissions/pubspec.yaml \
    || fail "packages/zuraffa_permissions no longer constrains the family core at zuraffa: ^$VERSION"

for member in zuraffa_permissions_platform_interface zuraffa_permissions_android zuraffa_permissions_ios zuraffa_permissions_macos; do
    grep -q "^  zuraffa_permissions: \^$VERSION$" "packages/$member/pubspec.yaml" \
        || fail "$member no longer constrains zuraffa_permissions at ^$VERSION"
done

for member in zuraffa_permissions_android zuraffa_permissions_ios zuraffa_permissions_macos; do
    grep -q "^  zuraffa_permissions_platform_interface: \^$VERSION$" "packages/$member/pubspec.yaml" \
        || fail "$member no longer constrains zuraffa_permissions_platform_interface at ^$VERSION"
done

grep -q "zuraffa_permissions: \^$VERSION" README.md \
    || fail "README install guide does not show the fleet version (^$VERSION) — update it in the same change as any version bump (PUBLISH.md)"

echo -e "${GREEN}fleet parity OK: all members at $VERSION, family constraints at ^$VERSION, README install guide matches${NC}"
