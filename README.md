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
  <img src="https://img.shields.io/badge/Claude_Code-%E2%89%A5_2.1.59-d97757?logo=anthropic&logoColor=white" alt="Claude Code">
  <img src="https://img.shields.io/badge/version-2.0.0-4c8cff" alt="Version">
  <img src="https://img.shields.io/badge/license-MIT-green" alt="License">
  <img src="https://img.shields.io/badge/trigger_evals-{{EVAL_BADGE}}-2ea44f" alt="Trigger evals">
  <img src="https://img.shields.io/badge/dependencies-zero-2ea44f" alt="Zero dependencies">
  <img src="https://img.shields.io/badge/EN_·_ES-bilingual-8a2be2" alt="Bilingual">
</p>

<p align="center">
  <a href="https://hiagencia.com/?utm_source=github&utm_medium=readme&utm_campaign=hi-claude&utm_content=hero_nav">hiagencia.com</a> ·
  <a href="https://www.linkedin.com/company/hiagencia/">LinkedIn</a> ·
  <a href="https://x.com/hiagenciacom">X (@hiagenciacom)</a> ·
  <a href="#hi-claude-español">🇪🇸 Versión en español ↓</a>
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
| **Maintenance** | `/hi-claude:audit` grades your CLAUDE.md, your memory, your roadmap and your folder organization from A to F, shows findings with `file:line` evidence, and fixes only what you approve. |

## How it works

| Layer | What it guarantees |
|---|---|
| **The Constitution** | Three invariants — admission, consultation, trace — present from the first second of every session, including resumed and forked ones. Nothing else is loaded upfront; the rest opens when the task asks for it. |
| **The ROADMAP** | One file holds what is missing. Its open-work block is injected at every session start, so *"where did we leave off"* has an answer that survives a compaction, a `--resume`, and a week off. When an item is finished it is **deleted**, not ticked — that is why the file stays short. |
| **The Guardian** | Nothing gets written to CLAUDE.md or persistent memory without your explicit confirmation. Enforced by code, not by trust — including writes attempted through the shell. |
| **The subagent's role** | A subagent **investigates; it does not implement.** It is told so on spawn, and a hook denies its write attempts. What it brings back is a hypothesis until the main agent verifies it first-hand. |
| **The memory protocol** | Kicks in on its own when you correct something, confirm an approach, or state a preference ("I don't like...", "from now on...", "recordá que..."). It proposes what to remember; you decide. |
| **Four auditors** | Read-only reviewers for CLAUDE.md, memory, ROADMAP, and organization. Every finding cites its evidence, two findings per category at most, and inventing problems is off the table. Secrets in plain text mean an automatic F. |

## The admission rule

> Only three kinds of knowledge deserve to outlive the session:
>
> **TIMELESS**, true today and in five months. **PREFERENTIAL**, you said you like it that way. **LIMITING**, a boundary you set.
>
> Everything else has a home that is not memory: documentation goes to `docs/`, open work goes to `ROADMAP.md`, and CLAUDE.md keeps the path.

That one rule is the reason hi-claude projects stay sharp while others drown in their own notes.

## The working method

Three skills carry the parts of the craft that are not memory. They load when the moment calls for them, not before.

- **`roadmap`** — how work is taken, split, paused and closed. Every item declares what still blocks it: nothing, the real world, a window, your GO, or a dedicated measurement. Its "done" criterion is something you can *run*, not a sentence two sessions will read differently.
- **`work-protocol`** — how it gets written down. No verdicts written as final, no "for now", no documentation that turns into a diary. A measured result is a datum with its N, reopenable. And every problem closed leaves the system easier to operate than it was: a log that names the cause instead of a generic one, a repair path, a preview flag.
- **`seeding-doubts`** — for when quality stalls and nothing looks obviously wrong. Introspection, then three subagents with deliberately different tones whose deliverable is **more doubts, never answers**, then immediate verification of everything checkable. There is no "it can't be done" — there is an angle not tried yet.

## What sharp looks like

After a few weeks of real work, an audit might find:

- A CLAUDE.md bloated with pasted procedures → moved to `docs/`, one path reference left behind
- A ROADMAP full of finished items marked ✅ → deleted; what shipped lives in the code and in `STATE.md`
- The same preference saved three times in three wordings → merged into one
- A production token sitting in plain text → flagged first, before anything else

Everything else stays sharp on its own, because only what deserves to survive the session ever got saved.

## Numbers, not promises

- Official plugin validation: passed, zero critical issues.
- {{EVAL_LINE_EN}}
- A hook contract test bench that runs in one command, including two checks that the doctrine itself is not duplicated: a rule that lives in two files is a bug, and the tests say so.
- The subagent write-block is not a hope: it rests on a measurement of what the hook actually receives, re-runnable when Claude Code changes.
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

<h1 align="center" id="hi-claude-español">hi-claude 🇪🇸</h1>

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
| **Mantenimiento** | `/hi-claude:audit` califica tu CLAUDE.md, tu memoria, tu roadmap y tu organización de la A a la F, muestra hallazgos con evidencia `archivo:línea`, y corrige solo lo que apruebes. |

## Cómo funciona

| Capa | Qué garantiza |
|---|---|
| **La Constitución** | Tres invariantes —admisión, consulta, rastro— presentes desde el primer segundo de cada sesión, incluidas las reanudadas y las forkeadas. Nada más se carga de entrada; el resto se abre cuando la tarea lo pide. |
| **El ROADMAP** | Un archivo con lo que falta. Su bloque de trabajo abierto se inyecta en cada arranque, así que *"en qué quedamos"* tiene respuesta después de una compactación, de un `--resume` y de una semana sin tocar el proyecto. Cuando un ítem termina se **borra**, no se tilda — por eso el archivo no crece. |
| **El Guardián** | Nada se escribe en el CLAUDE.md ni en la memoria sin tu confirmación explícita. Garantizado por código, no por confianza — incluidas las escrituras que intentan pasar por la terminal. |
| **El rol del subagente** | Un subagente **investiga; no implementa.** Se lo declara al momento de nacer, y un hook le bloquea los intentos de escritura. Lo que trae es una hipótesis hasta que el agente principal la verifica de primera mano. |
| **El protocolo de memoria** | Se activa solo cuando corregís algo, confirmás un enfoque o declarás una preferencia ("no me gusta...", "de ahora en más...", "recordá que..."). Propone qué recordar; vos decidís. |
| **Cuatro auditores** | Revisores de solo lectura para CLAUDE.md, memoria, ROADMAP y organización. Cada hallazgo cita su evidencia, máximo dos por categoría, y tienen prohibido inventar problemas. Secretos en texto plano: F automática. |

## La regla de admisión

> Solo tres tipos de conocimiento merecen sobrevivir a la sesión:
>
> **ATEMPORAL**, vale hoy y en cinco meses. **PREFERENCIAL**, dijiste que te gusta así. **LIMITANTE**, un límite que pusiste vos.
>
> Todo lo demás tiene una casa que no es la memoria: la documentación va a `docs/`, el trabajo abierto va al `ROADMAP.md`, y el CLAUDE.md se queda con el path.

Esa única regla es la razón por la que los proyectos hi-claude se mantienen afilados mientras otros se ahogan en sus propias notas.

## El método de trabajo

Tres skills cargan las partes del oficio que no son memoria. Se abren cuando el momento las pide, no antes.

- **`roadmap`** — cómo se toma, se parte, se pausa y se cierra un trabajo. Cada ítem declara qué le falta además del trabajo: nada, el mundo real, una ventana, tu GO, o una medición dedicada. Su criterio de "hecho" es algo que se *corre*, no una frase que dos sesiones leen distinto.
- **`work-protocol`** — cómo se deja escrito. Nada de veredictos escritos como finales, nada de "por ahora", nada de documentación que se convierte en diario. Un resultado medido es un dato con su N, reabrible. Y cada problema que se cierra deja el sistema más fácil de operar: un log que nombra la causa en vez de uno genérico, un camino de reparación, un flag de previsualización.
- **`seeding-doubts`** — para cuando la calidad se estanca y nada parece estar mal. Introspección, después tres subagentes con tonos deliberadamente distintos cuyo entregable son **más dudas, nunca respuestas**, y después validación inmediata de todo lo verificable. No existe el "no se puede": existe un ángulo que todavía no se probó.

## Así se ve "afilado"

Después de unas semanas de trabajo real, una auditoría podría encontrar:

- Un CLAUDE.md hinchado con procedimientos pegados → movidos a `docs/`, queda una referencia de path
- Un ROADMAP lleno de ítems terminados con ✅ → borrados; lo que salió vive en el código y en `ESTADO.md`
- La misma preferencia guardada tres veces con tres redacciones → fusionada en una
- Un token de producción en texto plano → marcado primero, antes que cualquier otra cosa

Todo lo demás se mantiene afilado solo, porque únicamente lo que merece sobrevivir a la sesión llegó a guardarse.

## Números, no promesas

- Validación oficial de plugins: aprobada, cero problemas críticos.
- {{EVAL_LINE_ES}}
- Un banco de pruebas de contrato de los hooks que corre con un comando, con dos chequeos de que la doctrina no se duplica a sí misma: una regla que vive en dos archivos es un bug, y los tests lo dicen.
- El bloqueo de escritura a los subagentes no es una esperanza: se apoya en una medición de lo que el hook realmente recibe, re-corrible cuando Claude Code cambie.
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

<p align="center">Requiere Claude Code ≥ 2.1.59 · En Windows, instalá <a href="https://git-scm.com/download/win">Git for Windows</a> para que todo funcione · MIT License · © <a href="https://hiagencia.com/?utm_source=github&utm_medium=readme&utm_campaign=hi-claude&utm_content=copyright">Hi Agencia</a></p>
