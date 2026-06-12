# Where does each thing go?

| The knowledge is... | Destination | Example |
|---|---|---|
| A short rule that applies project-wide, every session | `CLAUDE.md` | "Deploy = two separate commands, never chained" |
| A personal preference or correction | Memory (`<type>-<slug>.md` + index line) | "Prefers lists over long tables" |
| TIMELESS documentation (research, tracker, manual) | `docs/` + entry in `docs/INDEX.md` + descriptive title + path in CLAUDE.md's documentation section | "Payment platforms research: docs/research/payments.md" |
| Ephemeral documentation (a plan, a status report, session notes) | `docs/` + entry in `docs/INDEX.md` ONLY — its path does NOT go in CLAUDE.md | This week's implementation plan |
| A rule that only applies to certain files/folders | `.claude/rules/<topic>.md` with `paths:` frontmatter | "All files under src/api/ need input validation" |
| A preference that applies to ALL the user's projects | User level: `~/.claude/CLAUDE.md` or `~/.claude/rules/` — saved ONCE | "Always answer in Spanish, concise" |
| Ephemeral state, progress, dated pendings | NOWHERE persistent. Conversation only (or a `docs/` status note if the user insists) | "Pending CSP fix ~Jun 16" |
| A secret, token, credential | NEVER in CLAUDE.md, memory, or docs. Env vars / secret manager; reference the variable name only | `APIFY_TOKEN` env var |

Tiebreakers:

- Paths ARE the indexing mechanism: a descriptive title + path lets every session know what exists without spending tokens reading it — the file gets opened only when needed. This applies identically to CLAUDE.md doc references and to MEMORY.md entries.
- The admission rule governs paths too: a document can matter (→ docs/ + INDEX.md) without its path earning a place in CLAUDE.md. Only timeless knowledge gets referenced there.
- CLAUDE.md is for what Claude must hold EVERY session; if it only matters sometimes → rules with `paths:` or a skill.
- If you find yourself writing the same memory in a second project → it belongs at user level.
- If a "memory" exceeds ~25 lines → it is a document; move the content to `docs/` and keep a short memory pointing to the path.
