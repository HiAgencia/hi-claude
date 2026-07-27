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
cualquier `description`, `run-evals.ps1` del taller privado ≥ el gate vigente.

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
(Hecho: un reporte de evals en el taller privado con la comparación y su N.)

## 3. Robustez

### Dar repetición al harness de triggering  `[B]`
Falta: el harness corre cada query UNA vez, y está medido que la varianza entre corridas supera al
efecto de editar una description (la misma description exacta dio 3/4 y 0/4). Así sirve como gate de
precisión, pero no para decidir si un cambio de texto mejoró algo. Necesita `-Repeat N` y reportar
mediana, no el último resultado.
(Hecho: `run-evals.ps1 -Ids @('sd-s-01') -Repeat 3` devuelve 3 resultados y su mediana.)

### Revalidar `agent_id` cuando cambie la versión de Claude Code  `[V]`
Falta: el `deny` a escrituras de subagentes depende de que `PreToolUse` reciba `agent_id`. Si una
versión deja de mandarlo, el bloqueo deja de aplicarse EN SILENCIO — no falla ruidosamente.
Ya resuelto: medido y documentado en la sonda de `agent_id` del taller privado
sobre Claude Code 2.1.220, con el método de la sonda listo para re-correr.
(Hecho: la sonda re-corrida devuelve al menos un `PreToolUse` con `agent_id` en la versión vigente.)
