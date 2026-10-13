#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2024-2026 us4us Ltd.
# SPDX-License-Identifier: MIT
#
# Build the nson Conan package from a pristine source tree in a temporary
# directory, then upload exactly that revision to a selected Conan remote.
#
# Why not just upload the GitHub release asset: nson-<version>.zip is a plain
# header archive, not a Conan package, and it does not contain recipes/, so the
# recipe is always needed to produce something uploadable. --from-release and
# --release-zip therefore take the recipe from the git ref and only swap in the
# archive's headers, which is a useful way to confirm that what was published
# on the release page is what ends up in the package.

set -euo pipefail

readonly PROG=${0##*/}
readonly REPO_ROOT=$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)
readonly RECIPE_DIR=recipes/nson/all
readonly CONFIG_YML=recipes/nson/config.yml
readonly GITHUB_REPO=us4useu/nson
readonly CPPSTD=23

REMOTE=""
VERSION=""
REF=""
USE_LOCAL=0
RELEASE_ZIP=""
FROM_RELEASE=0
WITH_TEST=0
DRY_RUN=0
KEEP=0

usage() {
    cat <<EOF
Usage: $PROG --remote NAME [options]

Builds nson as a Conan package in a temporary directory and uploads that exact
recipe/package revision to the given remote.

Required:
  -r, --remote NAME     Conan remote to upload to (must already be configured
                        and logged in; see "Remotes" below).

Source selection (default: the git tag v<version>):
      --ref REF         Build from this git ref (tag/branch/commit).
      --local           Build from the current working tree instead of a git
                        ref, including uncommitted changes.
      --from-release    Download nson-<version>.zip from the GitHub release
                        for v<version> and package its headers (recipe still
                        comes from --ref/--local).
      --release-zip F   Same, but use a local archive instead of downloading.

Other options:
  -v, --version X.Y.Z   Version to build. Default: the single version declared
                        in $CONFIG_YML.
      --with-test       Also build recipes/nson/all/test_package. Off by
                        default because it needs a C++23 toolchain with
                        <format> (gcc 13+); the package itself is header-only
                        and builds with any compiler.
  -n, --dry-run         Do everything except the actual upload.
      --keep            Do not delete the temporary build directory.
  -h, --help            Show this help.

Anything after a bare -- is passed through to "conan create".

Remotes:
  Configured remotes are listed with "conan remote list". To add one:
    conan remote add us4us https://nexus.example.com/repository/conan-hosted/
    conan remote add cloudsmith https://conan.cloudsmith.io/<org>/<repo>/
  then authenticate once:
    conan remote login <name> <user>
  Check the repository's own setup page for its exact URL.

Examples:
  $PROG --remote us4us-conan2-hosted --ref v0.1.0
  $PROG --remote cloudsmith --local --dry-run
  $PROG --remote cloudsmith --from-release --version 0.1.0
EOF
}

die() { printf '%s: error: %s\n' "$PROG" "$*" >&2; exit 1; }
note() { printf '==> %s\n' "$*"; }

passthrough=()
while [ $# -gt 0 ]; do
    case "$1" in
        -r|--remote)      REMOTE=${2:?missing value for $1}; shift 2 ;;
        -v|--version)     VERSION=${2:?missing value for $1}; shift 2 ;;
        --ref)            REF=${2:?missing value for $1}; shift 2 ;;
        --local)          USE_LOCAL=1; shift ;;
        --from-release)   FROM_RELEASE=1; shift ;;
        --release-zip)    RELEASE_ZIP=${2:?missing value for $1}; shift 2 ;;
        --with-test)      WITH_TEST=1; shift ;;
        -n|--dry-run)     DRY_RUN=1; shift ;;
        --keep)           KEEP=1; shift ;;
        -h|--help)        usage; exit 0 ;;
        --)               shift; passthrough=("$@"); break ;;
        *)                die "unknown argument '$1' (see --help)" ;;
    esac
done

[ -n "$REMOTE" ] || { usage >&2; die "--remote is required"; }
command -v conan >/dev/null || die "conan not found in PATH"

# ---------------------------------------------------------------- version ----

if [ -z "$VERSION" ]; then
    VERSION=$(python3 - "$REPO_ROOT/$CONFIG_YML" <<'PY'
import sys, yaml
versions = list(yaml.safe_load(open(sys.argv[1]))["versions"])
if len(versions) != 1:
    sys.exit(f"expected exactly one version in config.yml, found {versions}")
print(versions[0])
PY
    ) || die "could not read the version from $CONFIG_YML (pass --version)"
fi
[ -n "$REF" ] || REF="v$VERSION"

# ----------------------------------------------------------------- remote ----

# Note: the JSON is passed through the environment because these snippets are
# fed to python on stdin, so stdin is not available for piping.
CONAN_JSON=$(conan remote list --format=json) || die "could not list conan remotes"
CONAN_JSON="$CONAN_JSON" python3 - "$REMOTE" <<'PY' || exit 1
import json, os, sys
remote = sys.argv[1]
names = [r["name"] for r in json.loads(os.environ["CONAN_JSON"])]
if remote not in names:
    sys.exit(f"remote '{remote}' is not configured. Known remotes: {', '.join(names)}\n"
             f"Add it with: conan remote add {remote} <url>")
PY

CONAN_JSON=$(conan remote list-users --format=json) || die "could not list conan users"
CONAN_JSON="$CONAN_JSON" python3 - "$REMOTE" <<'PY' || exit 1
import json, os, sys
remote = sys.argv[1]
for r in json.loads(os.environ["CONAN_JSON"]):
    if r["name"] == remote and not r["authenticated"]:
        sys.exit(f"not logged in to '{remote}'. Run: conan remote login {remote} <user>")
PY

# ------------------------------------------------------------ build inputs ----

WORK=$(mktemp -d "${TMPDIR:-/tmp}/nson-conan-upload.XXXXXXXX")
cleanup() {
    if [ "$KEEP" -eq 1 ]; then
        note "kept build directory: $WORK"
    else
        rm -rf "$WORK"
    fi
}
trap cleanup EXIT

SRC="$WORK/src"
mkdir -p "$SRC"

if [ "$USE_LOCAL" -eq 1 ]; then
    note "staging the working tree (uncommitted changes included)"
    # Only the inputs the recipe reads: headers, recipe, and the packaged files.
    for path in nson "$RECIPE_DIR" "$CONFIG_YML" LICENSE README.md; do
        [ -e "$REPO_ROOT/$path" ] || die "missing '$path' in $REPO_ROOT"
        mkdir -p "$SRC/$(dirname "$path")"
        cp -R "$REPO_ROOT/$path" "$SRC/$(dirname "$path")/"
    done
else
    git -C "$REPO_ROOT" rev-parse --verify --quiet "$REF^{commit}" >/dev/null \
        || die "git ref '$REF' does not exist. Create the tag first, or use --ref/--local."
    note "staging git ref $REF ($(git -C "$REPO_ROOT" rev-parse --short "$REF^{commit}"))"
    git -C "$REPO_ROOT" archive --format=tar "$REF" | tar -x -C "$SRC"
fi

if [ "$FROM_RELEASE" -eq 1 ] && [ -z "$RELEASE_ZIP" ]; then
    RELEASE_ZIP="$WORK/nson-$VERSION.zip"
    url="https://github.com/$GITHUB_REPO/releases/download/v$VERSION/nson-$VERSION.zip"
    note "downloading $url"
    curl -fsSL --retry 3 -o "$RELEASE_ZIP" "$url" \
        || die "could not download the release asset for v$VERSION"
fi

if [ -n "$RELEASE_ZIP" ]; then
    [ -f "$RELEASE_ZIP" ] || die "release archive '$RELEASE_ZIP' not found"
    command -v unzip >/dev/null || die "unzip not found in PATH"
    note "packaging headers from $(basename "$RELEASE_ZIP")"
    unzip -q "$RELEASE_ZIP" -d "$WORK/release"
    headers=$(find "$WORK/release" -maxdepth 3 -type d -name nson -print -quit)
    [ -n "$headers" ] || die "no nson/ directory inside '$RELEASE_ZIP'"
    rm -rf "$SRC/nson"
    cp -R "$headers" "$SRC/nson"
    if ! diff -qr "$SRC/nson" "$REPO_ROOT/nson" >/dev/null 2>&1; then
        note "note: release headers differ from $REPO_ROOT/nson"
    fi
fi

# ------------------------------------------------------------------ build ----

create_args=(--version="$VERSION" -s compiler.cppstd="$CPPSTD" --build=missing
             --format=json)
[ "$WITH_TEST" -eq 1 ] || create_args+=(--test-folder=)
[ ${#passthrough[@]} -eq 0 ] || create_args+=("${passthrough[@]}")

note "conan create nson/$VERSION"
if ! (cd "$SRC" && conan create "$RECIPE_DIR" "${create_args[@]}" \
        > "$WORK/create.json" 2> "$WORK/create.log"); then
    cat "$WORK/create.log" >&2
    die "conan create failed"
fi

PINNED=$(python3 - "$WORK/create.json" <<'PY'
import json, sys
graph = json.load(open(sys.argv[1]))["graph"]["nodes"]
for node in graph.values():
    ref = node.get("ref")
    if ref and ref != "conanfile" and ref.startswith("nson/"):
        print(f"{ref}:{node['package_id']}#{node['prev']}")
        break
else:
    sys.exit("could not find the nson node in the conan create output")
PY
) || die "could not determine the built revision"

note "built $PINNED"

# ----------------------------------------------------------------- upload ----

upload_args=("$PINNED" -r "$REMOTE" --confirm)
[ "$DRY_RUN" -eq 0 ] || upload_args+=(--dry-run)

if [ "$DRY_RUN" -eq 1 ]; then
    note "uploading to '$REMOTE' (dry run)"
else
    note "uploading to '$REMOTE'"
fi
conan upload "${upload_args[@]}"

if [ "$DRY_RUN" -eq 1 ]; then
    note "dry run finished; nothing was uploaded"
else
    note "uploaded $PINNED to '$REMOTE'"
fi
