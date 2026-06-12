# Where does each thing go?

| The knowledge is... | Destination | Example |
|---|---|---|
| A short rule that applies project-wide, every session | `CLAUDE.md` | "Deploy = two separate commands, never chained" |
| A personal preference or correction | Memory (`<type>-<slug>.md` + index line) | "Prefers lists over long tables" |
| Documentation, a procedure, an analysis, reference material | `docs/` + entry in `docs/INDEX.md` + path referenced in CLAUDE.md | API integration guide |
| A rule that only applies to certain files/folders | `.claude/rules/<topic>.md` with `paths:` frontmatter | "All files under src/api/ need input validation" |
| A preference that applies to ALL the user's projects | User level: `~/.claude/CLAUDE.md` or `~/.claude/rules/` — saved ONCE | "Always answer in Spanish, concise" |
| Ephemeral state, progress, dated pendings | NOWHERE persistent. Conversation only (or a `docs/` status note if the user insists) | "Pending CSP fix ~Jun 16" |
| A secret, token, credential | NEVER in CLAUDE.md, memory, or docs. Env vars / secret manager; reference the variable name only | `APIFY_TOKEN` env var |

Tiebreakers:

- CLAUDE.md is for what Claude must hold EVERY session; if it only matters sometimes → rules with `paths:` or a skill.
- If you find yourself writing the same memory in a second project → it belongs at user level.
- If a "memory" exceeds ~25 lines → it is a document; move the content to `docs/` and keep a short memory pointing to the path.
