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
curado, estructura limpia, registro de trabajo abierto que sobrevive a la compactación, cada contenido
con un destino declarado en vez de un archivo nuevo, subagentes acotados por código, inventario de lo
que la sesión puede usar, y cierre de turno que no deja el registro viejo. Todo activo siempre,
cargado progresivamente.

## Qué está activo

**Los hooks** (`hooks/hooks.json`), todos bash sin dependencias:

| Hook | Qué garantiza |
|---|---|
| `UserPromptSubmit` | Seis momentos que llegan por FRASE, cada uno en castellano y en inglés porque un regex no correlaciona entre idiomas: estancamiento o veredicto cerrado (protocolo de dudas) · una falla que VOLVIÓ (abrir los archivos antes de otra hipótesis) · una corrida que carga la máquina o un RELANZAMIENTO (`heavy-runs`, que por description sola no dispara) · «esto nunca me pasó» (comparar, no explicar) · el usuario REPITIENDO algo (barrer el patrón y proponer la regla) · una preferencia DURABLE (protocolo de memoria). Deliberadamente angosto: "este test falla, arreglalo" no dispara nada, y cada señal tiene en el banco su trampa hecha de las mismas palabras |
| `SessionStart` (`startup·resume·clear·compact·fork`) | Inyecta la Constitución SÓLO si el `CLAUDE.md` global del usuario no lleva el bloque entre marcadores `hi-claude:principios` —una regla vive en un archivo, y el respaldo cubre a quien lo rechazó—; el bloque de trabajo abierto del registro, que busca en el directorio y un nivel adentro —con varios candidatos los nombra en vez de elegir, y si el bloque pasa el presupuesto DICE que el resto no llegó, con su tamaño—; los TÍTULOS de la documentación declarada, para que un protocolo referenciado por path no quede invisible; y el drift del inventario de plugins, contando sólo lo que CARGA acá: un plugin instalado para otro proyecto no es drift. Solo inyecta contenido REAL, y si no hay nada que decir no emite nada |
| `SubagentStart` | Inyecta el rol dentro del subagente: investiga y nunca decide; puede leer, inspeccionar, testear y medir; su entregable son hipótesis y cierra con la cita del límite, textual |
| `PreToolUse` (escrituras, Bash, delegación y `mcp__.*`) | Para un SUBAGENTE: `deny` a escribir fuera de un destino temporal por cualquier tool, a Bash fuera de una allowlist de lectura y runners de test, a toda tool MCP que no declare en su nombre que LEE, y a delegar el trabajo. Sin escape por variable de entorno. Para el PRINCIPAL: al despachar, el protocolo de delegación; y el aviso de background en trabajos largos. Para CUALQUIERA: `ask` si la escritura toca CLAUDE.md o la memoria. Por Bash eso se decide por el DESTINO de un operador de escritura, nunca por el texto del comando —`git` no edita contenido y una mención en un mensaje de commit no es una escritura—; la única excepción es un intérprete, que escribe desde adentro de su propio código y ahí la mención es todo lo que hay. La consulta es UNA por TURNO: en CLAUDE.md porque se exige el cambio en UNA escritura, y en memoria porque cubre el LOTE que la primera consulta listó. Si la memoria es NUEVA, nombra las que ya comparten una palabra con ella, porque fusionar es lo barato antes de escribir. También `ask` si un borrado toca algo que está DENTRO de un repo y git NO trackea, porque no hay copia y la vara "git lo conserva" no aplica ahí; fuera de todo repo esa vara nunca alcanzó y no se emite nada; La consulta lleva delante las tres preguntas de ADMISIÓN, porque pedir sólo «confirmá el cambio» vuelve la aprobación un trámite sobre la forma. Las reglas de redacción llegan UNA vez por turno en la primera escritura de markdown —incluida «la regla va sin su historia»—, con el MAPA DE DESTINOS solo cuando el archivo todavía no existe, y el aviso de que un documento se edita con la tool de edición cuando la escritura llega por `sed -i`, un intérprete o una redirección |
| `PostToolUse` (escrituras) | Registra qué archivos cambió la sesión, una línea por ARCHIVO; escribir el registro —reconocido donde VIVE, bajo `docs/` o en la raíz del repo, con `node_modules` afuera—, la foto viva, el inventario, el documento de contexto, el índice de documentación, CLAUDE.md o la memoria salda la deuda —el índice y el contexto están en la lista porque un documento sale del árbol por la terminal y MOVER algo a su lugar cierra el circuito igual que escribir, y sin eso podar o mudar dejaba la deuda intacta—. Al escribir en `plans/` o `specs/` avisa, sin bloquear, si algún vecino sigue con casillas sin marcar: un plan abierto por vez. Y al escribir el registro mide su MONOTONÍA: cuatro turnos que lo tocaron sin que baje una sola vez emiten la señal, nombrando la SECCIÓN donde aterrizó ese crecimiento. El contador es por REGISTRO y no por sesión, porque la monotonía es una propiedad del archivo ENTRE sesiones |
| `PostToolUse` (`Agent·Task·Workflow`) | Al volver un reporte: es una hipótesis, se verifica de primera mano antes de que algo se apoye en ella |
| `Stop` | Frena UNA vez cuando la SESIÓN juntó tres archivos cambiados sin tocar el registro. Por debajo de ese umbral el turno pasa y la marca QUEDA: la deuda se difiere, no se perdona, y el bloqueo llega cuando vale la pena. Pregunta PRIMERO qué dejó de ser verdad por el cambio —y borrarlo cierra el circuito igual que escribir—, SEGUNDO qué no está en su lugar, TERCERO el registro, y sólo si cambió: foto viva, inventario, memoria, CLAUDE.md. Exime lo que el propio turno produjo, salvo la pregunta de lugar: MOVER no es podar, así que no cae bajo la regla de la distancia. Respeta `stop_hook_active`, limpia su marca al frenar y las marcas de consulta del turno. La evidencia del umbral vive en `docs/evals/` del taller |
| `PreCompact` | Pide volcar lo que quedó a medio hacer antes de comprimir el contexto |

**Ocho skills**: `memory-protocol` (+ Constitución y references), `roadmap`, `work-protocol`,
`delegation`, `seeding-doubts`, `heavy-runs`, `setup` (+ plantillas `es`/`en`), `audit`.

**El reparto entre lo que viaja siempre y lo que llega por situación**: los siete principios van al
`CLAUDE.md` global del usuario, en su idioma, como un bloque entre marcadores que `setup` y el target
`adoption` de `audit` PROPONEN —un plugin no escribe ese archivo—. Las prácticas llegan por HOOK en su
momento literal y la skill guarda el detalle: `work-protocol` lleva cómo se lee una falla, cómo se
verifica, qué resuelve el agente solo, los nombres y el barrido de un error señalado; `heavy-runs`
lleva el techo de máquina, el paralelismo derivado, el destino de escritura y el relanzamiento. El
porqué: `hi-claude-internal/docs/superpowers/specs/principios-al-global-practicas-al-plugin-design.md`.

**`audit adoption` contesta lo que ningún auditor contesta**: de lo que el plugin ofrece, qué NO está
usando este proyecto. Se corre después de actualizar. Su panorama vive DENTRO de `audit`, se REESCRIBE
en cada release y nunca se apila, entra sólo lo que le pide algo AL PROYECTO, y cada ítem se verifica
POR EFECTO. Propone; no aplica. Cuidado: un proyecto que salta varias versiones recibe el panorama
VIGENTE, no la unión de los deltas que se perdió: es la consecuencia elegida de reescribir.

**Seis agentes auditores** read-only: CLAUDE.md, memoria, organización, ROADMAP, inventario y
vigencia. Reportan la MEDICIÓN con su evidencia, nunca una calificación, y cierran citando su límite
textualmente. El de vigencia cubre `docs/` —el único directorio que no auditaba ninguno— y verifica
por EFECTO: una casilla sin marcar no prueba que el trabajo esté abierto, ni una marcada que esté
cerrado. Ninguno borra: proponen.

**El método en cada sesión** — los siete principios con su jerarquía, la regla de que la regla viaja
SIN su historia (la evidencia y su N viven en `docs/`), admisión, consulta, distancia y rastro. Viajan
por el `CLAUDE.md` global cuando el bloque está, y por la Constitución inyectada cuando no. El resto
llega por hook en su momento. VIGENCIA manda sobre PERTENENCIA a propósito: a algo que ya dejó de servir no se le
busca casa.

**El tamaño no es la vara.** Ninguna rúbrica cobra puntos por cantidad de líneas: se reporta como dato
y lo que puntúa es cuánto dejó de ser verdad. Un archivo largo donde todo sigue vivo está sano; uno
corto lleno de afirmaciones vencidas, no. Y nada se poda en el turno que lo produjo: lo que autoriza a
borrar es la evidencia de cierre, no la impresión de haber terminado.

**El inventario**: `setup` genera UN `INVENTARIO.md` / `INVENTORY.md` con una sección por clase —
skills, MCP, plugins y herramientas — con detalle proporcional a lo que el proyecto usa. Su sección de
Plugins es la que el arranque contrasta contra lo instalado, y el arranque acepta también los cuatro
documentos sueltos de proyectos anteriores. Es uno y no cuatro porque un tema repartido en varios
archivos es un costo sin contraparte, y el auditor propone la fusión cuando encuentra los cuatro.

## Gotchas del contrato — medidos, no deducidos

- **El validador oficial se apunta al `plugin.json`, no al directorio.** Dado el directorio valida
  SOLO el manifiesto del marketplace y devuelve ✔ con una skill muerta adentro. Medido: pasó verde
  mientras `setup` tenía el frontmatter roto.
- **Un `description:` en escalar plano termina en el primer `": "`.** YAML lee un mapping anidado y
  descarta TODO el frontmatter: la skill sigue resolviendo por nombre de directorio pero el modelo ya
  no puede dispararla, y nada falla ruidosamente. Los agentes usan `description: |`, que es inmune por
  construcción. El banco lo chequea en las 12 componentes.
- **Un valor JSON no se lee "hasta la próxima comilla": puede llevar comillas ESCAPADAS.** Medido: con
  ese patrón, todo comando de Bash con comillas llegaba truncado en el primer `\"`, y un comando
  truncado no matchea ninguna regla — el hook calla, y el silencio se lee igual que "no hay nada que
  decidir". Tres garantías quedaban evadidas con solo entrecomillar el comando: el `ask` sobre
  CLAUDE.md, el `ask` sobre memoria y el `deny` de escritura de un subagente. Sobrevivió al banco, al
  validador y a la verificación pre-push porque TODOS los casos de Bash del banco eran sin comillas.
  Se des-escapa solo `\"`: los paths de Windows llegan con backslashes dobles y varios puntos del
  código los colapsan por su cuenta.
- **Un token de separadores puros pasa el test de existencia.** En Windows `\` ES la raíz del drive, así
  que `[ -e ]` da verdadero: un parseo roto que deja `\` como candidato no falla ruidosamente, produce
  una respuesta segura de sí misma sobre el archivo equivocado.
- **Un hook de `Stop` que no lee STDIN no puede ver `stop_hook_active`, y eso es un bucle.** El campo
  con el que Claude Code avisa "ya estás dentro de un ciclo de cierre" viaja en el payload, así que un
  hook que decide sin leerlo vuelve a bloquear en cada reintento hasta que el runtime corta. Medido
  sobre un `Stop` de otro proyecto que además decidía por `git status`: el árbol no cambia cuando el
  agente contesta, así que la respuesta honesta —"revisado, ninguno quedó viejo"— era justo la que no
  podía apagarlo, y la única salida era editar un documento que no había cambiado. Un hook que decide
  por el estado del ÁRBOL necesita, además del corte de ciclo, una huella de lo ya preguntado.
- **Los matchers son un regex SIN anclar contra el nombre de la tool.** Por eso `Edit` cubre
  `MultiEdit` y `Task` cubre `TaskCreate` — y por eso `Write` atrapa `TodoWrite`, que el Guardián
  exime explícitamente: un todo de sesión no es un artefacto del proyecto.
- **`MultiEdit` y `SlashCommand` no están en `ToolInputSchemas`.** Nombrarlos en un matcher es una
  rama que nunca se ejecuta.
- **Una blocklist de verbos de mutación siempre va un verbo atrás.** Medido: `mcp__ide__executeCode`
  ejecuta código arbitrario —escribe lo que quiera— y no matcheaba ningún verbo de escritura. Por eso
  tanto la política de Bash como la de MCP son ALLOWLIST de lectura: lo que no declara que lee, se
  deniega. Es el lado seguro de lo desconocido.
- **Que un comando NOMBRE un archivo gobernado no es que lo escriba, y unir las dos coincidencias
  sueltas cuesta el 97% de las consultas.** Medido sobre transcripts reales: 285 comandos Bash
  llegaron a esa decisión y 8 escribían el archivo — 277 de más, 254 encabezados por `cd` y 14 por
  `git`. Bastaba un `>` en cualquier parte para declarar que el comando escribía, y un `2>/dev/null`
  o el `<noreply@anthropic.com>` de un trailer de commit lo aportan solos. Sondeado por efecto,
  `git log -- CLAUDE.md > hist.txt` y `git diff CLAUDE.md | tee d.txt` pedían permiso siendo LECTURA.
  Cuidado: el arreglo que destapó esto es el mismo que cerró tres evasiones: mientras `json_str` cortaba
  el comando en la primera comilla escapada, el guardián no veía un `git commit` entrecomillado — no
  estaba bien, estaba ciego.
- **En el lote de memorias, el HOOK garantiza la CONSULTA y el MODELO sostiene el CONTENIDO.** Lo que
  el código asegura es que la primera memoria del turno abre un diálogo que pide la lista completa, y
  que sin ese diálogo aprobado ninguna otra pasa. Lo que NO compara nada es si la memoria número tres
  estaba en esa lista: eso lo sostiene el modelo, avisado en cada una de las siguientes. La distinción
  importa porque el resto de esta pieza sí es por código, y leerla toda igual promete de más.
- **Un comando de LECTURA con un flag de ESCRITURA es un comando de escritura.** La allowlist de Bash
  del subagente admite linters y runners por su SUBCOMANDO, y varios reescriben el fuente cuando se
  les pide: medido, `cargo clippy --fix`, `npm run lint -- --fix` y `gradle check --write-locks`
  pasaban la contención mientras editaban el proyecto. El subcomando no es todo el contrato.
- **`sed` escribe sólo con `-i`.** Listarlo entero entre los que mutan convirtió `sed -n '83p' CLAUDE.md`
  —una LECTURA— en un pedido de confirmación: la misma confusión entre mencionar y escribir, un nivel
  más abajo, y apareció midiendo 691 comandos reales contra el hook nuevo.
- **UN COMANDO NO ES UN COMANDO, y decidir sobre el string entero le atribuye a un operador los
  argumentos de otra sentencia.** Medido en uso real: un `rm` de un lockfile bajo el directorio
  temporal levantó el aviso de borrado irreversible nombrando la RAÍZ DEL PROYECTO, que aparecía en
  una asignación de variable tres sentencias después. El `rm` estaba bien; lo que nombró, no — y un
  aviso que nombra lo equivocado es peor que ninguno, porque pide mirar algo que no es. Por eso tanto
  el gobernado como el borrado parten en SEGMENTOS y leen sólo los argumentos del segmento que muta.
- **`git ls-files --error-unmatch` sobre un DIRECTORIO siempre falla, aunque esté entero trackeado.**
  No es un pathspec que ese comando pueda matchear, así que preguntando así toda carpeta existente
  sale "sin copia" — medido sobre un repo que git venía cargando desde su primer commit. Un directorio
  cuenta como guardado cuando git trackea ALGO adentro.
- **Una respuesta vacía de `git ls-files` NO distingue «hay repo y esto está ignorado» de «acá no hay
  repo».** Las dos vuelven igual, y sólo la primera es el hueco que el aviso de borrado tapa: la vara
  "git lo conserva" gobierna el material DEL PROYECTO. Medido en uso real: borrar un directorio de
  trabajo en otro disco levantó el aviso citando una regla que nunca lo alcanzó. Por eso el aviso
  empieza por `rev-parse --git-dir` sobre el contenedor y fuera de todo repo no emite nada.
- **Un turno que reanuda una tarea de fondo no emite `Stop`.** Límite conocido y acotado: medido con
  la semántica real del marcador —que es por SESIÓN y no por turno—, la deuda se ARRASTRA y el 81% de
  los bloqueos llega igual en el turno que la generó; 13 de 62 sesiones terminan con deuda sin cobrar,
  mediana 1 archivo, máximo 4, 21 en total. Cobrar en `UserPromptSubmit` queda descartado con ese dato.
  Se reabre si la proporción de turnos reanudados sube muy por encima del 35,5% medido (N = 3.038).

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
