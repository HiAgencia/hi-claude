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

# ---- cases are appended by each task ----

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
