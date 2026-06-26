#!/usr/bin/env bash
# Smoke: install the toolkit into a throwaway jj repo, start a workspace, integrate it.
set -euo pipefail
tk="$(cd "$(dirname "$0")/.." && pwd)"
work="$(mktemp -d)"
cd "$work"
jj git init --colocate >/dev/null
"$tk/install.sh" "$work" >/dev/null
git config user.email t@t || true; git config user.name t || true
# Commit the installed scripts so jj tracks them and they propagate to new workspaces.
# (jj workspace add checks out a commit; untracked files stay only in the default WC.)
jj commit -m "install toolkit" >/dev/null

# default workspace must exist for the workflow's trunk model
./scripts/workflow start feat-x
test -d ../feat-x
echo "ok: workspace ../feat-x created"
( cd ../feat-x && echo "hello" > note.txt && ./scripts/jj describe -m "feat: note" >/dev/null )
./scripts/workflow integrate feat-x >/dev/null
test ! -d ../feat-x
echo "ok: workspace archived after integrate"
echo "SMOKE PASS"
