<!-- Foto viva de lo que HAY en el plugin. -->
# ESTADO — hi-claude

> **hi-claude gobierna esta foto.** Sus principios y criterios de redacción llegan solos a cada
> sesión — acá no se copian.
>
> Foto ÚNICA de lo que existe hoy. Cuando algo cambia se ACTUALIZA acá mismo. **No acumula
> histórico**: nada de "antes/ahora", nada de crónicas.
>
> **Los números vivos no se copian acá**: la versión sale de `.claude-plugin/plugin.json`, los
> resultados de evals del taller privado, y qué está publicado del `git log` de `origin/main`.
>
> Lo que FALTA vive en el registro del workspace de los mantenedores.

## En 30 segundos

hi-claude es un método de trabajo completo empaquetado como plugin: memoria gobernada, CLAUDE.md
curado, estructura limpia, registro de trabajo abierto que sobrevive a la compactación, subagentes
acotados por código, inventario de lo que la sesión puede usar, y cierre de turno que no deja el
registro viejo. Todo activo siempre, cargado progresivamente.

## Qué está activo

**Los hooks** (`hooks/hooks.json`), todos bash sin dependencias:

| Hook | Qué garantiza |
|---|---|
| `UserPromptSubmit` | Detecta en el prompt las frases de estancamiento o de veredicto cerrado y trae el protocolo de dudas. Deliberadamente angosto: "este test falla, arreglalo" y "me falta una dependencia" no lo disparan |
| `SessionStart` (`startup·resume·clear·compact·fork`) | Inyecta la Constitución; el bloque de trabajo abierto del registro, que busca en el directorio y un nivel adentro —con varios candidatos los nombra en vez de elegir—; los TÍTULOS de la documentación declarada, para que un protocolo referenciado por path no quede invisible; y el drift del inventario de plugins. Solo inyecta contenido REAL |
| `SubagentStart` | Inyecta el rol dentro del subagente: investiga y nunca decide; puede leer, inspeccionar, testear y medir; su entregable son hipótesis y cierra con la cita del límite, textual |
| `PreToolUse` (escrituras, Bash, delegación y `mcp__.*`) | Para un SUBAGENTE: `deny` a escribir fuera de un destino temporal por cualquier tool, a Bash fuera de una allowlist de lectura y runners de test, a toda tool MCP que no declare en su nombre que LEE, y a delegar el trabajo. Sin escape por variable de entorno. Para el PRINCIPAL: al despachar, el protocolo de delegación; y el aviso de background en trabajos largos. Para CUALQUIERA: `ask` si la escritura toca CLAUDE.md o la memoria, incluida la vía Bash, y las reglas de redacción en toda escritura de markdown |
| `PostToolUse` (escrituras) | Registra si el turno tocó el sistema y su tamaño; escribir el registro, la foto viva, un inventario, el índice de documentación, CLAUDE.md o la memoria salda la deuda —el índice está en la lista porque un documento sale del árbol por la terminal, que ningún hook de escritura ve, y sin eso podar dejaba la deuda intacta—. Al escribir en `plans/` o `specs/` avisa, sin bloquear, si algún vecino sigue con casillas sin marcar: un plan abierto por vez |
| `PostToolUse` (`Agent·Task·Workflow`) | Al volver un reporte: es una hipótesis, se verifica de primera mano antes de que algo se apoye en ella |
| `Stop` | Frena UNA vez el fin de un turno que cambió el sistema. Pregunta PRIMERO qué dejó de ser verdad por el cambio —y borrarlo cierra el circuito igual que escribir— y después qué falta, sobre los seis destinos: registro, foto viva, docs, inventario, memoria, CLAUDE.md. Exime explícitamente lo que el propio turno produjo. Respeta `stop_hook_active` y limpia su marca al frenar. Tras cerrar un bloque grande OFRECE el pre-mortem inverso, sin bloquear |
| `PreCompact` | Pide volcar lo que quedó a medio hacer antes de comprimir el contexto |

**Siete skills**: `memory-protocol` (+ Constitución y references), `roadmap`, `work-protocol`,
`delegation`, `seeding-doubts`, `setup` (+ plantillas `es`/`en`), `audit`.

**Seis agentes auditores** read-only: CLAUDE.md, memoria, organización, ROADMAP, inventario y
vigencia. Reportan la MEDICIÓN con su evidencia, nunca una calificación, y cierran citando su límite
textualmente. El de vigencia cubre `docs/` —el único directorio que no auditaba ninguno— y verifica
por EFECTO: una casilla sin marcar no prueba que el trabajo esté abierto, ni una marcada que esté
cerrado. Ninguno borra: proponen.

**El método en cada sesión** — la soberanía, los seis principios con sus tres ejes (admisión,
redacción y vigencia), la jerarquía que resuelve conflictos entre ellos, y los cuatro invariantes:
admisión, consulta, rastro, vigencia. Es lo único que viaja siempre; el resto se abre por skill.

**El tamaño no es la vara.** Ninguna rúbrica cobra puntos por cantidad de líneas: se reporta como dato
y lo que puntúa es cuánto dejó de ser verdad. Un archivo largo donde todo sigue vivo está sano; uno
corto lleno de afirmaciones vencidas, no. Y nada se poda en el turno que lo produjo: lo que autoriza a
borrar es la evidencia de cierre, no la impresión de haber terminado.

**El inventario**: `setup` genera `SKILLS.md`, `MCP.md`, `PLUGINS.md` y `TOOLS.md` desde una plantilla
única, con detalle proporcional a lo que el proyecto usa. `PLUGINS.md` es el que el arranque contrasta
contra lo instalado.

## Gotchas del contrato — medidos, no deducidos

- **El validador oficial se apunta al `plugin.json`, no al directorio.** Dado el directorio valida
  SOLO el manifiesto del marketplace y devuelve ✔ con una skill muerta adentro. Medido: pasó verde
  mientras `setup` tenía el frontmatter roto.
- **Un `description:` en escalar plano termina en el primer `": "`.** YAML lee un mapping anidado y
  descarta TODO el frontmatter: la skill sigue resolviendo por nombre de directorio pero el modelo ya
  no puede dispararla, y nada falla ruidosamente. Los agentes usan `description: |`, que es inmune por
  construcción. El banco lo chequea en las 12 componentes.
- **Los matchers son un regex SIN anclar contra el nombre de la tool.** Por eso `Edit` cubre
  `MultiEdit` y `Task` cubre `TaskCreate` — y por eso `Write` atrapa `TodoWrite`, que el Guardián
  exime explícitamente: un todo de sesión no es un artefacto del proyecto.
- **`MultiEdit` y `SlashCommand` no están en `ToolInputSchemas`.** Nombrarlos en un matcher es una
  rama que nunca se ejecuta.
- **Una blocklist de verbos de mutación siempre va un verbo atrás.** Medido: `mcp__ide__executeCode`
  ejecuta código arbitrario —escribe lo que quiera— y no matcheaba ningún verbo de escritura. Por eso
  tanto la política de Bash como la de MCP son ALLOWLIST de lectura: lo que no declara que lee, se
  deniega. Es el lado seguro de lo desconocido.

## Superficies declaradas

- **Los runners de test** que la política de Bash permite ejecutan código del proyecto. Medido (N=1,
  pytest 9.1.0): el runner por sí solo escribe 11 entradas, todas caché regenerable
  (`.pytest_cache/`, `__pycache__/`), ninguna sobre código, docs, configuración ni memoria. Un test
  que escribe el código fuente SÍ lo logra y el runner reporta `passed`. Alcance real del bloqueo:
  un subagente puede EJECUTAR el código de test que el proyecto ya tiene commiteado — no puede
  escribir uno nuevo, así que no es una vía de entrada. Lo que no cubre es un proyecto cuyos tests
  modifican su propio código, y ahí no es el subagente el que escribe.
- **El drift automático cubre plugins**, que es lo enumerable con certeza desde un hook. Skills, MCP y
  tools se declaran en su documento y los mantiene el método.
- **Una `description` sola no dispara cuando la regla debe aplicar siempre.** Medido sobre las 65
  queries del harness: negativos 29/29 —cero falsos disparos—, positivos 24/36. `delegation` 0/4 y
  `seeding-doubts` 0/4, esta última confirmada además por uso real. Por eso toda regla que debe
  aplicar siempre vive en un hook y la skill guarda el detalle. La varianza entre corridas del modelo
  de piso supera al efecto de editar una description: el harness es gate de precisión, no
  instrumento de ajuste.

## Cómo se verifica

`bash tests/run-hook-tests.sh` corre el banco de contrato de los hooks: envoltura de salida por
evento, contención del subagente vía cada tool, ciclo completo de cierre de turno, drift del
inventario, soberanía en toda plantilla, y dos chequeos de doctrina (que la regla de admisión y el
árbol de decisión vivan en un solo archivo). El harness de triggering vive en el repo interno y se
corre ante cualquier cambio de `description`.
