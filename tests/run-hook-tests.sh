#!/usr/bin/env bash
# Contract tests for hi-claude hooks: pipe a fixture into a hook, assert on its output.
# Usage: bash tests/run-hook-tests.sh
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FIX="$ROOT/tests/fixtures"
pass=0; fail=0

# ONE run at a time. The bench shares a scratch dir and session-keyed markers in the temp dir, so two
# concurrent runs overwrite each other's state - measured, they produced 20 and 7 failures against
# 172/0 in isolation, and that red is indistinguishable from a real regression. `mkdir` is the atomic
# test-and-set every POSIX shell has; aborting loudly beats reporting a failure that is not there.
LOCK="${TMPDIR:-/tmp}/hi-claude-bench.lock"
if ! mkdir "$LOCK" 2>/dev/null; then
  printf 'ABORT  another run of this bench is already in progress (%s).\n' "$LOCK"
  printf '       It shares scratch state, so running two at once reports red that is not a regression.\n'
  printf '       Wait for it to finish, or remove that directory if no run is alive.\n'
  exit 2
fi
trap 'rm -rf "$LOCK" 2>/dev/null' EXIT INT TERM

ok()  { printf 'PASS  %s\n' "$1"; pass=$((pass+1)); }
ko()  { printf 'FAIL  %s\n      got: %s\n' "$1" "$(printf '%s' "$2" | head -c 300)"; fail=$((fail+1)); }

# run_hook <hook> <fixture-file> -> stdout of the hook
run_hook() { bash "$ROOT/hooks/$1" < "$2" 2>/dev/null || true; }

# envelope <name> <hook> <fixture-file> json|plain [expected hookEventName]
#   Claude Code validates hook stdout against a schema union. An event that is NOT
#   in that union must print PLAIN text; printing JSON makes the hook fail validation
#   and its output is dropped silently. Substring assertions cannot see that class of
#   bug: the text is right, the envelope is wrong. This checks the envelope.
envelope() {
  local name="$1" hook="$2" fixture="$3" kind="$4" event="${5:-}" out
  out=$(run_hook "$hook" "$fixture")
  case "$kind" in
    plain)
      case "$out" in
        "{"*) ko "$name" "$out" ;;
        *)    ok "$name" ;;
      esac ;;
    json)
      if printf '%s' "$out" | grep -qF "\"hookEventName\": \"$event\""; then ok "$name"; else ko "$name" "$out"; fi ;;
  esac
}

# check <name> <hook> <fixture-file> <mode> [pattern]
#   modes: contains | notcontains | empty
check() {
  local name="$1" hook="$2" fixture="$3" mode="$4" pattern="${5:-}" out
  out=$(run_hook "$hook" "$fixture")
  case "$mode" in
    contains)    printf '%s' "$out" | grep -qF -- "$pattern" && ok "$name" || ko "$name" "$out" ;;
    notcontains) printf '%s' "$out" | grep -qF -- "$pattern" && ko "$name" "$out" || ok "$name" ;;
    empty)       [ -z "$out" ] && ok "$name" || ko "$name" "$out" ;;
  esac
}

# make_project -> prints the path of a temp project carrying a ROADMAP with open work
make_project() {
  local d
  d="$(mktemp -d)"
  mkdir -p "$d/docs"
  cat > "$d/docs/ROADMAP.md" <<'ROADMAP'
# ROADMAP

## 0. Mapa de ejecucion
nada relevante aca

<!-- hi-claude:en-curso -->
## 1. EN CURSO

### Sellar el kickoff con hora  [V]
Falta: unificar los dos formatos de PK.
Ya resuelto: migracion escrita y testeada.

<!-- Formato de un item:
### Titulo imperativo  [V]
Falta: una linea.
-->
<!-- /hi-claude:en-curso -->

## 2. Otro bloque
esto no deberia inyectarse
ROADMAP
  printf '%s' "$d"
}

# fixture_with_cwd <fixture-name> <cwd> -> prints path of a temp fixture with __CWD__ replaced
fixture_with_cwd() {
  local out esc
  out="$(mktemp)"
  esc=$(printf '%s' "$2" | sed 's#\\#\\\\\\\\#g')
  sed "s#__CWD__#${esc}#" "$FIX/$1" > "$out"
  printf '%s' "$out"
}

# arm_files <session> <path>... -> arms the turn marker with those files, one PostToolUse each
#
# DISTINCT PATHS, because the marker holds one line per FILE: repeating one path arms a turn of ONE
# file. Running the same fixture three times used to arm three, and that stopped being true the moment
# the counter started meaning what its message says.
arm_files() {
  local sess="$1" p; shift
  rm -f "${TMPDIR:-/tmp}/hi-claude-turn-${sess}" "${TMPDIR:-/tmp}/hi-claude-size-${sess}"
  for p in "$@"; do
    printf '{"session_id":"%s","cwd":"C:\\\\proj","hook_event_name":"PostToolUse","tool_name":"Edit","tool_input":{"file_path":"%s","old_string":"a","new_string":"b"},"tool_response":{}}' \
      "$sess" "$p" > "$FIX/.arm-probe.json"
    run_hook tracker "$FIX/.arm-probe.json" >/dev/null
  done
  rm -f "$FIX/.arm-probe.json"
}

# stop_for <session> -> path of a Stop fixture keyed to THAT session. A Stop carrying another
# session reads an empty marker: the assertion measures nothing and looks exactly like a failure.
stop_for() {
  printf '{"session_id":"%s","cwd":"C:\\\\proj","hook_event_name":"Stop","stop_hook_active":false}' \
    "$1" > "$FIX/.stop-$1.json"
  printf '%s' "$FIX/.stop-$1.json"
}

# --- json-lib ---
. "$ROOT/hooks/json-lib"
out=$(escape_for_json 'a"b
c')
[ "$out" = 'a\"b\nc' ] && ok "json-lib: escape_for_json" || ko "json-lib: escape_for_json" "$out"
out=$(json_str '{"cwd":"C:\\proj","tool_name":"Write"}' tool_name)
[ "$out" = "Write" ] && ok "json-lib: json_str" || ko "json-lib: json_str" "$out"

# --- session-start ---
proj=$(make_project)
f=$(fixture_with_cwd session-start.json "$proj")
check "session-start: injects constitution" session-start "$f" contains "hi-claude-method"
check "session-start: injects open work"    session-start "$f" contains "Sellar el kickoff con hora"
check "session-start: stops at the marker"  session-start "$f" notcontains "esto no deberia inyectarse"
check "session-start: drops the scaffolding" session-start "$f" notcontains "Formato de un item"
rm -rf "$proj" "$f"

proj2=$(mktemp -d)
f2=$(fixture_with_cwd session-start.json "$proj2")
check "session-start: no roadmap, no noise" session-start "$f2" notcontains "## Open work (docs/ROADMAP.md)"
check "session-start: still injects method" session-start "$f2" contains "hi-claude-method"
rm -rf "$proj2" "$f2"

# A workspace that HOLDS repos keeps its register one level in. A session opened at the root used
# to see nothing at all — measured in this very repo-pair.
ws=$(mktemp -d); inner=$(make_project); mv "$inner" "$ws/the-repo"
f3=$(fixture_with_cwd session-start.json "$ws")
check "session-start: finds the register one level in" session-start "$f3" contains "Sellar el kickoff con hora"
# With two candidates, naming them beats picking one.
inner2=$(make_project); mv "$inner2" "$ws/other-repo"
f4=$(fixture_with_cwd session-start.json "$ws")
check "session-start: two registers, names them"  session-start "$f4" contains "Registers found below"
check "session-start: two registers, picks none"  session-start "$f4" notcontains "## Open work (docs/ROADMAP.md)"
rm -rf "$ws" "$f3" "$f4"

# --- guardian ---
check "guardian: subagent write is denied"   guardian "$FIX/subagent-write.json"        contains '"deny"'
check "guardian: subagent read passes"       guardian "$FIX/subagent-read.json"         empty
check "guardian: bash append to CLAUDE.md"   guardian "$FIX/bash-append-claude-md.json" contains '"ask"'
check "guardian: bash read of CLAUDE.md"     guardian "$FIX/bash-read-claude-md.json"   empty
check "guardian: write to CLAUDE.md"         guardian "$FIX/write-claude-md.json"       contains '"ask"'
check "guardian: edit memory file"           guardian "$FIX/edit-memory.json"           contains '"ask"'
check "guardian: normal write passes"        guardian "$FIX/write-normal.json"          empty
# The env-var escape is gone: a switch nobody can see in the session is a hole with a name.
out=$(HI_CLAUDE_SUBAGENT_WRITES=1 bash "$ROOT/hooks/guardian" < "$FIX/subagent-write.json")
printf '%s' "$out" | grep -qF '"deny"' && ok "guardian: env-var escape no longer unblocks" \
                                       || ko "guardian: env-var escape no longer unblocks" "$out"
n=$(grep -c 'HI_CLAUDE_SUBAGENT_WRITES' "$ROOT/hooks/guardian" || true)
[ "$n" -eq 0 ] && ok "guardian: escape hatch removed from source" \
               || ko "guardian: escape hatch removed from source" "$n mentions"

# --- subagent containment: no write path escapes, whatever the tool ---
# Each of these was measured passing before the matcher covered every tool and the Bash policy
# became an allowlist. A pattern hunt always trails the next command that writes.
check "subagent: MCP write is denied"        guardian "$FIX/subagent-mcp-write.json"        contains '"deny"'
check "subagent: interpreter write denied"   guardian "$FIX/subagent-bash-interpreter.json" contains '"deny"'
check "subagent: cp over CLAUDE.md denied"   guardian "$FIX/subagent-bash-copy.json"        contains '"deny"'
check "subagent: git commit denied"          guardian "$FIX/subagent-bash-git-commit.json"  contains '"deny"'
check "subagent: dispatching work denied"    guardian "$FIX/subagent-dispatch.json"         contains '"deny"'
# It may read, inspect, test and measure - that is the job.
check "subagent: test runner passes"         guardian "$FIX/subagent-bash-test.json"        empty
check "subagent: git status passes"          guardian "$FIX/subagent-bash-git-read.json"    empty
check "subagent: read-only MCP passes"       guardian "$FIX/subagent-mcp-read.json"         empty
# MCP policy is an ALLOWLIST of reading, not a blocklist of mutation. Measured: a blocklist is always
# one verb behind — `mcp__ide__executeCode` runs arbitrary code, writes anything, and matched no
# mutation verb. A tool whose name does not state that it READS is denied: the safe side of unknown.
mcpq() { printf '{"hook_event_name":"PreToolUse","agent_id":"a1","tool_name":"%s","tool_input":{}}' "$1" \
         | bash "$ROOT/hooks/guardian" 2>/dev/null; }
mcp_bad=0
for t in mcp__ide__executeCode mcp__filesystem__write_file mcp__db__run_migration \
         mcp__x__apply_patch mcp__x__deploy mcp__x__send_email mcp__x__install_package; do
  printf '%s' "$(mcpq "$t")" | grep -qF '"deny"' || { ko "mcp: denies $t" "passed"; mcp_bad=1; }
done
for t in mcp__context7__query-docs mcp__context7__resolve-library-id mcp__grep__searchGitHub \
         mcp__ide__getDiagnostics mcp__exa__web_search_exa mcp__x__list_tables mcp__x__read_file; do
  [ -z "$(mcpq "$t")" ] || { ko "mcp: allows $t" "denied - a subagent must be able to read"; mcp_bad=1; }
done
[ "$mcp_bad" -eq 0 ] && ok "mcp: allowlist of reading, everything else denied"
check "subagent: write to scratchpad passes" guardian "$FIX/subagent-write-temp.json"       empty
# The block is for subagents only: the main agent writes code without friction.
check "main agent: code write passes"        guardian "$FIX/main-agent-write.json"          empty
# False positives cost more than they protect: a prompt on every commit trains the user to click through.
#
# BOTH of these fixtures used to dodge the very defect they name. The commit carried no redirection
# and the read used `2>&1`, whose `&` the write-detector excludes - so the bench was green while real
# use asked on 277 of 285 commands (97,2%). They now carry the shape that fires: a redirection, and
# the `<noreply@anthropic.com>` of a commit trailer, which supplies a `>` all by itself.
check "guardian: commit mentioning CLAUDE.md" guardian "$FIX/bash-commit-mentions-claude-md.json" empty
check "guardian: a redirected grep is not a write" guardian "$FIX/bash-stderr-redirect.json"      empty
check "guardian: git READ of CLAUDE.md into a file" guardian "$FIX/bash-git-read-redirect.json"   empty
check "guardian: piping a diff to tee is a read"    guardian "$FIX/bash-tee-read-claude-md.json"  empty
# The other direction, in the same run: narrowing that lets a real write through is worse than the
# noise it removes, so each pass case has its write twin.
check "guardian: tee -a INTO CLAUDE.md asks"        guardian "$FIX/bash-tee-write-claude-md.json"     contains '"ask"'
check "guardian: redirect INTO CLAUDE.md asks"      guardian "$FIX/bash-redirect-into-claude-md.json" contains '"ask"'
check "guardian: deleting a memory asks"            guardian "$FIX/bash-rm-memory.json"               contains '"ask"'
# `sed` writes only with -i. Listing it unconditionally turned a READ into a confirmation prompt,
# which is the mention-vs-write confusion one level down.
bashq() { printf '{"hook_event_name":"PreToolUse","session_id":"TESTSESS","prompt_id":"T1","cwd":"C:\\\\proj","tool_name":"Bash","tool_input":{"command":"%s"}}' "$1" \
          | bash "$ROOT/hooks/guardian" 2>/dev/null; }
printf '%s' "$(bashq "sed -n '83p' CLAUDE.md")" | grep -qF '"ask"' \
  && ko "guardian: sed WITHOUT -i is a read" "asked" || ok "guardian: sed WITHOUT -i is a read"
printf '%s' "$(bashq "sed -i s/a/b/ CLAUDE.md")" | grep -qF '"ask"' \
  && ok "guardian: sed -i is a write" || ko "guardian: sed -i is a write" "passed"
# A separator inside quotes is text. It fabricated a phantom `rm` segment and asked to confirm a
# deletion nothing was performing.
printf '%s' "$(bashq "echo \\\"cuidado con | rm CLAUDE.md adentro\\\"")" | grep -qF '"ask"' \
  && ko "guardian: a quoted separator is not a separator" "asked" \
  || ok "guardian: a quoted separator is not a separator"

# --- subagent containment: a READ command with a WRITE FLAG is a write command ---
# The allowlist admits linters and runners by their SUBCOMMAND, and several rewrite the source when
# asked. Measured: all three of these passed the containment while editing the project.
subq() { printf '{"hook_event_name":"PreToolUse","agent_id":"sub1","session_id":"TESTSESS","cwd":"C:\\\\proj","tool_name":"Bash","tool_input":{"command":"%s"}}' "$1" \
         | bash "$ROOT/hooks/guardian" 2>/dev/null; }
sub_bad=0
for c in "cargo clippy --fix" "npm run lint -- --fix" "gradle check --write-locks"; do
  printf '%s' "$(subq "$c")" | grep -qF '"deny"' || { ko "subagent: denies '$c'" "passed"; sub_bad=1; }
done
# The other direction in the same run: the read-only forms must stay frictionless, or the fix is a ban.
for c in "cargo clippy" "npm run lint" "go vet ./..." "pytest tests/"; do
  [ -z "$(subq "$c")" ] || { ko "subagent: allows '$c'" "denied - it only reads"; sub_bad=1; }
done
[ "$sub_bad" -eq 0 ] && ok "subagent: a write FLAG is denied, the read-only form is not"

# --- containment must not deny the shell a READ is written in ---
# Two parse bugs, both reproduced live by subagents running under this hook. `2>/dev/null` was read as
# a destination and `is_temp` did not know the null sink, so every read carrying it was denied. And
# splitting the command with `tr ';|&'` cut `2>&1` into `2>` and `1`, leaving a phantom segment whose
# head matched no allowlist entry - so the whole command was denied for a redirection that writes
# nothing. Under a method that sends output to a file or to the void, that is most of what a subagent
# runs: the containment held and the investigation it exists to permit did not.
idiom_bad=0
for c in "ls 2>/dev/null" "echo hi 2>&1" "grep -r x . 2>/dev/null | head -5" \
         "cat a.md 2>&1 | wc -l" "git status 2>/dev/null" "find . -name x 2>/dev/null" \
         "pytest tests/ 2>&1" 'echo "a; b"'; do
  [ -z "$(subq "$c")" ] || { ko "subagent: allows '$c'" "denied - it writes nothing"; idiom_bad=1; }
done
# The controls run in the SAME pass, or the fix reads as "it stopped denying".
for c in "echo x > /c/proj/src/a.py" "git commit -m x" "cp /tmp/x /c/proj/src/a.py"; do
  printf '%s' "$(subq "$c")" | grep -qF '"deny"' || { ko "subagent: denies '$c'" "passed"; idiom_bad=1; }
done
[ "$idiom_bad" -eq 0 ] && ok "subagent: a redirection that writes nothing is not a write"

# --- the count means FILES, because that is what the message says and what the scale reads ---
# One file edited three times reported "3 file(s)" and earned the seven-step ritual. The threshold is
# calibrated on a distribution of FILES, so a counter of write EVENTS miscalibrates it by construction.
# The Stop fixture has to carry the SAME session as the writes, or the closer reads an empty marker
# and the assertion measures nothing while looking exactly like a failure.
count_of() {
  arm_files CNTSESS "$@"
  run_hook closer "$(stop_for CNTSESS)"
  rm -f "$FIX/.stop-CNTSESS.json" \
        "${TMPDIR:-/tmp}/hi-claude-turn-CNTSESS" "${TMPDIR:-/tmp}/hi-claude-size-CNTSESS"
}
out=$(count_of 'C:\\\\proj\\\\src\\\\a.py' 'C:\\\\proj\\\\src\\\\a.py' 'C:\\\\proj\\\\src\\\\a.py')
printf '%s' "$out" | grep -qF 'changed 1 file' \
  && ok "tracker: three edits to ONE file count as one" \
  || ko "tracker: three edits to ONE file count as one" "$out"
printf '%s' "$out" | grep -qF 'IN THIS ORDER' \
  && ko "closer: a one-file turn does not earn the ritual by repetition" "$out" \
  || ok "closer: a one-file turn does not earn the ritual by repetition"
out=$(count_of 'C:\\\\proj\\\\src\\\\a.py' 'C:\\\\proj\\\\src\\\\b.py' 'C:\\\\proj\\\\src\\\\c.py')
printf '%s' "$out" | grep -qF 'changed 3 file' \
  && ok "tracker: three DIFFERENT files still count as three" \
  || ko "tracker: three DIFFERENT files still count as three" "$out"

# --- what the START injects is what the CLOSE accepts, one level down included ---
# A workspace that holds repos keeps its register one level in and session-start injects it from
# there. A tracker that only accepted ${cwd} would let the turn update the very file it was handed
# and keep demanding - the two hooks agree only if they derive the SAME set.
level_bad=0
lvl() {
  rm -f "${TMPDIR:-/tmp}/hi-claude-turn-LVLSESS" "${TMPDIR:-/tmp}/hi-claude-size-LVLSESS"
  printf '{"session_id":"LVLSESS","cwd":"C:\\\\ws","hook_event_name":"PostToolUse","tool_name":"Write","tool_input":{"file_path":"C:\\\\ws\\\\repo\\\\src\\\\a.py","content":"x"},"tool_response":{}}' > "$FIX/.lvl-probe.json"
  run_hook tracker "$FIX/.lvl-probe.json" >/dev/null
  printf '{"session_id":"LVLSESS","cwd":"C:\\\\ws","hook_event_name":"PostToolUse","tool_name":"Write","tool_input":{"file_path":"%s","content":"x"},"tool_response":{}}' "$1" > "$FIX/.lvl-probe.json"
  run_hook tracker "$FIX/.lvl-probe.json" >/dev/null
  printf '{"session_id":"LVLSESS","cwd":"C:\\\\ws","hook_event_name":"Stop","stop_hook_active":false}' > "$FIX/.lvl-stop.json"
  run_hook closer "$FIX/.lvl-stop.json"
  rm -f "$FIX/.lvl-probe.json" "$FIX/.lvl-stop.json" \
        "${TMPDIR:-/tmp}/hi-claude-turn-LVLSESS" "${TMPDIR:-/tmp}/hi-claude-size-LVLSESS"
}
for p in 'C:\\\\ws\\\\repo\\\\docs\\\\ROADMAP.md' 'C:\\\\ws\\\\repo\\\\ROADMAP.md'; do
  [ -z "$(lvl "$p")" ] || { ko "register: one level in settles ($p)" "still blocked"; level_bad=1; }
done
for p in 'C:\\\\ws\\\\a\\\\b\\\\docs\\\\ROADMAP.md' 'C:\\\\ws\\\\vendor\\\\ROADMAP.md' 'C:\\\\ws\\\\.venv\\\\docs\\\\ROADMAP.md'; do
  printf '%s' "$(lvl "$p")" | grep -qF '"decision": "block"' \
    || { ko "register: $p must NOT settle" "it settled"; level_bad=1; }
done
[ "$level_bad" -eq 0 ] && ok "register: the close accepts exactly what the start injects"
# Writing rules ride along on markdown writes: as a skill description alone they never fired.
check "guardian: markdown write gets the rules" guardian "$FIX/write-markdown-doc.json" contains "TIMELESS"
check "guardian: markdown nudge is not a decision" guardian "$FIX/write-markdown-doc.json" notcontains "permissionDecision"
check "guardian: code write gets no nudge"      guardian "$FIX/write-normal.json"       empty
check "guardian: CLAUDE.md still asks, not nudges" guardian "$FIX/write-claude-md.json" notcontains "TIMELESS"
# Key order inside tool_input is model-controlled: a decoy file_path in the content
# must not shadow the real governed target.
check "guardian: decoy file_path cannot shadow" guardian "$FIX/write-shadowed-file-path.json" contains '"ask"'
# Paths carry spaces (this plugin is developed under one): word-splitting them would
# break the directory-shaped memory pattern.
check "guardian: memory path with spaces"      guardian "$FIX/edit-memory-path-with-spaces.json" contains '"ask"'

# --- subagent-start / pre-compact ---
check "subagent-start: states read-only role" subagent-start "$FIX/subagent-write.json" contains "HYPOTHES"
check "subagent-start: forbids implementing" subagent-start "$FIX/subagent-write.json" contains "not to implement"
check "subagent-start: forbids deciding"     subagent-start "$FIX/subagent-write.json" contains "NEVER determine what gets done"
check "subagent-start: carries no escape"    subagent-start "$FIX/subagent-write.json" contains "no escape switch"
# The limit has to travel WITH the finding: a report gets read outside the context that produced it.
check "subagent-start: demands the closing line" subagent-start "$FIX/subagent-write.json" contains "VERBATIM"
check "pre-compact: points at EN CURSO"      pre-compact    "$FIX/pre-compact.json"    contains "docs/ROADMAP.md"

# --- output envelopes must match what Claude Code's schema union accepts ---
proj=$(make_project); f=$(fixture_with_cwd session-start.json "$proj")
envelope "envelope: session-start is JSON SessionStart"   session-start  "$f"                      json  SessionStart
rm -rf "$proj" "$f"
envelope "envelope: subagent-start is JSON SubagentStart" subagent-start "$FIX/subagent-write.json" json  SubagentStart
envelope "envelope: guardian is JSON PreToolUse"          guardian       "$FIX/write-claude-md.json" json PreToolUse
envelope "envelope: pre-compact is PLAIN (not in union)"  pre-compact    "$FIX/pre-compact.json"    plain

# --- a stall reaches its protocol deterministically ---
# Measured on the harness: seeding-doubts fired 0/4 on its OWN explicit phrasings, one of them
# reaching for the roadmap skill instead. A stall is exactly when nothing feels like it needs a
# skill, so the trigger cannot live in a description.
sig() { printf '{"session_id":"s","cwd":"C:/p","hook_event_name":"UserPromptSubmit","prompt_text":"%s"}' "$1" \
        | bash "$ROOT/hooks/prompt-signals" 2>/dev/null; }
for q in "Algo anda mal y no se que" "Que se nos esta escapando, no mejora nunca" \
         "We are stuck. What are we missing?" "Nothing is improving. Take another look" \
         "no se puede" "It cannot be done"; do
  printf '%s' "$(sig "$q")" | grep -qF 'seeding-doubts' \
    && ok "stall: fires on \"$(printf '%s' "$q" | cut -c1-28)\"" \
    || ko "stall: fires on \"$(printf '%s' "$q" | cut -c1-28)\"" "silent"
done
# Ordinary work must stay silent - both of these are harness negatives.
for q in "Este test falla, arreglalo" "I am missing a dependency, install it" "Que falta para terminar esto"; do
  [ -z "$(sig "$q")" ] && ok "stall: silent on \"$(printf '%s' "$q" | cut -c1-24)\"" \
                       || ko "stall: silent on \"$(printf '%s' "$q" | cut -c1-24)\"" "fired"
done
# The prompt field name is read under both spellings: assuming one and being wrong fails silently.
printf '{"session_id":"s","hook_event_name":"UserPromptSubmit","prompt":"algo anda mal"}' \
  | bash "$ROOT/hooks/prompt-signals" | grep -qF 'seeding-doubts' \
  && ok "stall: reads the prompt under either field name" \
  || ko "stall: reads the prompt under either field name" "missed 'prompt'"
printf '{"session_id":"s","hook_event_name":"UserPromptSubmit","prompt_text":"algo anda mal"}' > "$FIX/prompt-stall.json"
envelope "envelope: prompt-signals is JSON UserPromptSubmit" prompt-signals "$FIX/prompt-stall.json" json UserPromptSubmit

# --- long jobs belong in the background ---
# A blocked wait costs the whole turn. The call is the only moment it can still be changed, so the
# check sits BEFORE the write detection: a test run writes nothing.
check "background: npm test gets the nudge"   guardian "$FIX/main-bash-long.json"  contains "run_in_background"
check "background: git status gets no nudge"  guardian "$FIX/main-bash-short.json" empty
check "background: the nudge is not a decision" guardian "$FIX/main-bash-long.json" notcontains "permissionDecision"
# A subagent may test and measure; the nudge must not turn into friction for it.
printf '%s\n' '{"session_id":"S","agent_id":"a1","hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"pytest tests/ -q"}}' > "$FIX/subagent-bash-pytest.json"
check "background: a subagent testing is untouched" guardian "$FIX/subagent-bash-pytest.json" empty

# --- seeding doubts fires ITSELF after a big block ---
# Measured on delegation and on the writing rules: a description never fires where nothing feels
# like it needs a skill, and finishing well is exactly that moment. So it arrives as an offer.
# TWO conditions, not one: the turn was big AND it CLOSED work (it wrote the register). Measured over
# this project's own history, size alone fires on 4 of 8 work blocks — an offer that shows up half the
# time is one that gets ignored.
SZ="${TMPDIR:-/tmp}/hi-claude-size-TESTSESS"
MK="${TMPDIR:-/tmp}/hi-claude-turn-TESTSESS"
rm -f "$SZ" "$MK"
i=0; while [ $i -lt 7 ]; do run_hook tracker "$FIX/post-write-code.json" >/dev/null; i=$((i+1)); done
out=$(run_hook closer "$FIX/stop.json")
printf '%s' "$out" | grep -qF 'seeding-doubts' && ko "premortem: size alone is not enough" "$out" \
                                              || ok "premortem: size alone is not enough"
rm -f "$SZ" "$MK"
i=0; while [ $i -lt 7 ]; do run_hook tracker "$FIX/post-write-code.json" >/dev/null; i=$((i+1)); done
run_hook tracker "$FIX/post-write-roadmap.json" >/dev/null
out=$(run_hook closer "$FIX/stop.json")
printf '%s' "$out" | grep -qF 'seeding-doubts' && ok "premortem: big block + closed work gets the offer" \
                                              || ko "premortem: big block + closed work gets the offer" "$out"
printf '%s' "$out" | grep -qF '"decision"' && ko "premortem: it offers, never blocks" "$out" \
                                           || ok "premortem: it offers, never blocks"
printf '%s' "$out" | grep -qF '"hookEventName": "Stop"' && ok "premortem: rides the Stop envelope" \
                                                        || ko "premortem: rides the Stop envelope" "$out"
rm -f "$SZ" "$MK"
run_hook tracker "$FIX/post-write-code.json" >/dev/null
run_hook tracker "$FIX/post-write-roadmap.json" >/dev/null
check "premortem: a small closed turn stays silent" closer "$FIX/stop.json" empty
rm -f "$SZ" "$MK"

# --- the closer closes the WHOLE loop, not just the register ---
# The rule is "every change updates docs, memory, the inventory, CLAUDE.md and the register". A
# closer that names only the register silently drops the other four.
#
# The demand is SCALED to the size of the turn, so this block has to arm one ABOVE the threshold.
# Arming a single file would assert the full loop against the short text and report a regression that
# is not one - the same shape of false red the bench exists to avoid.
#
# THREE DISTINCT PATHS, not the same fixture three times: the marker holds one line per FILE, so
# repeating one path arms a turn of ONE file and lands on the short branch.
arm_files TESTSESS 'C:\\\\proj\\\\src\\\\a.js' 'C:\\\\proj\\\\src\\\\b.js' 'C:\\\\proj\\\\src\\\\c.js'
out=$(run_hook closer "$FIX/stop.json")
for part in ROADMAP inventory memory CLAUDE.md EFFECT; do
  printf '%s' "$out" | grep -qF "$part" && ok "closer: demands $part" || ko "closer: demands $part" "$out"
done
# CURRENCY: the first question is what stopped being true, not what is missing. Measured on this
# project's own history, six write destinations and zero deletions made adding a line the cheapest
# way out of the debt every single time - which is how a register fills with claims that expired.
printf '%s' "$out" | grep -qF 'WHAT STOPPED BEING TRUE' \
  && ok "closer: asks what expired FIRST" || ko "closer: asks what expired FIRST" "$out"
printf '%s' "$out" | grep -qF 'DELETING CLOSES THE LOOP' \
  && ok "closer: deleting settles the debt like writing" || ko "closer: deleting settles the debt like writing" "$out"
# The distance rule: fresh out of the work the agent assumes it finished and that it finished well.
printf '%s' "$out" | grep -qF 'NOT PRUNED IN THIS TURN' \
  && ok "closer: spares what this turn produced" || ko "closer: spares what this turn produced" "$out"
rm -f "${TMPDIR:-/tmp}/hi-claude-turn-TESTSESS" "${TMPDIR:-/tmp}/hi-claude-size-TESTSESS"

# --- the demand is SCALED: a small turn is not charged a seven-step ritual ---
# Measured over 563 real blocks: 224 of them (40%) fired over ONE file and 57% over one or two. After
# a one-file block the turn wrote NOTHING a quarter of the time, having spent a median of 6 assistant
# messages re-auditing to conclude nothing applied. A demand that usually finds nothing gets answered
# without looking, which costs the guarantee - so the scale is part of the guarantee, not a comfort.
run_hook tracker "$FIX/post-write-code.json" >/dev/null
small=$(run_hook closer "$FIX/stop.json")
printf '%s' "$small" | grep -qF '"decision": "block"' \
  && ok "closer: a small turn still blocks" || ko "closer: a small turn still blocks" "$small"
printf '%s' "$small" | grep -qF 'Three questions' \
  && ok "closer: a small turn gets the short demand" || ko "closer: a small turn gets the short demand" "$small"
printf '%s' "$small" | grep -qF 'WHAT DID THIS MAKE FALSE' \
  && ok "closer: the short demand still asks what expired FIRST" \
  || ko "closer: the short demand still asks what expired FIRST" "$small"
# SCALING IS NOT DROPPING DESTINATIONS. Closing a small `[C]` item is BY DEFINITION a small turn, and
# that is exactly when the live picture has to change - so a short demand that names only the register
# removes the pointer where it is most needed. Measured on the first version of this branch: the live
# picture, the inventory, memory and CLAUDE.md appeared ONLY in the long text.
for part in "live picture" "inventory" "memory" "CLAUDE.md"; do
  printf '%s' "$small" | grep -qF "$part" \
    && ok "closer: the short demand still names the $part" \
    || ko "closer: the short demand still names the $part" "$small"
done
# The whole point is that it is SHORTER. If the ritual leaks into the small branch the scale is a
# comment, not a behaviour.
printf '%s' "$small" | grep -qF 'IN THIS ORDER' \
  && ko "closer: a small turn is spared the ritual" "$small" \
  || ok "closer: a small turn is spared the ritual"
rm -f "${TMPDIR:-/tmp}/hi-claude-turn-TESTSESS" "${TMPDIR:-/tmp}/hi-claude-size-TESTSESS"
# A document leaves the tree through the shell, which no PostToolUse write hook ever sees. Without
# the index settling the debt, a turn that PRUNED stayed in debt and the only way out was to write
# something new - the accumulation incentive, intact.
printf '%s\n' '{"session_id":"TESTSESS","cwd":"C:\\proj","hook_event_name":"PostToolUse","tool_name":"Write","tool_input":{"file_path":"C:\\proj\\docs\\INDEX.md","content":"x"},"tool_response":{}}' > "$FIX/post-write-index.json"
run_hook tracker "$FIX/post-write-code.json" >/dev/null
run_hook tracker "$FIX/post-write-index.json" >/dev/null
check "closer: correcting the index settles the debt too" closer "$FIX/stop.json" empty
rm -f "${TMPDIR:-/tmp}/hi-claude-turn-TESTSESS" "${TMPDIR:-/tmp}/hi-claude-size-TESTSESS"

# --- currency: one open plan at a time ---
# The signal is UNTICKED BOXES, not the word "vigente"/"current": it has to hold in whatever language
# the maintainers write in. The directory lives inside the repo on purpose - the tracker treats /tmp
# and %TEMP% as non-system destinations, so a fixture under mktemp would test nothing at all.
#
# The payload is piped rather than stored: it has to carry an ABSOLUTE path to the bench's own
# directory, and a fixture file holding one machine's paths is a fixture that only passes there.
#
# The tracker treats /tmp, %TEMP% and scratchpad paths as destinations that are not "the system", so a
# bench running from a repo cloned under one of them sees the hook exit before the signal. That is the
# hook behaving as specified — a failure here would be the bench reporting its own location. Measured:
# the pre-push clone landed under a scratchpad and these two turned red while the code was correct.
# Declared and skipped, never skipped in silence.
CURRENCY_HOME=$(printf '%s' "$ROOT" | tr '\\' '/' | tr '[:upper:]' '[:lower:]')
case "$CURRENCY_HOME" in
  /tmp/*|/var/tmp/*|*/appdata/local/temp/*|*/scratchpad/*|*/temp/*)
    printf 'SKIP  currency signal: this repo lives under a path the tracker treats as temporary\n      (%s) — clone it elsewhere to exercise these four checks\n' "$ROOT" ;;
  *)
PD="$ROOT/tests/.currency-tmp/plans"
mkdir -p "$PD"
printf 'nuevo\n' > "$PD/new-plan.md"
plan_write() {
  printf '{"session_id":"TESTSESS","cwd":"%s","hook_event_name":"PostToolUse","tool_name":"Write","tool_input":{"file_path":"%s/new-plan.md","content":"x"},"tool_response":{}}' \
    "$ROOT" "$PD" | bash "$ROOT/hooks/tracker" 2>/dev/null
}
printf -- '- [ ] Task one\n- [ ] Task two\n' > "$PD/old-plan.md"
out=$(plan_write)
printf '%s' "$out" | grep -qF "One open plan at a time" \
  && ok "currency: a plan written beside an open one gets the signal" \
  || ko "currency: a plan written beside an open one gets the signal" "$out"
printf '%s' "$out" | grep -qF "permissionDecision" \
  && ko "currency: the signal never blocks" "$out" || ok "currency: the signal never blocks"
# The tracker never emitted anything before this signal. A PostToolUse payload that is not in Claude
# Code's schema union is dropped with no error anyone would notice - the text is right, the envelope
# is wrong, and a substring assertion cannot see it.
printf '%s' "$out" | grep -qF '"hookEventName": "PostToolUse"' \
  && ok "currency: the signal rides the PostToolUse envelope" \
  || ko "currency: the signal rides the PostToolUse envelope" "$out"
# It stays narrow: a signal that shows up on ordinary work is one that gets learnt away.
printf -- '- [x] Task one\n' > "$PD/old-plan.md"
printf '%s' "$(plan_write)" | grep -qF "One open plan at a time" \
  && ko "currency: a closed neighbour raises nothing" "fired" \
  || ok "currency: a closed neighbour raises nothing"
rm -f "$PD/old-plan.md"
printf '%s' "$(plan_write)" | grep -qF "One open plan at a time" \
  && ko "currency: alone in the directory, silent" "fired" \
  || ok "currency: alone in the directory, silent"
check "currency: a code write raises nothing" tracker "$FIX/post-write-code.json" notcontains "One open plan at a time"
rm -rf "$ROOT/tests/.currency-tmp" ;;
esac
rm -f "${TMPDIR:-/tmp}/hi-claude-turn-TESTSESS" "${TMPDIR:-/tmp}/hi-claude-size-TESTSESS"

# --- the constitution carries the third axis ---
# It is the only text that rides into EVERY session: a principle that is not here does not govern.
CON="$ROOT/skills/memory-protocol/constitution.md"
grep -q "CURRENCY" "$CON" && ok "constitution: carries the currency axis" \
                          || ko "constitution: carries the currency axis" "missing"
grep -q "SIZE IS NOT THE MEASURE" "$CON" && ok "constitution: size is not the measure" \
                                         || ko "constitution: size is not the measure" "missing"
grep -q "Nothing is pruned in the turn that produced it" "$CON" \
  && ok "constitution: carries the distance rule" || ko "constitution: carries the distance rule" "missing"
# Writing an inventory document settles the debt too, or the loop can never be closed.
printf '%s\n' '{"session_id":"TESTSESS","cwd":"C:\\proj","hook_event_name":"PostToolUse","tool_name":"Write","tool_input":{"file_path":"C:\\proj\\docs\\PLUGINS.md","content":"x"},"tool_response":{}}' > "$FIX/post-write-inventory.json"
run_hook tracker "$FIX/post-write-code.json" >/dev/null
run_hook tracker "$FIX/post-write-inventory.json" >/dev/null
check "closer: updating the inventory settles the debt" closer "$FIX/stop.json" empty

# --- declared protocols: a path referenced and never opened does not govern ---
pr=$(mktemp -d); mkdir -p "$pr/docs"
cat > "$pr/docs/INDEX.md" <<'IDX'
# Index
| Document | What |
|---|---|
| [ROADMAP.md](ROADMAP.md) | the register |
| [SECURITY.md](SECURITY.md) | how secrets are handled here |
IDX
fp=$(fixture_with_cwd session-start.json "$pr")
check "protocols: injects declared titles"      session-start "$fp" contains "how secrets are handled here"
check "protocols: injects the path, not content" session-start "$fp" contains "docs/SECURITY.md"
# The register travels in its own block; repeating it is pure cost.
out=$(run_hook session-start "$fp")
[ "$(printf '%s' "$out" | grep -c 'docs/ROADMAP.md — the register')" -eq 0 ] \
  && ok "protocols: does not repeat the register" || ko "protocols: does not repeat the register" "$out"
rm -rf "$pr" "$fp"
pr2=$(mktemp -d)
fp2=$(fixture_with_cwd session-start.json "$pr2")
check "protocols: no index, no noise" session-start "$fp2" notcontains "Declared documentation"
rm -rf "$pr2" "$fp2"

# --- the six auditors ---
n=$(ls "$ROOT"/agents/*.md 2>/dev/null | wc -l)
[ "$n" -eq 6 ] && ok "agents: six auditors present" || ko "agents: six auditors present" "$n"
n=$(grep -lc "I never determine what gets done" "$ROOT"/agents/*.md 2>/dev/null | wc -l)
[ "$n" -eq 6 ] && ok "agents: all six carry the closing line" || ko "agents: all six carry the closing line" "$n of 6"
grep -q "inventory-auditor" "$ROOT/skills/audit/SKILL.md" \
  && ok "audit: dispatches the inventory auditor" || ko "audit: dispatches the inventory auditor" "missing"
grep -q "currency-auditor" "$ROOT/skills/audit/SKILL.md" \
  && ok "audit: dispatches the currency auditor" || ko "audit: dispatches the currency auditor" "missing"
# Size is a symptom, not a defect: a long file where every line is live is healthy. A rubric that
# scores line count teaches the opposite, which is the whole reason the criterion left.
grep -q "Size under" "$ROOT"/agents/*.md \
  && ko "auditors: line count scores nothing" "a rubric still charges points for size" \
  || ok "auditors: line count scores nothing"
# The currency auditor is worthless if it trusts the document it is auditing.
grep -q "EFFECT" "$ROOT/agents/currency-auditor.md" \
  && ok "currency-auditor: verifies by effect" || ko "currency-auditor: verifies by effect" "missing"
grep -qi "distance rule" "$ROOT/agents/currency-auditor.md" \
  && ok "currency-auditor: spares what the session just produced" \
  || ko "currency-auditor: spares what the session just produced" "missing"

# --- adoption: the panorama names the version it ships with, or it ages in silence ---
# It is REWRITTEN at every release, never stacked, and what makes that survive a release is not
# remembering. `plugin.json` declares a version and this goes red if the skill does not name it, so
# revisiting the panorama becomes a condition for shipping instead of a step somebody recalls — the
# same mechanic as a ceiling that only goes down: what cannot be forgotten is what breaks the run.
UPD="$ROOT/skills/update/SKILL.md"
pv=$(grep -m1 '"version"' "$ROOT/.claude-plugin/plugin.json" \
     | sed 's/.*"version"[^"]*"\([^"]*\)".*/\1/')
if grep -qF "$pv" "$UPD"; then
  ok "update: the panorama names the version it ships with ($pv)"
else
  ko "update: the panorama names the version it ships with" "$pv missing from skills/update/SKILL.md"
fi
# If it starts reporting health it IS audit under another name, and the difference in focus is the
# entire reason it exists. The description has to say so where the model reads it.
grep -qF "hi-claude:audit" "$UPD" \
  && ok "update: it says out loud what it is NOT" \
  || ko "update: it says out loud what it is NOT" "nothing disambiguates it from audit"
# An item without its measurement is a suggestion, and a suggestion gets read once.
n=$(grep -c '^\*\*How to measure it here' "$UPD" || true)
[ "${n:-0}" -ge 3 ] \
  && ok "update: every item carries how to measure it BY EFFECT ($n)" \
  || ko "update: every item carries how to measure it BY EFFECT" "only $n"
# The filter that keeps it from becoming the changelog it replaces.
grep -qF "asks something OF THE PROJECT" "$UPD" \
  && ok "update: only what asks something of the project enters" \
  || ko "update: only what asks something of the project enters" "the filter is not written down"

# --- memory protocol knows BOTH axes ---
grep -q "WRITING axis" "$ROOT/skills/memory-protocol/SKILL.md" \
  && ok "memory-protocol: applies the writing axis" || ko "memory-protocol: applies the writing axis" "missing"
grep -q "NON-CONDITIONING" "$ROOT/skills/memory-protocol/references/examples.md" \
  && ok "memory-protocol: examples cover both axes" || ko "memory-protocol: examples cover both axes" "missing"

# --- the matcher is load-bearing in BOTH directions ---
# Too narrow and MCP writes escape unevaluated; `*` and the hook runs on every Read and Grep at a
# measured ~430ms per call on Windows, which a session pays a hundred times over.
H="$ROOT/hooks/hooks.json"
grep -q 'mcp__\.\*' "$H" && ok "matcher: covers MCP tools" \
                         || ko "matcher: covers MCP tools" "an MCP write would never be evaluated"
grep -qE '"matcher": "[^"]*Agent[^"]*"' "$H" && ok "matcher: covers delegation tools" \
                                             || ko "matcher: covers delegation tools" "missing"
grep -q '"matcher": "\*"' "$H" && ko "matcher: not a blanket wildcard" "costs ~430ms on every tool call" \
                              || ok "matcher: not a blanket wildcard"

# --- inventory drift: a tool nobody knows about is a tool nobody uses ---
inv=$(mktemp -d); mkdir -p "$inv/docs"
reg="$inv/installed_plugins.json"
cat > "$reg" <<'REG'
{"version":2,"plugins":{"alpha-tool@some-market":[{"scope":"user"}],"beta-tool@some-market":[{"scope":"user"}]}}
REG
printf '# Plugins\n\n- alpha-tool: does a thing\n' > "$inv/docs/PLUGINS.md"
fi_=$(fixture_with_cwd session-start.json "$inv")
out=$(CLAUDE_CONFIG_DIR="$inv/cfg" bash "$ROOT/hooks/session-start" < "$fi_" 2>/dev/null)
printf '%s' "$out" | grep -qF "Inventory drift" \
  && ko "inventory: no registry, no noise" "$out" || ok "inventory: no registry, no noise"
mkdir -p "$inv/cfg/plugins" && cp "$reg" "$inv/cfg/plugins/installed_plugins.json"
out=$(CLAUDE_CONFIG_DIR="$inv/cfg" bash "$ROOT/hooks/session-start" < "$fi_" 2>/dev/null)
printf '%s' "$out" | grep -qF "beta-tool" \
  && ok "inventory: names what is installed and undeclared" || ko "inventory: names what is installed and undeclared" "$out"
printf '%s' "$out" | grep -qF "alpha-tool " \
  && ko "inventory: does not re-report what is declared" "$out" || ok "inventory: does not re-report what is declared"
printf '# Plugins\n\n- alpha-tool: a thing\n- beta-tool: another\n' > "$inv/docs/PLUGINS.md"
out=$(CLAUDE_CONFIG_DIR="$inv/cfg" bash "$ROOT/hooks/session-start" < "$fi_" 2>/dev/null)
printf '%s' "$out" | grep -qF "Inventory drift" \
  && ko "inventory: in sync, no noise" "$out" || ok "inventory: in sync, no noise"
# The MERGED inventory is one document with a section per class, and it wins over the older split
# files. Without this case the whole new path was exercised by hand and by nothing else - the checks
# above all run through PLUGINS.md, which is the path a project generated before the merge still has.
rm -f "$inv/docs/PLUGINS.md"
printf '# Inventario\n\n## Plugins\n\n- alpha-tool: a thing\n' > "$inv/docs/INVENTARIO.md"
out=$(CLAUDE_CONFIG_DIR="$inv/cfg" bash "$ROOT/hooks/session-start" < "$fi_" 2>/dev/null)
printf '%s' "$out" | grep -qF "beta-tool" \
  && ok "inventory: the merged document is read too" \
  || ko "inventory: the merged document is read too" "$out"
# The heading names the file it actually read: a drift notice pointing at a document the project does
# not have sends the session to correct the wrong one.
printf '%s' "$out" | grep -qF "Inventory drift (docs/INVENTARIO.md)" \
  && ok "inventory: the notice names the document it read" \
  || ko "inventory: the notice names the document it read" "$out"
rm -rf "$inv" "$fi_"

# --- delegation: the protocol arrives at the dispatch and at the RETURN ---
# Measured on the triggering harness: as a skill description alone it fired 0/4 on explicit dispatch
# phrasings (negatives 4/4 - it does not steal triggers, it just never gets its own). Dispatching has
# no decision point where a skill feels required, so the rule moved into the hooks.
check "dispatch: the main agent gets the protocol"  guardian "$FIX/main-dispatch.json" contains "never the DECIDING"
check "dispatch: it is a nudge, not a decision"     guardian "$FIX/main-dispatch.json" notcontains "permissionDecision"
check "dispatch: a subagent dispatching is denied"  guardian "$FIX/subagent-dispatch.json" contains '"deny"'
check "return: the report is framed as hypothesis"  report-received "$FIX/post-agent-report.json" contains "HYPOTHESIS"
check "return: no noise on unrelated tools"         report-received "$FIX/post-agent-noise.json"  empty
envelope "envelope: report-received is JSON PostToolUse" report-received "$FIX/post-agent-report.json" json PostToolUse

# --- turn close: a turn that changed the system does not end with the register stale ---
# The whole point is that this is a GUARANTEE, not a probabilistic trigger: measured, a rule that
# lives only in a description does not fire when there is no decision point that calls for it.
MARK="${TMPDIR:-/tmp}/hi-claude-turn-TESTSESS"
rm -f "$MARK"

run_hook tracker "$FIX/post-read.json" >/dev/null
[ ! -f "$MARK" ] && ok "tracker: a read leaves no debt" || ko "tracker: a read leaves no debt" "marker exists"

run_hook tracker "$FIX/post-write-temp.json" >/dev/null
[ ! -f "$MARK" ] && ok "tracker: a temp write leaves no debt" || ko "tracker: a temp write leaves no debt" "marker exists"

run_hook tracker "$FIX/post-write-code.json" >/dev/null
[ -f "$MARK" ] && ok "tracker: a code write records the debt" || ko "tracker: a code write records the debt" "no marker"

check "closer: blocks a turn that left the register stale" closer "$FIX/stop.json" contains '"decision": "block"'
# Blocking must be TOP-LEVEL for Stop: a hookSpecificOutput envelope fails validation silently.
check "closer: block is not wrapped in an envelope"        closer "$FIX/stop.json" notcontains "hookSpecificOutput"
# It cleared the marker as it blocked, so the next stop passes: a guarantee that traps is not one.
check "closer: never blocks twice in a row"                closer "$FIX/stop.json" empty

run_hook tracker "$FIX/post-write-code.json" >/dev/null
check "closer: honours stop_hook_active"                   closer "$FIX/stop-active.json" empty

run_hook tracker "$FIX/post-write-code.json" >/dev/null
run_hook tracker "$FIX/post-write-roadmap.json" >/dev/null
check "closer: updating the register settles the debt"     closer "$FIX/stop.json" empty
rm -f "$MARK"

# --- sovereignty: every generated text says what rules it is under ---
# A text that does not declare its rules gets its form re-litigated every session.
miss=$(grep -L "hi-claude" "$ROOT"/skills/setup/templates/*/*.md 2>/dev/null | wc -l)
[ "$miss" -eq 0 ] && ok "sovereignty: every template declares it" \
                  || ko "sovereignty: every template declares it" "$miss templates without it"
grep -q "hi-claude governs what persists here" "$ROOT/skills/memory-protocol/references/memory-schema.md" \
  && ok "sovereignty: memory schema declares it" || ko "sovereignty: memory schema declares it" "missing"

# --- OBJECTIVE: an auditor reports a datum, not a verdict of value ---
# A letter grade on the user's own files is a judgement; the rubrics already produce the number.
n=$(grep -l "GRADE:" "$ROOT"/agents/*.md 2>/dev/null | wc -l)
[ "$n" -eq 0 ] && ok "auditors: report a measurement, not a grade" \
               || ko "auditors: report a measurement, not a grade" "$n still grade A-F"
n=$(grep -l "NON-CONDITIONING\|WRITING axis\|ADMISSION axis" "$ROOT"/agents/*.md 2>/dev/null | wc -l)
[ "$n" -ge 3 ] && ok "auditors: score against the five principles" \
               || ko "auditors: score against the five principles" "only $n of 4"

# --- frontmatter must PARSE, or the component loads with empty metadata ---
# A plain unquoted YAML scalar ends at the first ": ". A description written that way makes YAML read
# a nested mapping and the WHOLE frontmatter is dropped: the skill still resolves by directory name,
# but the model can never auto-trigger it, and nothing fails loudly. Measured: it cost `setup` its
# 526-char description, and `claude plugin validate <dir>` reported success the whole time because
# that form only checks the marketplace manifest. Use the plugin.json path to reach components.
fm_bad=0
for f in "$ROOT"/skills/*/SKILL.md "$ROOT"/agents/*.md; do
  [ -f "$f" ] || continue
  line=$(grep -m1 '^description:' "$f" || true)
  [ -n "$line" ] || { ko "frontmatter: $(basename "$(dirname "$f")") has a description" "none"; fm_bad=1; continue; }
  val=${line#description:}; val=${val# }
  case "$val" in
    '|'*|'>'*|'"'*|"'"*) continue ;;   # block scalar or quoted: immune by construction
  esac
  if printf '%s' "$val" | grep -q ': '; then
    ko "frontmatter: no colon-space in a plain scalar ($f)" "value ends early, metadata dropped"
    fm_bad=1
  fi
done
[ "$fm_bad" -eq 0 ] && ok "frontmatter: every skill and agent parses"

# --- the two manifests must declare the SAME version ---
# `plugin.json` is what the plugin reports; `marketplace.json` is what `/plugin update` compares
# against. Bump one and not the other and the release is committed, pushed and invisible: users are
# told they are up to date. Nothing failed loudly the time it happened — the validator passes either
# way, because each manifest is valid on its own.
pv=$(grep -o '"version"[[:space:]]*:[[:space:]]*"[^"]*"' "$ROOT/.claude-plugin/plugin.json" | head -1 | sed 's/.*"\([^"]*\)"$/\1/')
mv_=$(grep -o '"version"[[:space:]]*:[[:space:]]*"[^"]*"' "$ROOT/.claude-plugin/marketplace.json" | head -1 | sed 's/.*"\([^"]*\)"$/\1/')
[ -n "$pv" ] && [ "$pv" = "$mv_" ] && ok "manifests: plugin and marketplace agree on the version ($pv)" \
                                   || ko "manifests: plugin and marketplace agree on the version" "plugin=$pv marketplace=$mv_"

# --- hook matchers name tools that actually exist ---
# Matching is an UNANCHORED regex test, so a matcher also hits every tool whose name CONTAINS it.
grep -q 'SlashCommand\|MultiEdit' "$ROOT/hooks/hooks.json" \
  && ko "matcher: no dead tool names" "SlashCommand/MultiEdit are not tools in current Claude Code" \
  || ok "matcher: no dead tool names"
# Matcher coverage, tested the way Claude Code tests it: an UNANCHORED regex against the tool name.
# That is what lets `Edit` cover MultiEdit and `Task` cover TaskCreate - and what makes `Write` catch
# TodoWrite, which is why the guardian exempts it explicitly.
# The PreToolUse matcher is the one carrying mcp__ - taking the FIRST matcher in the file would
# grab SessionStart's source list and every assertion below would be meaningless.
PTU=$(grep -o '"matcher": "[^"]*mcp__[^"]*"' "$ROOT/hooks/hooks.json" | sed 's/.*"matcher": "\(.*\)"/\1/')
[ -n "$PTU" ] || ko "matcher: PreToolUse matcher found in hooks.json" "none carries mcp__"
cov_bad=0
for t in Write Edit MultiEdit NotebookEdit Bash Agent Task TaskCreate Workflow mcp__fs__write_file; do
  printf '%s' "$t" | grep -Eq "$PTU" || { ko "matcher: covers $t" "not matched"; cov_bad=1; }
done
for t in Read Grep Glob WebFetch WebSearch Skill; do
  printf '%s' "$t" | grep -Eq "$PTU" && { ko "matcher: spares $t" "matched - costs a bash spawn per call"; cov_bad=1; }
done
[ "$cov_bad" -eq 0 ] && ok "matcher: covers what decides, spares what only reads"
# Delegating work onward is deciding: a subagent creating a task is denied, reading them is not.
printf '%s\n' '{"hook_event_name":"PreToolUse","agent_id":"a1","tool_name":"TaskCreate","tool_input":{"prompt":"x"}}' > "$FIX/subagent-taskcreate.json"
printf '%s\n' '{"hook_event_name":"PreToolUse","agent_id":"a1","tool_name":"TaskGet","tool_input":{}}' > "$FIX/subagent-taskget.json"
check "subagent: creating a task is denied" guardian "$FIX/subagent-taskcreate.json" contains '"deny"'
check "subagent: reading tasks passes"      guardian "$FIX/subagent-taskget.json"    empty
# TodoWrite is session-local scratch, not a project artefact: denying it is friction, not protection.
printf '%s\n' '{"hook_event_name":"PreToolUse","agent_id":"a1","tool_name":"TodoWrite","tool_input":{"todos":[]}}' > "$FIX/subagent-todowrite.json"
check "subagent: TodoWrite is not a project write" guardian "$FIX/subagent-todowrite.json" empty

# --- doctrine: one rule, one file ---
# Scope: the instruction surface Claude loads (skills/), excluding the templates,
# which are output for the USER's project, and agents/, which run with their own
# context and never receive the Constitution.
n=$(grep -rl "PREFERENTIAL" "$ROOT/skills" --include=*.md | grep -v '/templates/' | wc -l)
[ "$n" -eq 1 ] && ok "doctrine: admission rule defined once in skills/" \
               || ko "doctrine: admission rule defined once in skills/" "$n files"
n=$(grep -rl "Where does each thing go" "$ROOT" --include=*.md | wc -l)
[ "$n" -eq 1 ] && ok "doctrine: decision tree lives in one file" \
               || ko "doctrine: decision tree lives in one file" "$n files"

# --- templates carry the markers session-start looks for ---
for t in es/ROADMAP.template.md en/ROADMAP.template.md; do
  f="$ROOT/skills/setup/templates/$t"
  if [ -f "$f" ] && grep -qF '<!-- hi-claude:en-curso -->' "$f" && grep -qF '<!-- /hi-claude:en-curso -->' "$f"; then
    ok "template markers: $t"
  else
    ko "template markers: $t" "missing file or markers"
  fi
done

# --- a freshly generated ROADMAP injects nothing (end to end, real template) ---
for lang in es en; do
  proj=$(mktemp -d); mkdir -p "$proj/docs"
  sed 's/{{PROJECT_NAME}}/Demo/;s/{{SESSION_DONE_CRITERION}}/pytest -q/' \
    "$ROOT/skills/setup/templates/$lang/ROADMAP.template.md" > "$proj/docs/ROADMAP.md"
  f=$(fixture_with_cwd session-start.json "$proj")
  check "fresh ROADMAP ($lang): no open-work noise" session-start "$f" notcontains "## Open work (docs/ROADMAP.md)"
  rm -rf "$proj" "$f"
done

# --- an open-work block past the budget SAYS it was cut ---
# Measured across five real registers on disk: two of them overflow (4.836 and 5.860 chars), so their
# block reaches the session cut and the session cannot tell. A trailing marker reads as a formality -
# what makes it actionable is saying the rest did NOT arrive, so it is not answered by reading harder.
proj=$(mktemp -d); mkdir -p "$proj/docs"
# The filler must NOT be headings: session-start strips them before deciding there is substance, so a
# block made only of `###` lines injects nothing and the check would pass for the wrong reason.
{ echo "# ROADMAP"; echo '<!-- hi-claude:en-curso -->'; echo "## 1. EN CURSO"; echo "### An item"
  awk 'BEGIN{ while (i++ < 80) print "Falta: open work that keeps going on and on and on and on." }'
  echo '<!-- /hi-claude:en-curso -->'; } > "$proj/docs/ROADMAP.md"
f=$(fixture_with_cwd session-start.json "$proj")
check "session-start: an oversized open-work block says it was cut" session-start "$f" contains "THE REST DID NOT ARRIVE"
rm -rf "$proj" "$f"

# A block that FITS must carry no notice: a warning on ordinary work is one that gets learnt away.
proj=$(mktemp -d); mkdir -p "$proj/docs"
{ echo "# ROADMAP"; echo '<!-- hi-claude:en-curso -->'; echo "### One item"
  echo "Falta: one line."; echo '<!-- /hi-claude:en-curso -->'; } > "$proj/docs/ROADMAP.md"
f=$(fixture_with_cwd session-start.json "$proj")
check "session-start: a block that fits carries no cut notice" session-start "$f" notcontains "THE REST DID NOT ARRIVE"
rm -rf "$proj" "$f"

# --- memory signal: a DURABLE preference reaches the protocol, a one-off does not ---
# Measured: `memory-protocol` carries the literal phrasings in its description and mp-s-03 still scored
# 0/4 with median 0 - stable, not variance. The negatives below are the harness's own traps, built from
# the SAME words as the positives; they are what makes this narrow instead of greedy.
psig() {
  printf '{"session_id":"S","hook_event_name":"UserPromptSubmit","prompt":"%s"}' "$1" \
    | bash "$ROOT/hooks/prompt-signals" 2>/dev/null
}
mem_pos=0
for q in 'No me gusta que uses tablas tan largas, preferi listas de ahora en mas' \
         'Recorda que jamas se hace deploy los viernes' \
         'Si, exactamente asi - siempre valide los emails con ese regex' \
         'Para la proxima, los reportes me los das en una sola pagina' \
         'From now on, never commit without asking me first' \
         'Nunca mas uses node 16 aca, quedamos en node 20'; do
  printf '%s' "$(psig "$q")" | grep -qF 'DURABLE preference' && mem_pos=$((mem_pos + 1))
done
[ "$mem_pos" -ge 6 ] && ok "memory signal: durable preferences reach the protocol ($mem_pos/6)" \
                     || ko "memory signal: durable preferences reach the protocol" "only $mem_pos/6"
mem_false=0
for q in 'No me gusta como quedo este parrafo, reescribilo' \
         'Recordame manana revisar el PR' \
         'Siempre que veas un error de tipos mostrame el stack completo... digo, en este debug de ahora nomas' \
         'Te acordas de que hicimos en la sesion de ayer?' \
         'Corre los tests con --verbose esta vez' \
         'Guarda este archivo en la carpeta docs'; do
  printf '%s' "$(psig "$q")" | grep -qF 'DURABLE preference' && mem_false=$((mem_false + 1))
done
[ "$mem_false" -eq 0 ] && ok "memory signal: one-off requests stay silent (0 false fires)" \
                       || ko "memory signal: one-off requests stay silent" "$mem_false false fires"
# The two signals share a hook and must not bleed into each other.
printf '%s' "$(psig 'algo anda mal y no se que')" | grep -qF 'DURABLE preference' \
  && ko "memory signal: a stall does not raise the memory protocol" "signals bleed" \
  || ok "memory signal: a stall does not raise the memory protocol"
printf '%s' "$(psig 'Para la proxima, los reportes en una pagina')" | grep -qF 'seeding-doubts' \
  && ko "memory signal: a preference does not raise the doubts protocol" "signals bleed" \
  || ok "memory signal: a preference does not raise the doubts protocol"

# --- json_str: a value carrying ESCAPED QUOTES is not truncated ---
# Measured: reading the value as "up to the next quote" cut every Bash command that carried quotes,
# and a truncated command matches no rule. Three guarantees were evaded by merely quoting the command
# — the ask on CLAUDE.md, the ask on memory, and the subagent write block — and the bench never saw it
# because every Bash case it had was unquoted. These four are the regression that keeps it closed.
qask() {
  printf '{"session_id":"S","cwd":"/c/proj","hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"%s"}}' "$1" \
    | bash "$ROOT/hooks/guardian" 2>/dev/null
}
printf '%s' "$(qask 'echo \"una regla\" >> CLAUDE.md')" | grep -qF '"ask"' \
  && ok "json_str: a QUOTED bash write to CLAUDE.md still asks" \
  || ko "json_str: a QUOTED bash write to CLAUDE.md still asks" "quoting the command evaded the guarantee"
printf '%s' "$(qask 'echo \"dato\" >> /c/Users/x/.claude/projects/p/memory/n.md')" | grep -qF '"ask"' \
  && ok "json_str: a QUOTED bash write to memory still asks" \
  || ko "json_str: a QUOTED bash write to memory still asks" "quoting the command evaded the guarantee"
out=$(printf '{"session_id":"S","agent_id":"sub-1","cwd":"/c/proj","hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"echo \\"x\\" > /c/proj/src/app.py"}}' \
  | bash "$ROOT/hooks/guardian" 2>/dev/null)
printf '%s' "$out" | grep -qF '"deny"' \
  && ok "json_str: a QUOTED subagent write is still denied" \
  || ko "json_str: a QUOTED subagent write is still denied" "$out"
# The unquoted path must keep working: the fix un-escapes only \" and leaves \\ alone, because Windows
# paths arrive with doubled backslashes and several call sites collapse them themselves.
printf '%s' "$(qask 'echo x >> CLAUDE.md')" | grep -qF '"ask"' \
  && ok "json_str: the unquoted path still asks" \
  || ko "json_str: the unquoted path still asks" "the fix broke what already worked"

# --- belonging: the destination map rides on CREATION only ---
# The negative matters as much as the positive: a signal that shows up on every doc write is one that
# gets learnt away, and writing into an already-declared destination is ordinary work.
# NOT under the temp dir: a temporary destination gets no map by design, so building the fixture there
# would make every check below pass for the wrong reason.
bproj="$HOME/hi claude maptest"; rm -rf "$bproj"; mkdir -p "$bproj/docs/motor"
printf 'x\n' > "$bproj/docs/ROADMAP.md"
printf 'x\n' > "$bproj/docs/CONTEXTO.md"
bwrite() {
  printf '{"session_id":"TESTSESS","cwd":"%s","hook_event_name":"PreToolUse","tool_name":"Write","tool_input":{"file_path":"%s","content":"x"}}' \
    "$bproj" "$1" | bash "$ROOT/hooks/guardian" 2>/dev/null
}
out=$(bwrite "$bproj/docs/NUEVA.md")
printf '%s' "$out" | grep -qF "LAST option" \
  && ok "belonging: creating a doc gets the destination map" \
  || ko "belonging: creating a doc gets the destination map" "$out"
# The map is what EXISTS, not what an index declares: a session can only reuse what is really there.
printf '%s' "$out" | grep -qF "docs/CONTEXTO.md" \
  && ok "belonging: the map names the real destinations" \
  || ko "belonging: the map names the real destinations" "$out"
printf '%s' "$out" | grep -qF "docs/motor/" \
  && ok "belonging: folders count as destinations" \
  || ko "belonging: folders count as destinations" "$out"
printf '%s' "$out" | grep -qF "permissionDecision" \
  && ko "belonging: the map never blocks" "$out" || ok "belonging: the map never blocks"
out=$(bwrite "$bproj/docs/ROADMAP.md")
printf '%s' "$out" | grep -qF "LAST option" \
  && ko "belonging: an existing destination stays silent" "$out" \
  || ok "belonging: an existing destination stays silent"
# The writing rules still ride along - the map is additive, it replaces nothing.
printf '%s' "$out" | grep -qF "TIMELESS" \
  && ok "belonging: the writing rules still ride along" \
  || ko "belonging: the writing rules still ride along" "$out"
# A TEMPORARY destination is not a project document. Measured in a real session: a scratch `.md` under
# the session scratchpad brought the whole map, which is the shape of noise this signal must avoid.
out=$(bwrite "${TMPDIR:-/tmp}/scratchpad/nota-suelta.md")
printf '%s' "$out" | grep -qF "LAST option" \
  && ko "belonging: a temporary destination gets no map" "$out" \
  || ok "belonging: a temporary destination gets no map"
rm -rf "$bproj"

# --- belonging: deleting what git does NOT keep ---
# A tracked file passes with no friction; an untracked one INSIDE the repo has no copy, so the call is
# the user's. Outside every repo the doctrine it patches never reached, so nothing is raised at all.
#
# The scratch repo carries SPACES in its name ON PURPOSE. An earlier version of this bench used a
# space-free path because that was the one where the hook worked - which is choosing the case that
# passes over the case that runs. On Windows a path with spaces is the common case, and the failure it
# produced was not silence: a fragment of the broken path matched, and the notice named `\` instead of
# the file. It cannot live under the temp dir either: the hook skips temporary destinations by design.
dproj="$HOME/hi claude deltest"
rm -rf "$dproj" 2>/dev/null; mkdir -p "$dproj"
if git -C "$dproj" init -q >/dev/null 2>&1; then
  printf 'kept\n' > "$dproj/kept.md"
  git -C "$dproj" add kept.md >/dev/null 2>&1
  git -C "$dproj" -c user.email=t@t -c user.name=t commit -qm init >/dev/null 2>&1
  printf 'scrap\n' > "$dproj/scrap.md"
  # QUOTED, which is how a shell receives a path with spaces in the first place.
  delcmd() {
    printf '{"session_id":"TESTSESS","cwd":"%s","hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"rm \\"%s\\""}}' \
      "$dproj" "$1" | bash "$ROOT/hooks/guardian" 2>/dev/null
  }
  out=$(delcmd "$dproj/scrap.md")
  printf '%s' "$out" | grep -qF "NO copy" \
    && ok "belonging: deleting an untracked file asks" \
    || ko "belonging: deleting an untracked file asks" "$out"
  printf '%s' "$out" | grep -qF '"ask"' \
    && ok "belonging: it asks the user, it does not deny" \
    || ko "belonging: it asks the user, it does not deny" "$out"
  # Firing is not enough: the notice has to NAME the file. Asking the user to look at the CONTENT of
  # something it cannot name is a prompt they can only answer blind.
  printf '%s' "$out" | grep -qF "scrap.md" \
    && ok "belonging: the notice names the file, even with spaces in the path" \
    || ko "belonging: the notice names the file, even with spaces in the path" "$out"
  out=$(delcmd "$dproj/kept.md")
  printf '%s' "$out" | grep -qF "NO copy" \
    && ko "belonging: deleting a tracked file passes" "$out" \
    || ok "belonging: deleting a tracked file passes"
  # A COMMAND IS NOT ONE COMMAND, and the notice must not borrow another statement's arguments.
  # Measured in real use: deleting a lock file under the temp dir raised this notice naming the
  # PROJECT ROOT, which appeared in a variable assignment three statements later. The `rm` was
  # correct, the path it named was not, and a notice that names the wrong thing is worse than none.
  out=$(printf '{"session_id":"TESTSESS","cwd":"%s","hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"rm -rf \\"%s/hi-claude-bench.lock\\" 2>/dev/null; R=\\"%s\\"; bash \\"$R/run.sh\\""}}' \
        "$dproj" "${TMPDIR:-/tmp}" "$dproj" | bash "$ROOT/hooks/guardian" 2>/dev/null)
  printf '%s' "$out" | grep -qF "NO copy" \
    && ko "belonging: a later assignment is not the rm's argument" "$out" \
    || ok "belonging: a later assignment is not the rm's argument"
  # A DIRECTORY is never a pathspec `ls-files --error-unmatch` can match, so asking that way reports
  # every tracked directory as untracked - which is how a repo git has carried for its whole history
  # got named as having no copy.
  out=$(delcmd "$dproj")
  printf '%s' "$out" | grep -qF "NO copy" \
    && ko "belonging: a tracked DIRECTORY is not reported as unsaved" "$out" \
    || ok "belonging: a tracked DIRECTORY is not reported as unsaved"
  # The other direction in the same run: a directory INSIDE the repo that git never saw still asks.
  mkdir -p "$dproj/scrap dir" && printf 'x\n' > "$dproj/scrap dir/a.txt"
  out=$(delcmd "$dproj/scrap dir")
  printf '%s' "$out" | grep -qF "NO copy" \
    && ok "belonging: an untracked DIRECTORY inside the repo still asks" \
    || ko "belonging: an untracked DIRECTORY inside the repo still asks" "$out"
  rm -rf "$dproj/scrap dir" 2>/dev/null
  # AND THE SCOPE. Outside every repo the premise never applied, and `ls-files` comes back empty
  # there exactly as it does for an ignored file inside one - so without the repo test this notice
  # fires on material git was never going to see. Measured in real use on a scratch directory on
  # another drive, whose own convention is that it gets deleted once the run completes.
  # It cannot be built under the temp dir: `is_temp` decides earlier and it would pass for the
  # wrong reason.
  outside="$HOME/hi claude norepo"
  rm -rf "$outside" 2>/dev/null; mkdir -p "$outside" && printf 'x\n' > "$outside/a.txt"
  if git -C "$outside" rev-parse --git-dir >/dev/null 2>&1; then
    printf 'SKIP  belonging scope: HOME sits inside a repo here, so the no-repo case cannot be built\n'
  else
    out=$(delcmd "$outside")
    printf '%s' "$out" | grep -qF "NO copy" \
      && ko "belonging: outside every repo it stays silent" "$out" \
      || ok "belonging: outside every repo it stays silent"
  fi
  rm -rf "$outside" 2>/dev/null
else
  printf 'SKIP  belonging deletion: no git available to build the scratch repo\n'
fi
rm -rf "$dproj" 2>/dev/null

# --- belonging: the register's MONOTONY ---
# Measured on a real register: 99.060 -> 853.468 bytes over three weeks without one drop. Monotony is
# the signal because the two alternatives were refuted on that same file - by ITEM parses 0 blocks
# (`### ` appears zero times), and by LINE reaches 40% of the volume at 800 ch.
case "$(printf '%s' "$ROOT" | tr '[:upper:]' '[:lower:]')" in
  /tmp/*|/var/tmp/*|*/appdata/local/temp/*|*/scratchpad/*)
    printf 'SKIP  belonging monotony: this repo lives under a path the tracker treats as temporary\n      (%s) — clone it elsewhere to exercise these two checks\n' "$ROOT" ;;
  *)
MP="$ROOT/tests/.belonging-tmp"; mkdir -p "$MP/docs"
grow() { awk -v n="$1" 'BEGIN{ while (i++ < n) printf "x" }' > "$MP/docs/ROADMAP.md"; }
# The counter is keyed by the REGISTER's path, not by the session, so the bench has to clear it the
# same way - clearing a session-keyed name would leave state behind and make the NEXT check inherit it.
MKEY=$(printf '%s' "$MP/docs/ROADMAP.md" | tr '\\' '/' | sed 's#//*#/#g' \
         | tr '[:upper:]' '[:lower:]' | cksum | tr -cd '0-9' | cut -c1-16)
MREG="${TMPDIR:-/tmp}/hi-claude-reg-${MKEY}"
mclear() { rm -f "$MREG" "${MREG}.sec" "${MREG}.sec.now" 2>/dev/null; }
mwrite() {
  printf '{"session_id":"%s","cwd":"%s","hook_event_name":"PostToolUse","tool_name":"Write","tool_input":{"file_path":"%s/docs/ROADMAP.md","content":"x"},"tool_response":{}}' \
    "${1:-MONOSESS}" "$MP" "$MP" | bash "$ROOT/hooks/tracker" 2>/dev/null
}
mclear
out=""
for n in 400 800 1200 1600 2000; do grow "$n"; out=$(mwrite); done
printf '%s' "$out" | grep -qF "only GREW" \
  && ok "belonging: a register that only grows gets the signal" \
  || ko "belonging: a register that only grows gets the signal" "$out"
printf '%s' "$out" | grep -qF "permissionDecision" \
  && ko "belonging: the monotony signal never blocks" "$out" \
  || ok "belonging: the monotony signal never blocks"
# A register that OSCILLATES is the healthy one: work comes in, work closes. It must stay silent.
mclear
out=""
for n in 400 800 1200 900 1300; do grow "$n"; out=$(mwrite); done
printf '%s' "$out" | grep -qF "only GREW" \
  && ko "belonging: a register that oscillates stays silent" "$out" \
  || ok "belonging: a register that oscillates stays silent"

# Monotony is a property of the FILE, not of one conversation. Keyed by session it demanded five
# writes to the register inside ONE session - measured across five real registers on disk, none ever
# emitted, and the largest reached 530.624 ch with the signal never firing. Five DIFFERENT sessions
# is the case that was impossible before and is the whole point of the key.
mclear
out=""
for n in 400 800 1200 1600 2000; do grow "$n"; out=$(mwrite "SESS-$n"); done
printf '%s' "$out" | grep -qF "only GREW" \
  && ok "belonging: the monotony counter survives across sessions" \
  || ko "belonging: the monotony counter survives across sessions" "$out"

# WHAT the signal names. The three densest LINES were measured at 1,2% of a 530.624 ch register and
# naming the BIGGEST section emitted on 5 of 5 real registers, pointing at `2. Pendientes` (66%) in a
# register of pending work. Where the growth LANDED is the question monotony is actually asking.
mclear
gsec() {
  { echo "# ROADMAP"; echo "## 1. Motor"; echo "one open line";
    echo "## 2. Contexto del hilo";
    awk -v n="$1" 'BEGIN{ while (i++ < n) print "context that outlived its own item" }';
    echo "## 3. Negocio"; echo "another line"; } > "$MP/docs/ROADMAP.md"
}
out=""
for n in 1 20 40 60 80; do gsec "$n"; out=$(mwrite); done
printf '%s' "$out" | grep -qF "2. Contexto del hilo" \
  && ok "belonging: the signal names the section the growth landed in" \
  || ko "belonging: the signal names the section the growth landed in" "$out"
printf '%s' "$out" | grep -qF "3. Negocio" \
  && ko "belonging: it names where growth landed, not every section" "$out" \
  || ok "belonging: it names where growth landed, not every section"

mclear
rm -rf "$MP"
rm -f "${TMPDIR:-/tmp}/hi-claude-turn-MONOSESS" "${TMPDIR:-/tmp}/hi-claude-size-MONOSESS"
for n in 400 800 1200 1600 2000; do
  rm -f "${TMPDIR:-/tmp}/hi-claude-turn-SESS-$n" "${TMPDIR:-/tmp}/hi-claude-size-SESS-$n" 2>/dev/null
done
    ;;
esac

# --- the register is recognized WHERE IT LIVES, not only under docs/ ---
# Measured across real projects: 194 writes to a register - 7,4% of all of them - settled nothing,
# because two of those projects keep the ROADMAP at the repo root. There the turn closed its loop
# correctly and the hook kept demanding, with nothing anywhere saying why.
printf '%s\n' '{"session_id":"TESTSESS","cwd":"C:\\proj","hook_event_name":"PostToolUse","tool_name":"Write","tool_input":{"file_path":"C:\\proj\\ROADMAP.md","content":"x"},"tool_response":{}}' > "$FIX/post-write-root-roadmap.json"
printf '%s\n' '{"session_id":"TESTSESS","cwd":"C:\\proj","hook_event_name":"PostToolUse","tool_name":"Write","tool_input":{"file_path":"C:\\proj\\node_modules\\smart-buffer\\docs\\ROADMAP.md","content":"x"},"tool_response":{}}' > "$FIX/post-write-vendor-roadmap.json"
run_hook tracker "$FIX/post-write-code.json"         >/dev/null
run_hook tracker "$FIX/post-write-root-roadmap.json" >/dev/null
check "tracker: a register at the repo root settles the debt" closer "$FIX/stop.json" empty
rm -f "${TMPDIR:-/tmp}/hi-claude-turn-TESTSESS" "${TMPDIR:-/tmp}/hi-claude-size-TESTSESS"
# A dependency ships registers of its own, and none of them is this project's.
run_hook tracker "$FIX/post-write-code.json"           >/dev/null
run_hook tracker "$FIX/post-write-vendor-roadmap.json" >/dev/null
check "tracker: a vendored ROADMAP does not settle" closer "$FIX/stop.json" contains '"decision": "block"'
rm -f "${TMPDIR:-/tmp}/hi-claude-turn-TESTSESS" "${TMPDIR:-/tmp}/hi-claude-size-TESTSESS"

# THE REGISTER IS THE ONE THE START INJECTS, and a denylist of vendor directories is not the same
# rule. Measured over nine paths after `node_modules` alone was excluded, FIVE still settled the
# debt: `vendor/`, `.venv/lib/site-packages/`, `third_party/`, `.git/` and a fixture in `tests/`.
# Each of those is a way to silence the close without closing anything, so what settles is now
# DERIVED from cwd exactly as `session-start` derives what it injects.
settles_from() {
  local label="$1" path="$2" want="$3" out
  rm -f "${TMPDIR:-/tmp}/hi-claude-turn-TESTSESS" "${TMPDIR:-/tmp}/hi-claude-size-TESTSESS"
  run_hook tracker "$FIX/post-write-code.json" >/dev/null
  printf '{"session_id":"TESTSESS","cwd":"C:\\\\proj","hook_event_name":"PostToolUse","tool_name":"Write","tool_input":{"file_path":"%s","content":"x"},"tool_response":{}}' \
    "$path" > "$FIX/.settle-probe.json"
  run_hook tracker "$FIX/.settle-probe.json" >/dev/null
  out=$(run_hook closer "$FIX/stop.json")
  rm -f "$FIX/.settle-probe.json" \
        "${TMPDIR:-/tmp}/hi-claude-turn-TESTSESS" "${TMPDIR:-/tmp}/hi-claude-size-TESTSESS"
  case "$want" in
    settles) [ -z "$out" ] && ok "$label" || ko "$label" "$out" ;;
    *)       printf '%s' "$out" | grep -qF '"decision": "block"' \
               && ok "$label" || ko "$label" "${out:-empty}" ;;
  esac
}
settles_from "register: docs/ROADMAP.md settles"        'C:\\\\proj\\\\docs\\\\ROADMAP.md'                       settles
settles_from "register: the repo root settles"          'C:\\\\proj\\\\ROADMAP.md'                               settles
settles_from "register: vendor/ does not"               'C:\\\\proj\\\\vendor\\\\x\\\\ROADMAP.md'                no
settles_from "register: site-packages does not"         'C:\\\\proj\\\\.venv\\\\lib\\\\site-packages\\\\x\\\\ROADMAP.md' no
settles_from "register: third_party/ does not"          'C:\\\\proj\\\\third_party\\\\x\\\\ROADMAP.md'           no
settles_from "register: a fixture in tests/ does not"   'C:\\\\proj\\\\tests\\\\fixtures\\\\ROADMAP.md'          no
settles_from "register: something inside .git/ does not" 'C:\\\\proj\\\\.git\\\\x\\\\ROADMAP.md'                 no
settles_from "live picture: docs/ESTADO.md settles"     'C:\\\\proj\\\\docs\\\\ESTADO.md'                        settles
settles_from "live picture: one under vendor/ does not" 'C:\\\\proj\\\\vendor\\\\x\\\\docs\\\\ESTADO.md'         no

# A session opened on a project whose register sits at the root gets its open work injected too.
proot="$(mktemp -d)"
cat > "$proot/ROADMAP.md" <<'ROADMAPROOT'
# ROADMAP

<!-- hi-claude:en-curso -->
## 1. EN CURSO

### Cerrar el latido del paso  [C]
Falta: el artefacto que lo publica.
<!-- /hi-claude:en-curso -->

## 3. Horizonte
### Migrar el volumen del VPS
esto no viaja al arranque
ROADMAPROOT
froot=$(fixture_with_cwd session-start.json "$proot")
check "session-start: injects a register kept at the root" session-start "$froot" contains "Cerrar el latido del paso"
# The horizon is what makes the block affordable: if it rides along, it is just a bigger register.
check "session-start: the horizon never rides along"       session-start "$froot" notcontains "esto no viaja al arranque"
rm -rf "$proot" "$froot"

# --- one consultation per TURN for memories, one WRITE for CLAUDE.md ---
# Measured: 311 turns produced 908 consultations and only 121 (38,9%) needed one. 597 (65,7%) were the
# second or later of the same turn; the worst asked 35, and one turn made 19 separate edits to
# CLAUDE.md alone. CLAUDE.md loses nothing by being written once. Memories cannot merge that way, so
# there the consultation covers the batch - the consultation axis loosened on purpose, and only there.
printf '%s\n' '{"hook_event_name":"PreToolUse","session_id":"TESTSESS","prompt_id":"TURN1","tool_name":"Write","tool_input":{"file_path":"C:\\Users\\Ten\\.claude\\projects\\My-Proj\\memory\\feedback-x.md","content":"x"}}' > "$FIX/write-memory-turn.json"
printf '%s\n' '{"hook_event_name":"PreToolUse","session_id":"TESTSESS","tool_name":"Write","tool_input":{"file_path":"C:\\Users\\Ten\\.claude\\projects\\My-Proj\\memory\\feedback-x.md","content":"x"}}' > "$FIX/write-memory-no-turn.json"
rm -f "${TMPDIR:-/tmp}/hi-claude-mem-TESTSESS-TURN1"
check "memory batch: the first one asks"              guardian "$FIX/write-memory-turn.json" contains '"ask"'
check "memory batch: the ask demands the whole list"  guardian "$FIX/write-memory-turn.json" contains "LIST THEM ALL HERE"
# The mark is written by PostToolUse, which does not run unless the user APPROVED. That is what makes
# an approval the thing the rest of the turn rides on, instead of a request the hook granted itself.
run_hook tracker "$FIX/write-memory-turn.json" >/dev/null
check "memory batch: the rest of the turn rides it"   guardian "$FIX/write-memory-turn.json" notcontains '"ask"'
check "memory batch: it says what was approved"       guardian "$FIX/write-memory-turn.json" contains "covered a LIST"
# Without a turn key there is no turn to key on, so it degrades to asking every time. A guarantee that
# switches off in silence is the exact failure this branch exists to prevent, so it is asserted.
check "memory batch: no prompt_id, no batch"          guardian "$FIX/write-memory-no-turn.json" contains '"ask"'
rm -f "${TMPDIR:-/tmp}/hi-claude-mem-TESTSESS-TURN1" \
      "${TMPDIR:-/tmp}/hi-claude-turn-TESTSESS" "${TMPDIR:-/tmp}/hi-claude-size-TESTSESS"

check "guardian: the CLAUDE.md ask demands ONE write" guardian "$FIX/write-claude-md.json" contains "ONE WRITE"
check "guardian: the memory ask does not"             guardian "$FIX/edit-memory.json"     notcontains "ONE WRITE"
# The instruction to group has to reach the MODEL, and the permission dialog reaches the user. So it
# rides the write that already happened, on the second one - the first has nothing to group with.
printf '%s\n' '{"session_id":"TESTSESS","prompt_id":"TURN2","cwd":"C:\\proj","hook_event_name":"PostToolUse","tool_name":"Edit","tool_input":{"file_path":"C:\\proj\\CLAUDE.md","old_string":"a","new_string":"b"},"tool_response":{}}' > "$FIX/post-edit-claude-md.json"
rm -f "${TMPDIR:-/tmp}/hi-claude-gov-TESTSESS-TURN2"
check "tracker: the first governed edit stays quiet"  tracker "$FIX/post-edit-claude-md.json" empty
check "tracker: the second asks for ONE write"        tracker "$FIX/post-edit-claude-md.json" contains "in ONE write"
check "tracker: it does not repeat every edit after"  tracker "$FIX/post-edit-claude-md.json" empty
rm -f "${TMPDIR:-/tmp}/hi-claude-gov-TESTSESS-TURN2" \
      "${TMPDIR:-/tmp}/hi-claude-turn-TESTSESS" "${TMPDIR:-/tmp}/hi-claude-size-TESTSESS"

# --- the horizon is in BOTH templates, or half the users never get it ---
for lang in es en; do
  t="$ROOT/skills/setup/templates/$lang/ROADMAP.template.md"
  grep -qiE '^## .*(Horizonte|Horizon)' "$t" \
    && ok "template $lang: carries the horizon section" \
    || ko "template $lang: carries the horizon section" "missing"
  # A horizon inside the injected block is a bigger register with another name.
  awk '/hi-claude:en-curso -->/{f=1} /\/hi-claude:en-curso/{f=0} f' "$t" \
    | grep -qiE 'Horizonte|Horizon' \
    && ko "template $lang: the horizon sits OUTSIDE the injected block" "it is inside" \
    || ok "template $lang: the horizon sits OUTSIDE the injected block"
done

# --- belonging: the doctrine reached the constitution ---
grep -qF "BELONGS" "$ROOT/skills/memory-protocol/constitution.md" \
  && ok "constitution: carries the belonging axis" \
  || ko "constitution: carries the belonging axis" "missing"
grep -qF "CURRENT sits above BELONGS" "$ROOT/skills/memory-protocol/constitution.md" \
  && ok "constitution: currency outranks belonging" \
  || ko "constitution: currency outranks belonging" "missing"
grep -qF "MOVING IS NOT PRUNING" "$ROOT/hooks/closer" \
  && ok "closer: asks what is not in its place" \
  || ko "closer: asks what is not in its place" "missing"

# The lock is what keeps a concurrent run from reporting red that is not a regression. While THIS run
# holds it, a second mkdir has to fail - that is the whole guarantee.
if mkdir "$LOCK" 2>/dev/null; then
  rmdir "$LOCK" 2>/dev/null
  ko "bench: a second run cannot start while this one holds the lock" "the lock was not held"
else
  ok "bench: a second run cannot start while this one holds the lock"
fi

# The register key must NEVER fall back to the session: that is the unreachable threshold this key
# exists to remove, and it would come back without failing loudly.
if grep -A2 'cksum' "$ROOT/hooks/tracker" | grep -qF 'key="$session"'; then
  ko "tracker: the key fallback stays keyed by the register" "it falls back to the session"
else
  ok "tracker: the key fallback stays keyed by the register"
fi

# The turn markers are session-scoped state in the temp dir. A test bench that leaves its own state
# behind makes the NEXT run start dirty, and a closer that finds a stale marker blocks for nothing.
rm -f "${TMPDIR:-/tmp}"/hi-claude-turn-TESTSESS "${TMPDIR:-/tmp}"/hi-claude-size-TESTSESS 2>/dev/null
[ -e "${TMPDIR:-/tmp}/hi-claude-turn-TESTSESS" ] || [ -e "${TMPDIR:-/tmp}/hi-claude-size-TESTSESS" ] \
  && ko "bench: leaves no state behind" "markers survived" || ok "bench: leaves no state behind"

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
