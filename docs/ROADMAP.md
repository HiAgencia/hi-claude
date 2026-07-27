<!-- Registro ÚNICO de lo que falta en el plugin. Los comentarios HTML no consumen contexto. -->
# ROADMAP — hi-claude

> Lo que FALTA, imperativo y atemporal. Al cerrarse un ítem se BORRA: lo hecho vive en `ESTADO.md`,
> en el código y en los commits. Sin fechas, sin bitácora, sin ✅.

## 0. Mapa de ejecución

**Vías de cierre** — sin marca = `[C]`. Se marca solo lo que una sesión NO cierra sola:

| Vía | Qué necesita además del trabajo | Qué puede hacer una sesión |
|---|---|---|
| `[C]` trabajo | nada | cerrarlo |
| `[V]` verificar | una instalación real del plugin, una versión de Claude Code | dejarlo listo + el comando exacto que lo cierra |
| `[O]` operación | el push al repo público, el marketplace | dejar el checklist ejecutable, no dispararlo |
| `[D]` decisión | el GO del dueño del método | traer el dato que decide, no el argumento |
| `[B]` medición | sesión dedicada de evals | fuera de alcance |

**HUBS** — se hacen primero porque desbloquean a otros:
*(todavía no hay)*

**Criterio de sesión cerrada** — corrible, se corre antes de declarar nada:
`bash tests/run-hook-tests.sh` verde · `plugin-dev:plugin-validator` sin críticos · si se tocó
cualquier `description`, `hi-claude-internal/tests/triggering/run-evals.ps1` ≥ el gate vigente.

**Decisiones que frenan** — necesitan GO antes de avanzar:
*(todavía no hay)*

<!-- hi-claude:en-curso -->
## 1. EN CURSO — máx 3

*(vacío)*

<!-- Formato de un ítem:
### Título imperativo  [V]
Falta: una línea.
Ya resuelto: una línea, re-escrita, nunca apilada.
(Hecho: comando corrible)
-->
<!-- /hi-claude:en-curso -->

## 2. Método y eficacia

### Medir si el método MEJORA el resultado, no solo si dispara `[B]`
Falta: el harness mide triggering de descriptions; nada mide si trabajar bajo el método produce mejor
trabajo. Para un plugin de memoria alcanzaba; para uno de metodología es el hueco de fondo. Diseñar la
vara antes que el experimento: qué se compara, contra qué línea base, con qué N.
(Hecho: un reporte en `hi-claude-internal/docs/evals/` con la comparación y su N.)

## 3. Robustez

### Revalidar `agent_id` cuando cambie la versión de Claude Code  `[V]`
Falta: el `deny` a escrituras de subagentes depende de que `PreToolUse` reciba `agent_id`. Si una
versión deja de mandarlo, el bloqueo deja de aplicarse EN SILENCIO — no falla ruidosamente.
Ya resuelto: medido y documentado en `hi-claude-internal/docs/evals/2026-07-26-agent-id-probe.md`
sobre Claude Code 2.1.220, con el método de la sonda listo para re-correr.
(Hecho: la sonda re-corrida devuelve al menos un `PreToolUse` con `agent_id` en la versión vigente.)
