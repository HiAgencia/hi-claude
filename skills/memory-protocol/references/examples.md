# Examples — bad vs good

> Cases 1-3 and 6 are the ADMISSION axis (does this persist at all). Cases 4, 5, 7 and 8 are the
> WRITING axis (how it is written once it does).

## 1. Ephemeral state vs timeless rule

BAD — `project-status.md`: "Today I migrated the scraper; commit pending; deadline June 16."
GOOD — `project-deploy-two-steps.md`: "Deploy requires `apify login` and `apify push` as two separate calls. **Why:** chained with && the push is skipped on Windows without any error. **How to apply:** always two Bash calls."

## 2. Document dump vs short rule + path

BAD — a 94-line memory with a full design checklist inside.
GOOD — `feedback-balance-checklist.md`: "Apply the horizontal-balance checklist when designing slides. **How to apply:** see docs/design/balance-checklist.md" (and the checklist lives in docs/).

## 3. Duplicated preference vs linked memory

BAD — the same "user prefers autonomous execution" memory written in 4 different projects.
GOOD — one entry in `~/.claude/CLAUDE.md`: "Prefer autonomous execution; don't ask before reversible actions." Project memories link context when needed: "Autonomy preference applies — see user-level config. Related: [[feedback-decision-style]]".

## 4. The rule with its history glued on vs the rule with a path to its evidence

BAD — "LinkedIn via MCP works (validated N=10: 10/10 companies, 9/10 profiles, on the April run)."
GOOD — "LinkedIn via MCP: use the logged-in browser snapshot, never raw HTTP. **Why:** raw HTTP gets the logged-out page. **How to apply:** evidence and its N in docs/evidence/linkedin-mcp.md."

The figure and the date expire inside a text that does not. The memory keeps the rule; the number lives
where it can be re-measured.

## 5. Secret vs reference

BAD — `project-tokens.md`: "Apify token: apify_api_3dT9..."
GOOD — "Apify auth: token lives in the `APIFY_TOKEN` env var (set per machine). NEVER write token values in files."

## 6. Missing scope vs explicit scope

BAD — "Always uppercase brand names." (breaks prose everywhere)
GOOD — "Uppercase brand names in N8N node titles. EXPLICIT SCOPE: only N8N workflow JSON, not prose."

## 7. Closed verdict vs reopenable state (NON-CONDITIONING)

BAD — `project-no-parallel.md`: "Parallel uploads don't work with this API. Don't try."
GOOD — `project-upload-concurrency.md`: "Cap uploads at 4 concurrent. **Why:** above that the provider answered HTTP 429 when observed; the runs are in docs/evidence/uploads.md. **Reopens if:** the plan changes or the provider publishes a higher limit."

A memory is the text that outlives the reason it was written. "Don't try" costs every future session
the attempt; the second form costs nothing and carries the condition that makes it obsolete.

## 8. Attributed cause vs observed fact (OBJECTIVE)

BAD — `feedback-bad-scraper.md`: "The scraper is badly built, that's why it fails."
GOOD — `project-scraper-timeout.md`: "The scraper returns empty on large pages: the timeout fires before the DOM settles. **How to apply:** raise the wait or paginate before scraping."

The first blames and closes. The second describes what happens, under what condition, and leaves the
next session somewhere to act.
