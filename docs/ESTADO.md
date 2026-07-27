<!-- Foto viva de lo que HAY en el plugin. -->
# ESTADO — hi-claude

> Foto ÚNICA de lo que existe hoy. Cuando algo cambia se ACTUALIZA acá mismo. **No acumula
> histórico**: nada de "antes/ahora", nada de crónicas.
>
> **Los números vivos no se copian acá**: la versión sale de `.claude-plugin/plugin.json`, los
> resultados de evals de `hi-claude-internal/docs/evals/`, y qué está publicado del `git log` de
> `origin/main`.
>
> Lo que FALTA vive en `ROADMAP.md`.

## En 30 segundos

hi-claude es un método de trabajo completo empaquetado como plugin: memoria gobernada, CLAUDE.md
curado, estructura limpia, registro de trabajo abierto que sobrevive a la compactación, rol de
subagente acotado por código, y auditorías bajo demanda. Todo activo siempre, cargado
progresivamente.

## Qué está activo

**Cuatro hooks** (`hooks/hooks.json`), todos bash sin dependencias:

| Hook | Qué garantiza |
|---|---|
| `SessionStart` (`startup·resume·clear·compact·fork`) | Inyecta la Constitución y, si el proyecto tiene uno, el bloque de trabajo abierto de `docs/ROADMAP.md`. Solo inyecta contenido REAL: un ROADMAP recién generado no produce ruido |
| `SubagentStart` | Inyecta el rol dentro del subagente: investiga, no implementa; su entregable son hipótesis |
| `PreCompact` | Pide volcar lo que quedó a medio hacer antes de comprimir el contexto |
| `PreToolUse` (`Write·Edit·MultiEdit·NotebookEdit·Bash`) | `deny` si un subagente escribe (escape: `HI_CLAUDE_SUBAGENT_WRITES=1`) · `ask` si la escritura toca CLAUDE.md o la memoria, incluida la vía Bash |

**Seis skills**: `memory-protocol` (+ Constitución y references), `roadmap`, `work-protocol`,
`seeding-doubts`, `setup` (+ plantillas `es`/`en`), `audit`.

**Cuatro agentes auditores** read-only: CLAUDE.md, memoria, organización, ROADMAP.

**El método en tres invariantes** — admisión, consulta, rastro — que es lo único que viaja en cada
sesión; el resto se abre por skill.

## Cómo se verifica

`bash tests/run-hook-tests.sh` corre el banco de pruebas de contrato de los hooks (incluye dos
chequeos de doctrina: que la regla de admisión y el árbol de decisión vivan en un solo archivo). El
harness de triggering vive en el repo interno y se corre ante cualquier cambio de `description`.
