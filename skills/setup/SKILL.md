---
name: setup
description: Day-1 onboarding for any project under the hi-claude method. Use when the user wants to set up, initialize, or organize a project ("set up this project", "configurá el proyecto", "empecemos", "cómo arranco", "ordená esta carpeta"), when a folder has no CLAUDE.md and the user asks how to begin, or right after the plugin is installed in a fresh project. Interactive: interviews the user, then generates CLAUDE.md, docs/INDEX.md, docs/ROADMAP.md, docs/ESTADO.md, base structure, and initial memory — all with explicit approval.
---

# hi-claude Setup

Onboard a project into the hi-claude method in ~5 minutes, interviewing the user in plain language
(they may be non-technical) and generating everything from templates.

## Phase 1 — Detect (no questions)

1. Inspect the working directory: empty folder or existing project? Is there a `CLAUDE.md` (root or
   `.claude/`)? A `docs/` folder? A git repo?
2. Note which MCP servers, plugins, and skills are available in THIS session (they are in your
   context) — you will propose which ones belong in the project's CLAUDE.md.
3. Detect the user's language from the conversation; generate everything in that language (templates
   exist in `es` and `en`).

## Phase 2 — Interview

One `AskUserQuestion` call. The tool takes 2-4 closed options per question and adds "Other" for free
text, so open answers arrive through it. Ask in the user's language, with plain words.

What must be resolved by the end of the interview — the wording is yours:

| Must be resolved | Becomes |
|---|---|
| What this project is | the CLAUDE.md header, in the user's own words |
| What kind of work it is | the folder tree: `src/`+`tests/` for code, `BRAND/`+`content/` for marketing, `research/` for documents |
| Which of the tools connected in THIS session belong to the project | the tools table, one "when to use it here" line each |
| Which limits are non-negotiable here | the LIMITING rules |
| What makes a session CLOSED, in a way that can be RUN | `{{SESSION_DONE_CRITERION}}` in the ROADMAP's §0 |

Ground every option in what you detected in the folder: a guess the user can correct beats a blank.
For the last one, a runnable criterion is the point — the test suite green and the linter clean for
code, the file published and reachable for content, every claim with its source for research.

## Phase 3 — Propose (nothing written yet)

Present the exact plan: the file tree to create and the full CLAUDE.md content, built from
`${CLAUDE_PLUGIN_ROOT}/skills/setup/templates/<lang>/CLAUDE.template.md` with every `{{PLACEHOLDER}}`
filled:

- `{{PROJECT_NAME}}`, `{{PROJECT_DESCRIPTION}}`
- `{{MEMORY_PATH}}` — the REAL memory directory: list `~/.claude/projects/` and match the slug derived
  from the project path (separators and specials replaced by dashes). If no match exists yet, use the
  derived form anyway — the directory appears with the first saved memory.
- `{{KEY_DOCS}}` — TIMELESS key documents only (research, trackers, manuals), one line each:
  `- **Descriptive title**: \`path\``. In a fresh project write the "nothing yet" placeholder. Plans
  and status docs never go here; when unsure, consult `references/decision-tree.md` in the
  memory-protocol skill.
- `{{FOLDER_TREE}}` — the structure for this kind of work; always includes `docs/`
- `{{TOOLS_TABLE}}` — only the tools the user selected
- `{{USER_RULES}}` — the limits, verbatim, marked non-negotiable
- `{{SESSION_DONE_CRITERION}}` — goes into `ROADMAP.template.md`, not into CLAUDE.md: a rule lives in
  one file

Wait for approval (the Guardian will also enforce confirmation on the CLAUDE.md write).

## Phase 4 — Generate

On approval: create the folders, then write from
`${CLAUDE_PLUGIN_ROOT}/skills/setup/templates/<lang>/`:

- `CLAUDE.md`
- `docs/INDEX.md`
- `docs/ROADMAP.md` — the register of what is missing
- `docs/ESTADO.md` (`STATE.md` in English projects) — the live picture of what exists

ROADMAP and STATE start empty on purpose: they fill up as work happens. If git is available and the
user agrees, offer `git init` + first commit.

## Phase 5 — Initial memory

If the user shared who they are (role, technical level, output preferences), propose ONE memory file
`user-profile.md` (type `user`) following the memory-protocol skill format — with approval. If a
preference clearly applies to all their projects, propose user level instead (see that skill's
decision tree).

## Existing projects

If a CLAUDE.md already exists: do NOT overwrite. Audit it instead (`/hi-claude:audit claude-md`) and
offer the missing pieces one by one, as explicit diffs:

- the `Gotchas` section — what the file tree does NOT say
- the `docs/ROADMAP.md` + `docs/ESTADO.md` pair, and the "Start here" reference to them
- the memory section, the tools table, and the docs index reference

A project coming from hi-claude v1 needs exactly the first two; everything else is already there.

## Tone

Plain language, no jargon, the user's language always. One short confirmation at the end: what was
created and what to do next ("just start working; I'll keep the ROADMAP current and remember what
matters — and you can run /hi-claude:audit anytime").
