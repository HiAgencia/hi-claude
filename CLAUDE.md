<!-- hi-claude dogfooding: this repo follows its own method. -->
# hi-claude (plugin source)

> **hi-claude governs this work** — the format, the practice, the retroactivity of every session. Its
> five principles, their two axes and the hierarchy that settles conflicts between them are defined in
> `skills/memory-protocol/constitution.md`, which the session hook injects at every start. Where form,
> criterion or scope is in doubt, hi-claude decides.

Claude Code plugin packaging the hi-claude working method: five principles with the hierarchy that settles them, governed memory, a curated CLAUDE.md, a register of open work, subagents that investigate and never decide, an inventory of what a project can use, a turn that does not end stale, and audits. This repo is BOTH the plugin and its marketplace.

## Start here

1. **`docs/ESTADO.md`** — what exists: every hook, skill and auditor with what it guarantees, plus the contract gotchas that were measured rather than deduced.
2. **`docs/ROADMAP.md`** — a pointer: open work for this plugin is kept in the maintainers' workspace, one level up, where both repos are visible. The runnable session-done criterion lives there, in its `§0`.
3. **`docs/INDEX.md`** — everything else.

## How to work here — the hi-claude method

- Persistent memory lives in `~/.claude/projects/<slug>/memory/`; `MEMORY.md` is its index — consult it before non-trivial work, even when you think you remember.
- Only TIMELESS, PREFERENTIAL, or LIMITING knowledge enters this file or memory — paths included: only timeless docs earn a reference here. Open work goes to `docs/ROADMAP.md`.
- ALWAYS consult before saving/modifying/deleting in memory or this file.
- Documentation does NOT live here: `docs/` with `docs/INDEX.md` as the entry point; this file only references paths.
- Clean root; everything in its folder.

## Project structure

```
.claude-plugin/   manifests (plugin.json + marketplace.json)
.gitattributes    pins hooks/** -text — load-bearing, see Gotchas
LICENSE           MIT, Hi Agencia
hooks/            hooks.json + run-hook.cmd (polyglot) + json-lib + one script per ROLE, named by
                  role because an event can carry more than one: PostToolUse has `tracker` (turn
                  bookkeeping) and `report-received` (a subagent's report just came back)
skills/           memory-protocol (+ constitution, references), roadmap (+ references),
                  work-protocol, delegation, seeding-doubts, setup (+ templates es/en), audit
agents/           read-only auditors (CLAUDE.md, memory, organization, ROADMAP, inventory)
BRAND/            Hi Agencia logo (white = dark mode, dark = light mode, used by README)
docs/             ROADMAP.md, ESTADO.md, INDEX.md
tests/            run-hook-tests.sh + fixtures/ (stdin payloads)
```

## Gotchas — what the tree does NOT say

- **The subagent write-block rests on `agent_id` reaching `PreToolUse`.** Measured on Claude Code 2.1.220 (`hi-claude-internal/docs/evals/2026-07-26-agent-id-probe.md`). If a version stops sending it, the `deny` stops applying **silently** — it does not fail loudly. Re-run that probe before trusting the guarantee on a new version. The probe record lives in the private workshop repo: maintainers only.
- **`hooks/json-lib` is sourced, never executed.** No shebang, not registered in `hooks.json`; every hook script sources it by path.
- **There is no `commands/` directory and none is needed.** Plugin skills are auto-exposed as `/<plugin>:<skill>`; verified in the session `init` event, which lists every skill under `slash_commands`. Adding a command file per skill would only duplicate them.
- **Hook scripts are extensionless on purpose** — Claude Code's Windows auto-detection prepends `bash` to commands containing `.sh`. Verify with `bash tests/run-hook-tests.sh` before committing.
- **`.gitattributes` pins `hooks/** -text` and is load-bearing.** It is the only thing keeping a Windows clone from checking out the hooks with CRLF, and a CRLF shebang kills every one of them. Do not "normalize" it.
- **`session-start` decides on real content, not on the block being non-empty.** A freshly generated ROADMAP carries a heading, an empty marker and a format comment; injecting that every session is noise, so the hook strips comments, headings and `*(placeholders)*` before deciding.
- **The `hi-claude:en-curso` HTML markers are identical in every language template.** That is what makes the extraction language-independent — renaming a heading is safe, touching a marker is not.
- **A description that reads as a definition does not trigger.** The ones that work open with `Use when/BEFORE …` and list the literal phrases, in both languages.
- **Never tune a description against a single eval run.** The harness runs each query once, and the run-to-run variance on the floor model is larger than the effect of an edit — the identical description measured 3/4 and 0/4. It is a precision gate, not a tuning instrument. Repeat, or change the architecture instead of the text.

## Tools

| Tool | When to use |
|---|---|
| skill: memory-protocol | Before any write to memory or this file — admission + consultation |
| skill: roadmap | Taking, splitting, pausing or closing work; before a compaction |
| skill: work-protocol | Writing docs, comments or commits; closing a problem |
| skill: delegation | Dispatching a subagent, and again when its report comes back |
| skill: seeding-doubts | Stuck on quality, or right after closing a big block |
| skill: setup | Bootstrapping CLAUDE.md / docs / register / inventory from the es/en templates |
| skill: audit (+ its five auditor agents) | Health check of CLAUDE.md, memory, ROADMAP, organization and inventory; run before each release |
| `bash tests/run-hook-tests.sh` | After ANY change to a hook, a template marker, or the doctrine |
| `claude plugin validate .claude-plugin/plugin.json` | After changing manifests, hooks, skills or agents. **Point it at the plugin.json, NOT at the directory**: given the directory it validates only the marketplace manifest and returns ✔ with a dead skill inside |
| `plugin-dev` (agent `plugin-validator`) | Deeper structural review before a release, when the CLI check is not enough |
| `hi-claude-internal/tests/triggering/run-evals.ps1` | MAINTAINERS ONLY (private repo) — after ANY change to a skill description; gate before shipping |
| context7 (MCP) | Current Claude Code plugin/skill/hook API docs before editing manifests or hook scripts |

## Key rules

- Design docs, plans, and eval methodology live in the PRIVATE repo `HiAgencia/hi-claude-internal` (full dev history archived there). Never commit them here.
- The shipped instruction surface (`skills/`, `agents/`, `hooks/`) is written in English; `docs/` is written in the maintainers' language, and user-facing output adapts to the user's language at runtime. Templates exist in `es/` and `en/`.
- Memory format reference: `skills/memory-protocol/references/memory-schema.md` is the single source of truth — native format changes are updated THERE only.
- License: MIT, copyright Hi Agencia.
