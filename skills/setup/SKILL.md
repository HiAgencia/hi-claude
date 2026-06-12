---
name: setup
description: Day-1 onboarding for any project under the hi-claude method. Use when the user wants to set up, initialize, or organize a project ("set up this project", "configurá el proyecto", "empecemos", "cómo arranco", "ordená esta carpeta"), when a folder has no CLAUDE.md and the user asks how to begin, or right after the plugin is installed in a fresh project. Interactive: interviews the user, then generates CLAUDE.md, docs/INDEX.md, base structure, and initial memory — all with explicit approval.
---

# hi-claude Setup

Onboard a project into the hi-claude method in ~5 minutes, interviewing the user in plain language (they may be non-technical) and generating everything from templates.

## Phase 1 — Detect (no questions)

1. Inspect the working directory: empty folder or existing project? Is there a `CLAUDE.md` (root or `.claude/`)? A `docs/` folder? A git repo?
2. Note which MCP servers, plugins, and skills are available in THIS session (you can see them in your context) — you will propose which ones belong in the project's CLAUDE.md.
3. Detect the user's language from the conversation; generate everything in that language (templates exist in `es` and `en`).

## Phase 2 — Interview (one AskUserQuestion call, 3-4 questions max)

AskUserQuestion requires 2-4 closed options per question — never pass an open question without options. The tool automatically adds an "Other" free-text choice, so for open-ended questions offer plausible options and let the real answer arrive via "Other".

Ask in the user's language, with simple words:

1. "What is this project about?" — offer 3 plausible guesses based on what you detected in the folder (file names, configs); the user's own words (often via "Other") become the CLAUDE.md header
2. "What kind of work is it?" → options: Code/Software · Marketing/Content · Documents/Research · Mixed
3. "I detected these tools connected: [list MCPs/plugins]. Which should this project use?" (multiSelect; explain each in one plain-language line)
4. "Any rules or limits I should always respect here?" → options: "None in particular" · "Never commit without asking me" · "Never touch production or deploys" (plus "Other" for custom rules) → these become LIMITING rules

## Phase 3 — Propose (nothing written yet)

Present the exact plan: the file tree to create and the full CLAUDE.md content, built from `${CLAUDE_PLUGIN_ROOT}/skills/setup/templates/<lang>/CLAUDE.template.md` with every `{{PLACEHOLDER}}` filled:

- `{{PROJECT_NAME}}`, `{{PROJECT_DESCRIPTION}}` — from Q1
- `{{MEMORY_PATH}}` — the REAL memory directory for this project: list `~/.claude/projects/` and match the slug derived from the project path (path with separators/specials replaced by dashes). If no match exists yet, use the derived `~/.claude/projects/<slug>/memory/` form anyway — the directory appears with the first saved memory.
- `{{FOLDER_TREE}}` — base structure by project type: always `docs/`; add `src/` + `tests/` for Code; `BRAND/` + `content/` for Marketing; `research/` for Documents
- `{{TOOLS_TABLE}}` — only the tools selected in Q3, each with a "when to use it in this project" line you write
- `{{USER_RULES}}` — the limits from Q4, verbatim, marked as non-negotiable

Wait for approval (the Guardian will also enforce confirmation on the CLAUDE.md write).

## Phase 4 — Generate

On approval: create the folders, write `CLAUDE.md`, write `docs/INDEX.md` from `${CLAUDE_PLUGIN_ROOT}/skills/setup/templates/<lang>/INDEX.template.md` (fill `{{DATE}}` with today's date). If git is available and the user agrees, offer `git init` + first commit.

## Phase 5 — Initial memory

If the user shared who they are (role, technical level, output preferences), propose ONE memory file `user-profile.md` (type `user`) following the memory-protocol skill format — with approval. If a preference clearly applies to all their projects, propose user level instead (see the memory-protocol skill's decision tree).

## Existing projects

If a CLAUDE.md already exists: do NOT overwrite. Tell the user you'll audit it instead and suggest `/hi-claude:audit claude-md`; offer to merge missing method sections (structure rules, tools table, docs index reference) as explicit diffs, one by one.

## Tone

Plain language, no jargon, user's language always. One short confirmation at the end: what was created and what to do next ("just start working; I'll remember what matters — and you can run /hi-claude:audit anytime").
