#!/usr/bin/env fish
# Install the jj-workflow toolkit into a target repo.
#   install.fish [--copy] TARGET_REPO
# Default: symlink each script (so updates here propagate). --copy: independent copies.

argparse copy -- $argv
or exit 2

set -l target $argv[1]
if test -z "$target"; or not test -d "$target"
    echo >&2 "usage: install.fish [--copy] TARGET_REPO (an existing directory)"
    exit 2
end

set -l here (path resolve (status dirname))
set -l src $here/scripts
set target (path resolve $target)

set -l mode symlink
set -q _flag_copy; and set mode copy

mkdir -p "$target/scripts/hooks" "$target/scripts/lib"
for f in (find $src -type f)
    set -l rel (string replace "$src/" '' $f)
    set -l dest "$target/scripts/$rel"
    mkdir -p (path dirname "$dest")
    if test "$mode" = copy
        cp "$f" "$dest"
    else
        ln -sfn "$f" "$dest"
    end
end

# Drop the example config so the follow-up below is actionable.
cp "$here/jjworkflow.example.toml" "$target/jjworkflow.example.toml"

echo "Installed toolkit ($mode) into $target/scripts/"
echo
echo "Manual follow-ups:"
echo "  1. Register the PreToolUse(Bash) guard scripts/hooks/jj_guard.fish in the"
echo "     target's Claude settings (.claude/settings.json)."
echo "  2. If defaults don't fit, copy jjworkflow.example.toml -> jjworkflow.toml and edit."
echo "  3. Add a scripts/provision-workspace hook if new workspaces need shared dirs."
