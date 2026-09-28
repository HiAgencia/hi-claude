<p align="center">
  <a href="https://hiagencia.com/?utm_source=github&utm_medium=readme&utm_campaign=hi-claude&utm_content=hero_logo">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="BRAND/hiagencia-logo-white.png">
      <img src="BRAND/hiagencia-logo-dark.png" alt="Hi Agencia" width="110">
    </picture>
  </a>
</p>

<h1 align="center">hi-claude</h1>

<p align="center">
  <strong>The first thing you should say to Claude in every new project.</strong><br>
  <em>Lo primero que deberías decirle a Claude en cada proyecto nuevo.</em><br><br>
  Install once. Every session remembers what matters — and never loses the thread.<br>
  <em>Instalalo una vez. Cada sesión recuerda lo que importa — y nunca pierde el hilo.</em>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Claude_Code-%E2%89%A5_2.1.143-d97757?logo=anthropic&logoColor=white" alt="Claude Code">
  <img src="https://img.shields.io/badge/version-3.0.0-4c8cff" alt="Version">
  <img src="https://img.shields.io/badge/license-MIT-green" alt="License">
  <img src="https://img.shields.io/badge/false_triggers-zero-2ea44f" alt="Zero false triggers">
  <img src="https://img.shields.io/badge/dependencies-zero-2ea44f" alt="Zero dependencies">
  <img src="https://img.shields.io/badge/EN_·_ES-bilingual-8a2be2" alt="Bilingual">
</p>

<p align="center">
  <a href="https://hiagencia.com/?utm_source=github&utm_medium=readme&utm_campaign=hi-claude&utm_content=hero_nav">hiagencia.com</a> ·
  <a href="https://www.linkedin.com/company/hiagencia/">LinkedIn</a> ·
  <a href="https://x.com/hiagenciacom">X (@hiagenciacom)</a> ·
  <a href="#hi-claude-español"> Versión en español ↓</a>
</p>

---

## The problem

Claude Code already remembers. The problem is **what** it remembers, and what your `CLAUDE.md` looks like after three months: stale notes, documentation pasted inline, dead paths, secrets in plain text, rules that contradict each other.

And there is a second problem nobody names. Halfway through a long session the context gets compacted, and the answer to *"what were we doing?"* is gone. Not the code — the code is fine. What is gone is the half-finished decision, the thing you were about to check, the reason you left that branch open.

hi-claude packages the discipline that fixes both, sharpened over 18 months of running real client systems on Claude Code, into a method anyone can install. Even someone who opened a terminal for the first time today.

## Install (2 commands, inside Claude Code)

```
/plugin marketplace add HiAgencia/hi-claude
/plugin install hi-claude@hi-claude
```

Restart the session (or run `/reload-plugins`). There is no step 3.

## What you get

| Moment | What hi-claude does |
|---|---|
| **Day 1** | `/hi-claude:setup` interviews you in plain language and generates your CLAUDE.md, your docs index, your ROADMAP and your initial memory. With your approval, always. |
| **Every day** | The open work stays written down as you go. Claude proposes remembering only what is worth keeping: timeless rules, your preferences, your limits. It never touches memory or CLAUDE.md without asking first. |
| **When the context compacts** | Claude is told to write down what is half-finished *before* the squash. What comes out the other side still knows where you were. |
| **Maintenance** | `/hi-claude:audit` measures your CLAUDE.md, your memory, your roadmap, your folder organization, your inventory and how much of your documentation stopped being true, shows findings with `file:line` evidence, and fixes only what you approve. It reports what it counted — never a grade on your own files. |

## How it works

| Layer | What it guarantees |
|---|---|
| **The Constitution** | Seven principles on four axes, the hierarchy that settles conflicts between them, and four invariants — present from the first second of every session, including resumed and forked ones. Nothing else is loaded upfront; the rest opens when the task asks for it. |
| **The ROADMAP** | One file holds what is missing. Its open-work block is injected at every session start, so *"where did we leave off"* has an answer that survives a compaction, a `--resume`, and a week off. Work that is not for now lives in the **horizon** of its thematic block — same file, with the condition that brings it in, and it never rides into the session. When an item is finished it is **deleted**, not ticked — that is why the file stays short. |
| **The Guardian** | Nothing gets written to CLAUDE.md or persistent memory without your explicit confirmation. Enforced by code, not by trust — including writes attempted through the shell, where the decision is the **destination** of a write operator and never a mention: a commit that names CLAUDE.md is not a change to it. And it is **one consultation per turn**, not one per edit. |
| **The subagent's role** | A subagent **investigates; it never decides what gets done.** It may read, inspect, test and measure — and a hook denies every write to your project through any tool, with no environment-variable escape. What it brings back is a hypothesis until the main agent verifies it first-hand, and every report says so in its own closing line. |
| **The work does not end stale** | When a session has changed three files without touching the register, it gets stopped once, with the loop to close: what stopped being true, what is not in its place, the register — and the live picture, the inventory, memory or CLAUDE.md only if they changed. Below that the turn passes and the debt stays on the books: a demand raised over one file mostly finds nothing, and a demand that mostly finds nothing gets answered without looking. Not a reminder that may or may not fire: a hook. |
| **The inventory** | One document says which skills, MCP servers, plugins and tools this project can use, described in proportion to what it actually uses. Start-up flags it when what is installed stops matching what is written. |
| **Nothing lands in the wrong place** | A content can be true, well written and still useful — and still end up in the document where nothing dislodges it. Creating a file is the LAST option: at the moment of creating one you get the destinations that already exist, and what is not opened session after session goes to ONE context document. The register is watched for MONOTONY, because a healthy one oscillates: work comes in, work closes. |
| **Practices that arrive at their moment** | Say you are stuck, that a failure came back, that *"this never happened to me before"*, or that you already explained something — and the protocol for THAT moment arrives on its own, in English or in Spanish: doubts instead of conclusions, files opened before another hypothesis, a comparison instead of an explanation, a sweep of the whole pattern instead of one fix. Those are exactly the moments nothing feels like it needs a skill, which is why they cannot be left to one. |
| **Long jobs go to the background** | A test run, a build, an install gets flagged at the call, the only moment it can still be changed. A blocked wait costs the whole turn. |
| **The memory protocol** | Kicks in on its own when you correct something, confirm an approach, or state a preference ("I don't like...", "from now on...", "recordá que..."). It proposes what to remember; you decide. |
| **Nothing outlives its truth** | A plan whose work shipped, an item nobody deleted, a rule describing a flow the code replaced — all of it reads as current forever unless something asks the third question. A sixth auditor covers `docs/`, the turn ends by asking what stopped being true *before* asking what is missing, and deleting closes the loop exactly as writing does. **Size is never the measure**: nothing scores points for line count. |
| **Six auditors** | Read-only reviewers for CLAUDE.md, memory, ROADMAP, organization, the inventory and currency. Every finding cites its evidence, two per category at most, and inventing problems is off the table. They report the measurement, never a grade on your files. Not one of them deletes: they propose. |

## The seven principles

> **What deserves to outlive the session** — PREFERENTIAL, you said you like it that way · LIMITING, a boundary you set · TIMELESS, true today and in five months.
>
> **Where it goes** — BELONGS, content lives where the session that needs it opens it. What is not opened session after session is CONTEXT, and context lives together, in one place, compressed. Any pair that can be merged is merged, and creating a new document is the LAST option.
>
> **How anything gets written** — OBJECTIVE, the fact with its evidence and no verdict of value · NON-CONDITIONING, the state observed with its method, never a closed door.
>
> **Whether what is already written is still alive** — CURRENT, a line stays while it is still true *and* still serves a future session. Failing either, it goes: not archived, not ticked, not struck through. Gone — git keeps it.
>
> Everything else has a home that is not memory: documentation goes to `docs/`, open work goes to `ROADMAP.md`, and CLAUDE.md keeps the path — declaring what each one is OPENED FOR.

The first three are why hi-claude projects stay sharp while others drown in their own notes. The fourth is why they do not drown in *files* either: a subject split across four documents costs something and pays nothing back, and the twenty-sixth document is one nobody opens. The next two are why no document ever tells a future session that something is impossible — a closed verdict costs every session after it the attempt. The last one is why the notes that *are* kept do not quietly turn into a museum: line count is never the measure, only whether each line is still true and still useful.

And it cuts the other way too. **Nothing is pruned in the turn that produced it** — fresh out of the work, the one who did it is the worst judge of whether it closed well. What authorises deleting is evidence: the criterion that runs, the version shipped, the test green. In the heat, it gets marked; it gets pruned once the evidence lands, and never without your word.

## The working method

Four skills carry the parts of the craft that are not memory. They load when the moment calls for them, not before.

- **`roadmap`** — how work is taken, split, paused and closed. Every item declares what still blocks it: nothing, the real world, a window, your GO, or a dedicated measurement. Its "done" criterion is something you can *run*, not a sentence two sessions will read differently.
- **`work-protocol`** — how it gets written down. No verdicts written as final, no "for now", no documentation that turns into a diary. A measured result is a datum with its N, reopenable. Before correcting any text it measures what is TRUE NOW — discovering the project's own test runner, gate and live environment instead of assuming them. And every problem closed leaves the system easier to operate than it was.
- **`delegation`** — what gets asked of a subagent and what happens to what it brings back. Delegate the looking, never the deciding, and never the change itself. A report is input to your judgement, never a substitute for it.
- **`seeding-doubts`** — for when quality stalls and nothing looks obviously wrong. Introspection, then three subagents with deliberately different tones whose deliverable is **more doubts, never answers**, then immediate verification of everything checkable. There is no "it can't be done" — there is an angle not tried yet.
- **`audit adoption`** — run it after updating the plugin. Updating changes nothing in your projects on its own: a project can be perfectly healthy while missing a whole capability. This target of `audit` asks the other question — of what the plugin offers, what is this project not using — and measures YOURS by effect, with your numbers. It proposes; you decide.
- **`heavy-runs`** — before anything that loads the machine or gets re-launched: the load ceiling is of the WHOLE machine, parallelism is derived from a measured unit cost, a run's destination is part of its contract, and the chain is read whole before the first launch.

## What sharp looks like

After a few weeks of real work, an audit might find:

- A CLAUDE.md bloated with pasted procedures → moved to `docs/`, one path reference left behind
- A ROADMAP full of finished items marked sí → deleted; what shipped lives in the code and in `STATE.md`
- The same preference saved three times in three wordings → merged into one
- A production token sitting in plain text → flagged first, before anything else

Everything else stays sharp on its own, because only what deserves to survive the session ever got saved.

## Numbers, not promises

- Official plugin validation: passed, zero critical issues.
- 65 trigger scenarios in English and Spanish, including deliberately tricky near-misses. **Negatives: 29/29 — zero false triggers.** A skill never fires when it shouldn't.
- Positive recall is the honest half: 24/36 in a full run, and the run-to-run variance on the floor model is larger than the effect of editing a description. It is reported as a datum with its N, not as a score.
- **That is why recall is not what the method rests on.** Every rule that must apply *always* lives in a hook, measured case by case: `delegation` scored 0/4 on its own phrasings, so the protocol rides on the dispatch itself. `seeding-doubts` scored 0/4 — a stall is exactly when nothing feels like it needs a skill — so a prompt-level hook catches the phrasing deterministically. The writing rules ride on every markdown write.
- **And the hooks were checked by EFFECT, not by whether a skill got invoked.** Same query, same model, with the plugin and without it. *"Algo anda mal y no sé qué"* → **with**: numbered doubts ordered by damage × cost, whatever is already shipped first. **Without**: "what specifically isn't working?". The protocol arrives and runs even though the harness still reports 0/4 — because the harness only ever sees skill invocations. A number that measures the wrong mechanism is worse than no number, so that limit is written into the runner itself.
- The hook contract bench in one command: output envelopes per event, subagent containment through every tool, the full turn-close cycle, inventory drift, declared-protocol injection, and two checks that the doctrine itself is not duplicated — a rule living in two files is a bug, and the tests say so.
- The subagent block rests on `agent_id`, a documented field of the hook payload, plus a re-runnable probe of what the hook actually receives. Its residual surface — a permitted test runner executes project code, and that code can write — is declared, not hidden.
- Tested end to end on Windows, the environment where things usually break. Built cross-platform.
- This repo runs on its own method: clean root, indexed docs, its own ROADMAP.

## Try this after installing

Open any project and just talk:

> *"No me gusta que uses tablas tan largas. Para la próxima, listas."*

Claude classifies it as a preference, proposes the exact memory entry, and waits for your OK. From that day on, every session knows.

Then, tomorrow:

> *"¿En qué quedamos?"*

---

## Who's behind this

<a href="https://hiagencia.com/?utm_source=github&utm_medium=readme&utm_campaign=hi-claude&utm_content=about_logo">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="BRAND/hiagencia-logo-white.png">
    <img src="BRAND/hiagencia-logo-dark.png" alt="Hi Agencia" width="64" align="left">
  </picture>
</a>

**hi-claude** is built by [**Hi Agencia**](https://hiagencia.com/?utm_source=github&utm_medium=readme&utm_campaign=hi-claude&utm_content=about_text), a marketing and automation agency that runs its entire operation on Claude Code: scrapers, client systems, websites, courses, internal tooling. This method didn't come out of a whiteboard. It was earned project by project over 18 months, then packaged so our clients, and you, start on day 1 where we arrived after a year and a half.

The logo says *hi*. So does the plugin.

[hiagencia.com](https://hiagencia.com/?utm_source=github&utm_medium=readme&utm_campaign=hi-claude&utm_content=about_links) · [LinkedIn](https://www.linkedin.com/company/hiagencia/) · [X (@hiagenciacom)](https://x.com/hiagenciacom)

<br clear="left">

---

<h1 align="center" id="hi-claude-español">hi-claude </h1>

<p align="center"><strong>Lo primero que deberías decirle a Claude en cada proyecto nuevo.</strong></p>

## El problema

Claude Code ya tiene memoria. El problema es **qué** recuerda, y en qué se convierte tu `CLAUDE.md` después de tres meses: notas viejas, documentación pegada adentro, paths muertos, secretos en texto plano, reglas que se contradicen.

Y hay un segundo problema que nadie nombra. A mitad de una sesión larga el contexto se comprime, y la respuesta a *"¿qué estábamos haciendo?"* desapareció. El código no: el código está bien. Lo que se perdió es la decisión a medio tomar, lo que ibas a chequear, el motivo por el que dejaste esa rama abierta.

hi-claude empaqueta la disciplina que resuelve las dos, pulida durante 18 meses operando sistemas reales de clientes sobre Claude Code, en un método que cualquiera puede instalar. Incluso alguien que abrió una terminal por primera vez hoy.

## Instalación (2 comandos, dentro de Claude Code)

```
/plugin marketplace add HiAgencia/hi-claude
/plugin install hi-claude@hi-claude
```

Reiniciá la sesión (o corré `/reload-plugins`). No hay paso 3.

## Qué incluye

| Momento | Qué hace hi-claude |
|---|---|
| **Día 1** | `/hi-claude:setup` te entrevista en lenguaje simple y genera tu CLAUDE.md, tu índice de docs, tu ROADMAP y tu memoria inicial. Siempre con tu aprobación. |
| **Todos los días** | El trabajo abierto queda anotado sobre la marcha. Claude propone recordar solo lo que vale la pena: reglas atemporales, tus preferencias, tus límites. Y nunca toca la memoria ni el CLAUDE.md sin consultarte antes. |
| **Cuando el contexto se comprime** | A Claude se le pide que escriba lo que quedó a medio hacer *antes* del resumen. Lo que sale del otro lado sigue sabiendo dónde estabas. |
| **Mantenimiento** | `/hi-claude:audit` mide tu CLAUDE.md, tu memoria, tu roadmap, tu organización, tu inventario y cuánto de tu documentación dejó de ser verdad, muestra hallazgos con evidencia `archivo:línea`, y corrige solo lo que apruebes. Reporta lo que contó — nunca una calificación sobre tus propios archivos. |

## Cómo funciona

| Capa | Qué garantiza |
|---|---|
| **La Constitución** | Siete principios sobre cuatro ejes, la jerarquía que resuelve los conflictos entre ellos, y cuatro invariantes — presentes desde el primer segundo de cada sesión, incluidas las reanudadas y las forkeadas. Nada más se carga de entrada; el resto se abre cuando la tarea lo pide. |
| **El ROADMAP** | Un archivo con lo que falta. Su bloque de trabajo abierto se inyecta en cada arranque, así que *"en qué quedamos"* tiene respuesta después de una compactación, de un `--resume` y de una semana sin tocar el proyecto. Lo que no es para ahora vive en el **horizonte** de su bloque temático — mismo archivo, con la condición que lo trae, y no viaja nunca al arranque. Cuando un ítem termina se **borra**, no se tilda — por eso el archivo no crece. |
| **El Guardián** | Nada se escribe en el CLAUDE.md ni en la memoria sin tu confirmación explícita. Garantizado por código, no por confianza — incluidas las escrituras que intentan pasar por la terminal, donde lo que decide es el **destino** de un operador de escritura y nunca una mención: un commit que nombra el CLAUDE.md no es un cambio al CLAUDE.md. Y es **una consulta por turno**, no una por edición. |
| **El rol del subagente** | Un subagente **investiga; nunca decide qué se hace.** Puede leer, inspeccionar, testear y medir — y un hook le bloquea toda escritura a tu proyecto por cualquier herramienta, sin escape por variable de entorno. Lo que trae es una hipótesis hasta que el agente principal la verifica de primera mano, y cada reporte lo dice en su línea de cierre. |
| **El trabajo no termina viejo** | Cuando una sesión cambió tres archivos sin tocar el registro, se frena una vez, con el circuito a cerrar: qué dejó de ser verdad, qué no está en su lugar, el registro — y la foto viva, el inventario, la memoria o el CLAUDE.md sólo si cambiaron. Por debajo de eso el turno pasa y la deuda queda anotada: una demanda levantada por un archivo casi nunca encuentra nada, y una demanda que casi nunca encuentra nada se contesta sin mirar. No un recordatorio que puede o no aparecer: un hook. |
| **El inventario** | Un documento dice qué skills, servidores MCP, plugins y tools puede usar este proyecto, descritos en proporción a lo que realmente se usa. El arranque avisa cuando lo instalado deja de coincidir con lo escrito. |
| **Nada cae en el lugar equivocado** | Un contenido puede ser cierto, estar bien escrito y seguir sirviendo — y terminar igual en el documento donde nada lo desaloja. Crear un archivo es la ÚLTIMA opción: al crear uno te llegan los destinos que ya existen, y lo que no se abre sesión a sesión va a UN documento de contexto. Al registro se le mira la MONOTONÍA, porque uno sano oscila: entra trabajo, se cierra trabajo. |
| **Prácticas que llegan en su momento** | Decís que están estancados, que una falla volvió, que *"esto nunca me pasó"* o que eso ya lo explicaste — y el protocolo de ESE momento llega solo, en castellano o en inglés: dudas en vez de conclusiones, los archivos abiertos antes de otra hipótesis, una comparación en vez de una explicación, el barrido del patrón entero en vez de un arreglo suelto. Son justo los momentos en que nada se siente como que necesita una skill — por eso no pueden quedar librados a una. |
| **Los trabajos largos van al background** | Una corrida de tests, un build, un install: se marca en la llamada, el único momento en que todavía se puede cambiar. Una espera bloqueada cuesta el turno entero. |
| **El protocolo de memoria** | Se activa solo cuando corregís algo, confirmás un enfoque o declarás una preferencia ("no me gusta...", "de ahora en más...", "recordá que..."). Propone qué recordar; vos decidís. |
| **Nada sobrevive a su propia verdad** | Un plan cuyo trabajo ya salió, un ítem que nadie borró, una regla que describe un flujo que el código reemplazó: todo eso se lee como vigente para siempre si nada hace la tercera pregunta. Un sexto auditor cubre `docs/`, el cierre de turno pregunta qué dejó de ser verdad *antes* de preguntar qué falta, y borrar cierra el circuito igual que escribir. **El tamaño nunca es la vara**: nada puntúa por cantidad de líneas. |
| **Seis auditores** | Revisores de solo lectura para CLAUDE.md, memoria, ROADMAP, organización, inventario y vigencia. Cada hallazgo cita su evidencia, máximo dos por categoría, y tienen prohibido inventar problemas. Reportan la medición, nunca una calificación sobre tus archivos. Ninguno borra: proponen. |

## Los siete principios

> **Qué merece sobrevivir a la sesión** — PREFERENCIAL, dijiste que te gusta así · LIMITANTE, un límite que pusiste vos · ATEMPORAL, vale hoy y en cinco meses.
>
> **Dónde va** — PERTENECE, un contenido vive donde lo abre la sesión que lo necesita. Lo que no se abre sesión a sesión es CONTEXTO, y el contexto vive junto, en un solo lugar, comprimido. Todo par que se pueda fusionar se fusiona, y crear un documento nuevo es la ÚLTIMA opción.
>
> **Cómo se escribe cualquier cosa** — OBJETIVO, el hecho con su evidencia y sin juicio de valor · NO CONDICIONANTE, el estado observado con su método, nunca una puerta cerrada.
>
> **Si lo ya escrito sigue vivo** — VIGENTE, una línea se queda mientras siga siendo verdad *y* siga sirviéndole a una sesión futura. Si falla cualquiera de las dos, sale: no se archiva, no se tilda, no se tacha. Sale — git lo conserva.
>
> Todo lo demás tiene una casa que no es la memoria: la documentación va a `docs/`, el trabajo abierto va al `ROADMAP.md`, y el CLAUDE.md se queda con el path — declarando para qué se abre cada uno.

Los tres primeros son la razón por la que los proyectos hi-claude se mantienen afilados mientras otros se ahogan en sus propias notas. El cuarto es la razón por la que tampoco se ahogan en *archivos*: repartir un tema en cuatro documentos cuesta y no devuelve nada, y el documento número veintiséis es uno que nadie abre. Los dos siguientes son la razón por la que ningún documento le dice a una sesión futura que algo es imposible — un veredicto cerrado le cuesta el intento a todas las que vengan después. El último es la razón por la que las notas que sí se guardan no se convierten en museo: la cantidad de líneas nunca es la vara, solo si cada una sigue siendo verdad y sigue sirviendo.

Y corta para el otro lado también. **Nada se poda en el turno que lo produjo** — recién salido del trabajo, el que lo hizo es el peor juez de si cerró bien. Lo que autoriza a borrar es evidencia: el criterio que corre, la versión publicada, el test en verde. En caliente se marca; se poda cuando llega la evidencia, y nunca sin tu palabra.

## El método de trabajo

Cuatro skills cargan las partes del oficio que no son memoria. Se abren cuando el momento las pide, no antes.

- **`roadmap`** — cómo se toma, se parte, se pausa y se cierra un trabajo. Cada ítem declara qué le falta además del trabajo: nada, el mundo real, una ventana, tu GO, o una medición dedicada. Su criterio de "hecho" es algo que se *corre*, no una frase que dos sesiones leen distinto.
- **`work-protocol`** — cómo se deja escrito. Nada de veredictos escritos como finales, nada de "por ahora", nada de documentación que se convierte en diario. Un resultado medido es un dato con su N, reabrible. Antes de corregir un texto mide qué es verdad HOY — descubriendo el runner de tests, el gate y el entorno vivo que el proyecto tenga, en vez de asumirlos. Y cada problema que se cierra deja el sistema más fácil de operar.
- **`delegation`** — qué se le pide a un subagente y qué se hace con lo que trae. Se delega el MIRAR, nunca el DECIDIR, y jamás el cambio en sí. Un reporte es insumo de tu criterio, nunca un reemplazo.
- **`seeding-doubts`** — para cuando la calidad se estanca y nada parece estar mal. Introspección, después tres subagentes con tonos deliberadamente distintos cuyo entregable son **más dudas, nunca respuestas**, y después validación inmediata de todo lo verificable. No existe el "no se puede": existe un ángulo que todavía no se probó.
- **`audit adoption`** — se corre después de actualizar el plugin. Actualizar no cambia nada en tus proyectos por sí solo: un proyecto puede estar perfectamente sano y estar desperdiciando una capacidad entera. Este target de `audit` hace la otra pregunta —de lo que el plugin ofrece, qué no está usando este proyecto— y mide el TUYO por efecto, con tus números. Propone; decidís vos.
- **`heavy-runs`** — antes de cualquier cosa que cargue la máquina o se relance: el techo de carga es del CONJUNTO de lo que corre, el paralelismo se deriva de un costo unitario medido, el destino de una corrida es parte de su contrato, y la cadena se lee entera antes del primer lanzamiento.

## Así se ve "afilado"

Después de unas semanas de trabajo real, una auditoría podría encontrar:

- Un CLAUDE.md hinchado con procedimientos pegados → movidos a `docs/`, queda una referencia de path
- Un ROADMAP lleno de ítems terminados con sí → borrados; lo que salió vive en el código y en `ESTADO.md`
- La misma preferencia guardada tres veces con tres redacciones → fusionada en una
- Un token de producción en texto plano → marcado primero, antes que cualquier otra cosa

Todo lo demás se mantiene afilado solo, porque únicamente lo que merece sobrevivir a la sesión llegó a guardarse.

## Números, no promesas

- Validación oficial de plugins: aprobada, cero problemas críticos.
- 65 escenarios de activación en español e inglés, con trampas deliberadas. **Negativos: 29/29 — cero falsos disparos.** Una skill nunca se activa cuando no corresponde.
- El recall positivo es la mitad honesta: 24/36 en una corrida completa, y la varianza entre corridas del modelo de piso supera al efecto de editar una description. Se reporta como dato con su N, no como puntaje.
- **Por eso el método no se apoya en el recall.** Toda regla que debe aplicar *siempre* vive en un hook, medida caso por caso: `delegation` dio 0/4 en sus propias frases, así que el protocolo viaja en el despacho mismo. `seeding-doubts` dio 0/4 —un estancamiento es justo cuando nada se siente como que necesita una skill—, así que un hook a nivel de prompt captura la frase de forma determinista. Las reglas de escritura viajan en cada escritura de markdown.
- **Y los hooks se verificaron por EFECTO, no por si una skill se invocó.** Misma query, mismo modelo, con el plugin y sin él. *"Algo anda mal y no sé qué"* → **con**: dudas numeradas y ordenadas por daño × costo, lo ya publicado primero. **Sin**: "¿qué específicamente no está funcionando?". El protocolo llega y se ejecuta aunque el harness siga reportando 0/4 — porque el harness solo ve invocaciones de skill. Un número que mide el mecanismo equivocado es peor que ningún número, así que ese límite quedó escrito en el runner mismo.
- 102 pruebas de contrato de los hooks en un comando: envoltura de salida por evento, contención del subagente por cada herramienta, el ciclo completo de cierre de turno, drift del inventario, inyección de los protocolos declarados, y dos chequeos de que la doctrina no se duplica a sí misma — una regla que vive en dos archivos es un bug, y los tests lo dicen.
- El bloqueo a los subagentes se apoya en `agent_id`, campo documentado del payload del hook, más una sonda re-corrible de lo que el hook realmente recibe. Su superficie residual —un runner de test permitido ejecuta código del proyecto, y ese código puede escribir— está declarada, no escondida.
- Probado de punta a punta en Windows, el entorno donde todo suele romperse. Construido multiplataforma.
- Este repo funciona con su propio método: root limpio, docs indexadas, su propio ROADMAP.

## Probalo apenas lo instales

Abrí cualquier proyecto y simplemente hablá:

> *"No me gusta que uses tablas tan largas. Para la próxima, listas."*

Claude lo clasifica como preferencia, te propone la memoria exacta y espera tu OK. Desde ese día, todas las sesiones lo saben.

Y mañana:

> *"¿En qué quedamos?"*

## Quién está detrás

**hi-claude** es de [**Hi Agencia**](https://hiagencia.com/?utm_source=github&utm_medium=readme&utm_campaign=hi-claude&utm_content=about_es), una agencia de marketing y automatización que opera todo sobre Claude Code: scrapers, sistemas de clientes, sitios web, cursos, herramientas internas. Este método no salió de una pizarra. Se ganó proyecto a proyecto durante 18 meses, y se empaquetó para que nuestros clientes, y vos, arranquen el día 1 donde nosotros llegamos después de un año y medio.

El logo dice *hi*. El plugin también.

[hiagencia.com](https://hiagencia.com/?utm_source=github&utm_medium=readme&utm_campaign=hi-claude&utm_content=footer_es) · [LinkedIn](https://www.linkedin.com/company/hiagencia/) · [X (@hiagenciacom)](https://x.com/hiagenciacom)

---

<p align="center">Requiere Claude Code ≥ 2.1.143 — el piso lo fija el evento <code>SubagentStart</code>, sobre el que se apoya el rol del subagente; verificado en 2.1.220. Si lo corrés en una versión anterior y funciona, decilo y bajamos el número. · En Windows, instalá <a href="https://git-scm.com/download/win">Git for Windows</a> para que todo funcione · MIT License · © <a href="https://hiagencia.com/?utm_source=github&utm_medium=readme&utm_campaign=hi-claude&utm_content=copyright">Hi Agencia</a></p>
