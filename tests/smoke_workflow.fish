#!/usr/bin/env fish
# Smoke: install the toolkit into a throwaway jj repo, start a workspace, integrate it.
# Fish has no `set -e`, so each step that must succeed is guarded with `; or ...`.

set -l tk (path resolve (status dirname)/..)
set -l work (mktemp -d)
cd $work; or exit 1

jj git init --colocate >/dev/null; or begin
    echo >&2 "smoke: jj git init failed"
    exit 1
end
$tk/install.fish $work >/dev/null; or begin
    echo >&2 "smoke: install failed"
    exit 1
end
git config user.email t@t 2>/dev/null
git config user.name t 2>/dev/null

# Commit the installed scripts so jj tracks them and they propagate to new workspaces.
# (jj workspace add checks out a commit; untracked files stay only in the default WC.)
jj commit -m "install toolkit" >/dev/null; or begin
    echo >&2 "smoke: commit failed"
    exit 1
end

# default workspace must exist for the workflow's trunk model
./scripts/workflow start feat-x; or begin
    echo >&2 "smoke: workflow start failed"
    exit 1
end
test -d ../feat-x; or begin
    echo >&2 "smoke: ../feat-x was not created"
    exit 1
end
echo "ok: workspace ../feat-x created"

pushd ../feat-x
echo hello >note.txt
./scripts/jj describe -m "feat: note" >/dev/null; or begin
    echo >&2 "smoke: describe failed"
    popd
    exit 1
end
popd

./scripts/workflow integrate feat-x >/dev/null; or begin
    echo >&2 "smoke: integrate failed"
    exit 1
end
test ! -d ../feat-x; or begin
    echo >&2 "smoke: ../feat-x was not archived after integrate"
    exit 1
end
echo "ok: workspace archived after integrate"
echo "SMOKE PASS"
