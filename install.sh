#!/usr/bin/env bash
# Install the jj-workflow toolkit into a target repo.
#   install.sh [--copy] TARGET_REPO
# Default: symlink each script (so updates here propagate). --copy: independent copies.
set -euo pipefail

mode=symlink
if [ "${1:-}" = "--copy" ]; then mode=copy; shift; fi
target="${1:-}"
if [ -z "$target" ] || [ ! -d "$target" ]; then
    echo "usage: install.sh [--copy] TARGET_REPO (an existing directory)" >&2
    exit 2
fi
src="$(cd "$(dirname "$0")" && pwd)/scripts"
target="$(cd "$target" && pwd)"

mkdir -p "$target/scripts/hooks" "$target/scripts/lib"
while IFS= read -r -d '' f; do
    rel="${f#"$src"/}"
    dest="$target/scripts/$rel"
    mkdir -p "$(dirname "$dest")"
    if [ "$mode" = symlink ]; then
        ln -sfn "$f" "$dest"
    else
        cp "$f" "$dest"
    fi
done < <(find "$src" -type f -print0)

cp "$(dirname "$0")/jjworkflow.example.toml" "$target/jjworkflow.example.toml"

echo "Installed toolkit ($mode) into $target/scripts/"
echo
echo "Manual follow-ups:"
echo "  1. Register the PreToolUse(Bash) guard scripts/hooks/jj_guard.fish in the"
echo "     target's Claude settings (.claude/settings.json)."
echo "  2. If defaults don't fit, copy jjworkflow.example.toml -> jjworkflow.toml and edit."
echo "  3. Add a scripts/provision-workspace hook if new workspaces need shared dirs."
