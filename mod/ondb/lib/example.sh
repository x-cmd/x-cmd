# shellcheck shell=dash
# onDB example.sh — end-to-end smoke test
# Usage: sh lib/example.sh [--use-sqlite]
. "$HOME/.x-cmd.root/X"

USE_SQLITE=0
[ "${1:-}" = "--use-sqlite" ] && USE_SQLITE=1

# ── Setup ────────────────────────────────────────────────────
TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT
D="$TMPDIR/onto"

if [ "$USE_SQLITE" = 1 ]; then
    mkdir -p "${___X_CMD_ROOT_DATA:-$HOME/.x-cmd.root/data}/sqlite/mode"
    : > "${___X_CMD_ROOT_DATA:-$HOME/.x-cmd.root/data}/sqlite/mode/sqlite_enable"
fi

pass=0 fail=0
assert(){
    local label="$1" expected="$2" actual="$3"
    if [ "$expected" = "$actual" ]; then
        pass=$(( pass + 1 ))
    else
        fail=$(( fail + 1 ))
        printf "FAIL  %s\n  expected: %s\n  actual:   %s\n" "$label" "$expected" "$actual"
    fi
}
assert_contains(){
    local label="$1" needle="$2" haystack="$3"
    case "$haystack" in *"$needle"*) pass=$(( pass + 1 )) ;; *)
        fail=$(( fail + 1 ))
        printf "FAIL  %s\n  expected to contain: %s\n  actual: %s\n" "$label" "$needle" "$haystack"
    esac
}
assert_not_contains(){
    local label="$1" needle="$2" haystack="$3"
    case "$haystack" in *"$needle"*)
        fail=$(( fail + 1 ))
        printf "FAIL  %s\n  should NOT contain: %s\n  actual: %s\n" "$label" "$needle" "$haystack" ;;
    *) pass=$(( pass + 1 )) ;;
    esac
}

# ── 1. Create entities ───────────────────────────────────────
printf "\n=== 1. add ===\n"

out="$( x ondb add --type Project --name "P1" --id proj_001 -d "$D" )"
assert "add proj_001 id" "id	proj_001" "$out"

out="$( x ondb add --type Task --name "T1" --id t1 -d "$D" )"
assert "add t1 id" "id	t1" "$out"

out="$( x ondb add --type Task --name "T2" --id t2 -d "$D" -- status=open )"
assert "add t2 id" "id	t2" "$out"

out="$( x ondb add --type Task --name "T3" --id t3 -d "$D" -- status=blocked )"
assert "add t3 id" "id	t3" "$out"

out="$( x ondb add --type Task --name "T4" --id t4 -d "$D" -- status=open priority=high )"
assert "add t4 with multiple props" "id	t4" "$out"

out="$( x ondb add --type Event --name "Sprint Planning" --id ev1 -d "$D" -- date=2026-05-27 )"
assert "add ev1 id" "id	ev1" "$out"

out="$( x ondb add --type Person --name "Bob" --id p2 -d "$D" )"
assert "add p2 id" "id	p2" "$out"

# ── 2. Link entities ─────────────────────────────────────────
printf "\n=== 2. link ===\n"

out="$( x ondb link --from proj_001 --rel has_task --to t1 -d "$D" )"
assert_contains "link proj→t1" "linked" "$out"

out="$( x ondb link --from proj_001 --rel has_task --to t2 -d "$D" )"
assert_contains "link proj→t2" "linked" "$out"

out="$( x ondb link --from t2 --rel blocks --to t3 -d "$D" )"
assert_contains "link t2→t3 blocks" "linked" "$out"

# Duplicate link should be silently skipped (no error, no duplicate)
out="$( x ondb link --from proj_001 --rel has_task --to t1 -d "$D" )"
assert_not_contains "dup link should be skipped" "linked" "$out"

# Link to non-existent entity should fail
out="$( x ondb link --from proj_001 --rel has_task --to nonexistent -d "$D" 2>&1 )"
assert_not_contains "link to nonexistent should fail" "linked" "$out"

# ── 3. Set properties ────────────────────────────────────────
printf "\n=== 3. set ===\n"

out="$( x ondb set --id t1 -d "$D" -- status=done )"
assert_contains "set t1 status" "updated" "$out"

out="$( x ondb set --id t2 -d "$D" -- priority=high )"
assert_contains "set t2 priority" "updated" "$out"

# Set on non-existent entity should fail
out="$( x ondb set --id nonexistent -d "$D" -- status=x 2>&1 )"
assert_not_contains "set nonexistent should fail" "updated" "$out"

# ── 4. Get (before compact) ──────────────────────────────────
printf "\n=== 4. get (pre-compact) ===\n"

out="$( x ondb get --id t1 -d "$D" )"
assert_contains "get t1 has type Task" "Task" "$out"
assert_contains "get t1 has status=done" "status=done" "$out"

out="$( x ondb get --id t4 -d "$D" )"
assert_contains "get t4 has status=open" "status=open" "$out"
assert_contains "get t4 has priority=high" "priority=high" "$out"

# ── 5. Query (before compact) ────────────────────────────────
printf "\n=== 5. query (pre-compact) ===\n"

out="$( x ondb query --type Task --where status=open -d "$D" )"
assert_contains "query status=open: t2" "t2" "$out"
assert_contains "query status=open: t4" "t4" "$out"
assert_not_contains "query status=open excludes t1" "t1" "$out"
assert_not_contains "query status=open excludes proj" "proj_001" "$out"

out="$( x ondb query --where status=blocked -d "$D" )"
assert_contains "query status=blocked: t3" "t3" "$out"
assert_not_contains "query status=blocked excludes t2" "t2" "$out"

out="$( x ondb query --type Task -d "$D" )"
assert_contains "query type Task: t1" "t1" "$out"
assert_contains "query type Task: t4" "t4" "$out"
assert_not_contains "query type Task excludes proj" "proj_001" "$out"

# ── 6. Compact ───────────────────────────────────────────────
printf "\n=== 6. compact ===\n"

out="$( x ondb compact -d "$D" )"
assert_contains "compact snapshot" "snapshot" "$out"
if [ "$USE_SQLITE" = 1 ]; then
    assert_contains "compact db" "db" "$out"
fi

# ── 7. Post-compact get ──────────────────────────────────────
printf "\n=== 7. get (post-compact) ===\n"

out="$( x ondb get --id t1 -d "$D" )"
assert_contains "get t1 post-compact: Task" "Task" "$out"
assert_contains "get t1 post-compact: status=done" "status=done" "$out"

out="$( x ondb get --id t4 -d "$D" )"
assert_contains "get t4 post-compact: status=open" "status=open" "$out"
assert_contains "get t4 post-compact: priority=high" "priority=high" "$out"

# ── 8. Post-compact query ────────────────────────────────────
printf "\n=== 8. query (post-compact) ===\n"

out="$( x ondb query --type Task --where status=open -d "$D" )"
assert_contains "post-compact query status=open: t2" "t2" "$out"
assert_contains "post-compact query status=open: t4" "t4" "$out"
assert_not_contains "post-compact query status=open excludes t1" "t1" "$out"

out="$( x ondb query --where status=blocked -d "$D" )"
assert_contains "post-compact query blocked: t3" "t3" "$out"

out="$( x ondb query --type Task --where status=done -d "$D" )"
assert_contains "post-compact query done: t1" "t1" "$out"
assert_not_contains "post-compact query done excludes t2" "t2" "$out"

# ── 9. List ──────────────────────────────────────────────────
printf "\n=== 9. ls ===\n"

out="$( x ondb ls -d "$D" )"
assert_contains "ls all: proj_001" "proj_001" "$out"
assert_contains "ls all: t1" "t1" "$out"

out="$( x ondb ls --type Task -d "$D" )"
assert_contains "ls Task: t1" "t1" "$out"
assert_contains "ls Task: t4" "t4" "$out"
assert_not_contains "ls Task excludes proj" "proj_001" "$out"

# ── 10. Linked ───────────────────────────────────────────────
printf "\n=== 10. linked ===\n"

out="$( x ondb linked --id proj_001 -d "$D" )"
assert_contains "linked proj outgoing: t1" "t1" "$out"
assert_contains "linked proj outgoing: t2" "t2" "$out"

out="$( x ondb linked --id t1 --direction incoming -d "$D" )"
assert_contains "linked t1 incoming: proj_001" "proj_001" "$out"

out="$( x ondb linked --id t2 --direction both -d "$D" )"
assert_contains "linked t2 both: proj_001" "proj_001" "$out"
assert_contains "linked t2 both: t3" "t3" "$out"

# ── 11. Unlink + Rm ─────────────────────────────────────────
printf "\n=== 11. unlink + rm ===\n"

out="$( x ondb unlink --from t2 --rel blocks --to t3 -d "$D" )"
assert_contains "unlink t2→t3" "unlinked" "$out"

out="$( x ondb rm --id t3 -d "$D" )"
assert_contains "rm t3" "deleted" "$out"

# ── 12. Link with props ─────────────────────────────────────
printf "\n=== 12. link with props ===\n"

out="$( x ondb link --from ev1 --rel attended_by --to p2 -d "$D" -- role=facilitator )"
assert_contains "link with props" "linked" "$out"

out="$( x ondb linked --id ev1 --json -d "$D" )"
assert_contains "linked ev1 json has link_props" "link_props" "$out"

out="$( x ondb rm --id t4 -d "$D" )"
assert_contains "rm t4" "deleted" "$out"

# ── 12. Post-mutation queries ───────────────────────────────
printf "\n=== 12. post-mutation queries ===\n"

out="$( x ondb ls -d "$D" )"
assert_not_contains "ls after rm excludes t3" "t3" "$out"
assert_not_contains "ls after rm excludes t4" "t4" "$out"
assert_contains "ls after rm: t1" "t1" "$out"
assert_contains "ls after rm: t2" "t2" "$out"

out="$( x ondb linked --id t2 --direction outgoing -d "$D" )"
assert_not_contains "linked after unlink excludes t3" "t3" "$out"

out="$( x ondb query --type Task --where status=open -d "$D" )"
assert_contains "post-rm query open: t2" "t2" "$out"
assert_not_contains "post-rm query open excludes t4" "t4" "$out"

# ── 13. Property deletion ────────────────────────────────────
printf "\n=== 13. property deletion ===\n"

out="$( x ondb set --id t2 -d "$D" -- priority= )"
assert_contains "set delete priority" "updated" "$out"

out="$( x ondb get --id t2 -d "$D" )"
assert_not_contains "priority deleted from t2" "priority=" "$out"
assert_contains "t2 still has status=open" "status=open" "$out"

# ── 14. JSON output ──────────────────────────────────────────
printf "\n=== 14. json output ===\n"

out="$( x ondb ls --json -d "$D" )"
assert_contains "ls json has [" "[" "$out"
assert_contains "ls json has proj_001" "proj_001" "$out"

out="$( x ondb query --type Task --json -d "$D" )"
assert_contains "query json has Task" "Task" "$out"
assert_not_contains "query json excludes Project" "Project" "$out"

out="$( x ondb get --id proj_001 --json -d "$D" )"
assert_contains "get proj json has name" '"name"' "$out"

out="$( x ondb linked --id proj_001 --json -d "$D" )"
assert_contains "linked json has t1" "t1" "$out"

# ── 15. Validate ─────────────────────────────────────────────
printf "\n=== 15. validate ===\n"

out="$( x ondb validate -d "$D" )"
# Should return 0 errors for a consistent graph
assert "validate passes" "0" "$?"

# ── 16. Second compact ───────────────────────────────────────
printf "\n=== 16. second compact ===\n"

out="$( x ondb compact -d "$D" )"
assert_contains "compact2 snapshot" "snapshot" "$out"

# Verify data survived second compact
out="$( x ondb ls -d "$D" )"
assert_contains "ls after compact2: t1" "t1" "$out"
assert_not_contains "ls after compact2 excludes t3" "t3" "$out"

out="$( x ondb query --type Task --where status=done -d "$D" )"
assert_contains "query after compact2: t1 done" "t1" "$out"

# ── Summary ──────────────────────────────────────────────────
printf "\n═══ %d passed, %d failed ═══\n" "$pass" "$fail"
[ "$fail" = 0 ]
