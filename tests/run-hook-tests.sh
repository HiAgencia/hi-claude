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
rm -rf "$proj" "$f"

proj2=$(mktemp -d)
f2=$(fixture_with_cwd session-start.json "$proj2")
check "session-start: no roadmap, no noise" session-start "$f2" notcontains "## Open work (docs/ROADMAP.md)"
check "session-start: still injects method" session-start "$f2" contains "hi-claude-method"
rm -rf "$proj2" "$f2"

# --- guardian ---
check "guardian: subagent write is denied"   guardian "$FIX/subagent-write.json"        contains '"deny"'
check "guardian: subagent read passes"       guardian "$FIX/subagent-read.json"         empty
check "guardian: bash append to CLAUDE.md"   guardian "$FIX/bash-append-claude-md.json" contains '"ask"'
check "guardian: bash read of CLAUDE.md"     guardian "$FIX/bash-read-claude-md.json"   empty
check "guardian: write to CLAUDE.md"         guardian "$FIX/write-claude-md.json"       contains '"ask"'
check "guardian: edit memory file"           guardian "$FIX/edit-memory.json"           contains '"ask"'
check "guardian: normal write passes"        guardian "$FIX/write-normal.json"          empty
out=$(HI_CLAUDE_SUBAGENT_WRITES=1 bash "$ROOT/hooks/guardian" < "$FIX/subagent-write.json")
[ -z "$out" ] && ok "guardian: escape hatch works" || ko "guardian: escape hatch works" "$out"
# False positives cost more than they protect: a prompt on every commit trains the user to click through.
check "guardian: commit mentioning CLAUDE.md" guardian "$FIX/bash-commit-mentions-claude-md.json" empty
check "guardian: 2>&1 is not a write"         guardian "$FIX/bash-stderr-redirect.json"           empty
# Writing rules ride along on markdown writes: as a skill description alone they never fired.
check "guardian: markdown write gets the rules" guardian "$FIX/write-markdown-doc.json" contains "TIMELESS"
check "guardian: markdown nudge is not a decision" guardian "$FIX/write-markdown-doc.json" notcontains "permissionDecision"
check "guardian: code write gets no nudge"      guardian "$FIX/write-normal.json"       empty
check "guardian: CLAUDE.md still asks, not nudges" guardian "$FIX/write-claude-md.json" notcontains "TIMELESS"

# --- subagent-start / pre-compact ---
check "subagent-start: states read-only role" subagent-start "$FIX/subagent-write.json" contains "HYPOTHES"
check "subagent-start: forbids implementing" subagent-start "$FIX/subagent-write.json" contains "does not implement"
check "pre-compact: points at EN CURSO"      pre-compact    "$FIX/pre-compact.json"    contains "docs/ROADMAP.md"

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

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
