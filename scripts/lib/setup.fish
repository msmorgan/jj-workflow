set -q __setup_done; and return
set -g __setup_done

# Each caller passes the programs it needs (e.g. `jj flock`, `perl`); we only
# check those. No hard-coded deps — this toolkit fetches nothing.
set -l deps_ok
for program in $argv
    if not command -q $program
        echo >&2 "setup.fish: missing needed program $program"
        set -e deps_ok
    end
end
set -q deps_ok; or return 1

set -g project_dir (path resolve (status dirname)/../..)
set -g scripts_dir $project_dir/scripts
set -g lib_dir $scripts_dir/lib
