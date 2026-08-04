#!/usr/bin/env bash
# Contract tests for hi-claude hooks: pipe a fixture into a hook, assert on its output.
# Usage: bash tests/run-hook-tests.sh
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FIX="$ROOT/tests/fixtures"
pass=0; fail=0

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
check "guardian: commit mentioning CLAUDE.md" guardian "$FIX/bash-commit-mentions-claude-md.json" empty
check "guardian: 2>&1 is not a write"         guardian "$FIX/bash-stderr-redirect.json"           empty
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
run_hook tracker "$FIX/post-write-code.json" >/dev/null
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
rm -f "${TMPDIR:-/tmp}/hi-claude-turn-TESTSESS"
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

# The turn markers are session-scoped state in the temp dir. A test bench that leaves its own state
# behind makes the NEXT run start dirty, and a closer that finds a stale marker blocks for nothing.
rm -f "${TMPDIR:-/tmp}"/hi-claude-turn-TESTSESS "${TMPDIR:-/tmp}"/hi-claude-size-TESTSESS 2>/dev/null
[ -e "${TMPDIR:-/tmp}/hi-claude-turn-TESTSESS" ] || [ -e "${TMPDIR:-/tmp}/hi-claude-size-TESTSESS" ] \
  && ko "bench: leaves no state behind" "markers survived" || ok "bench: leaves no state behind"

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
