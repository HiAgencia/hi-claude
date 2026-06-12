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
  <em>Lo primero que deberías decirle a Claude en cada proyecto nuevo.</em>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Claude_Code-%E2%89%A5_2.1.59-d97757?logo=anthropic&logoColor=white" alt="Claude Code">
  <img src="https://img.shields.io/badge/version-1.0.0-4c8cff" alt="Version">
  <img src="https://img.shields.io/badge/license-MIT-green" alt="License">
  <img src="https://img.shields.io/badge/trigger_evals-97.4%25-2ea44f" alt="Trigger evals">
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

Claude Code already remembers. The problem is **what** it remembers, and what your `CLAUDE.md` looks like after three months: stale notes, documentation pasted inline, dead paths, secrets in plain text, rules that contradict each other. Power users slowly build a discipline to keep it sharp. Everyone else inherits chaos.

hi-claude packages that discipline, sharpened over 18 months of running real client systems on Claude Code, into a method anyone can install. Even someone who opened a terminal for the first time today.

## Install (2 commands, inside Claude Code)

```
/plugin marketplace add HiAgencia/hi-claude
/plugin install hi-claude@hi-claude
```

Restart the session (or run `/reload-plugins`). There is no step 3.

## What you get

| Moment | What hi-claude does |
|---|---|
| **Day 1** | `/hi-claude:setup` interviews you in plain language and generates your CLAUDE.md, your docs structure, and your initial memory. With your approval, always. |
| **Every day** | Claude proposes remembering only what is worth keeping: timeless rules, your preferences, your limits. It never touches memory or CLAUDE.md without asking first. |
| **Maintenance** | `/hi-claude:audit` grades your CLAUDE.md, your memory, and your folder organization from A to F, shows findings with `file:line` evidence, and fixes only what you approve. |

## How it works

| Layer | What it guarantees |
|---|---|
| **The Constitution** | The method is present in every session, from the first second. Claude never forgets who it is, no matter how long you work. |
| **The Guardian** | Nothing gets written to CLAUDE.md or persistent memory without your explicit confirmation. Enforced by code, not by trust. |
| **The memory protocol** | Kicks in on its own when you correct something, confirm an approach, or state a preference ("I don't like...", "from now on...", "recordá que..."). It proposes what to remember; you decide. |
| **Three auditors** | Read-only reviewers for CLAUDE.md, memory, and organization. Every finding cites its evidence, two findings per category at most, and inventing problems is off the table. Secrets in plain text mean an automatic F. |

## The admission rule

> Only three kinds of knowledge deserve to outlive the session:
>
> **TIMELESS**, true today and in five months. **PREFERENTIAL**, you said you like it that way. **LIMITING**, a boundary you set.
>
> Everything else: ephemeral state dies with the session, and documentation goes to `docs/`. CLAUDE.md keeps the path, never the content.

That one rule is the reason hi-claude projects stay sharp while others drown in their own notes.

## Numbers, not promises

- Official plugin validation: passed, zero critical issues.
- 38 trigger scenarios tested in English and Spanish, including deliberately tricky ones: 100% precision, zero false triggers, 97.4% overall.
- Tested end to end on Windows, the environment where things usually break. Built cross-platform.
- This repo runs on its own method: clean root, indexed docs, brand assets where they belong.

## Try this after installing

Open any project and just talk:

> *"No me gusta que uses tablas tan largas. Para la próxima, listas."*

Claude classifies it as a preference, proposes the exact memory entry, and waits for your OK. From that day on, every session knows.

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

Claude Code ya tiene memoria. El problema es **qué** recuerda, y en qué se convierte tu `CLAUDE.md` después de tres meses: notas viejas, documentación pegada adentro, paths muertos, secretos en texto plano, reglas que se contradicen. Los usuarios avanzados van armando una disciplina para mantenerlo afilado. El resto hereda el caos.

hi-claude empaqueta esa disciplina, pulida durante 18 meses operando sistemas reales de clientes sobre Claude Code, en un método que cualquiera puede instalar. Incluso alguien que abrió una terminal por primera vez hoy.

## Instalación (2 comandos, dentro de Claude Code)

```
/plugin marketplace add HiAgencia/hi-claude
/plugin install hi-claude@hi-claude
```

Reiniciá la sesión (o corré `/reload-plugins`). No hay paso 3.

## Qué incluye

| Momento | Qué hace hi-claude |
|---|---|
| **Día 1** | `/hi-claude:setup` te entrevista en lenguaje simple y genera tu CLAUDE.md, tu estructura de docs y tu memoria inicial. Siempre con tu aprobación. |
| **Todos los días** | Claude propone recordar solo lo que vale la pena: reglas atemporales, tus preferencias, tus límites. Y nunca toca la memoria ni el CLAUDE.md sin consultarte antes. |
| **Mantenimiento** | `/hi-claude:audit` califica tu CLAUDE.md, tu memoria y tu organización de la A a la F, muestra hallazgos con evidencia `archivo:línea`, y corrige solo lo que apruebes. |

## Cómo funciona

| Capa | Qué garantiza |
|---|---|
| **La Constitución** | El método está presente en cada sesión, desde el primer segundo. Claude no olvida quién es, por más largo que sea el trabajo. |
| **El Guardián** | Nada se escribe en el CLAUDE.md ni en la memoria sin tu confirmación explícita. Garantizado por código, no por confianza. |
| **El protocolo de memoria** | Se activa solo cuando corregís algo, confirmás un enfoque o declarás una preferencia ("no me gusta...", "de ahora en más...", "recordá que..."). Propone qué recordar; vos decidís. |
| **Tres auditores** | Revisores de solo lectura para CLAUDE.md, memoria y organización. Cada hallazgo cita su evidencia, máximo dos por categoría, y tienen prohibido inventar problemas. Secretos en texto plano: F automática. |

## La regla de admisión

> Solo tres tipos de conocimiento merecen sobrevivir a la sesión:
>
> **ATEMPORAL**, vale hoy y en cinco meses. **PREFERENCIAL**, dijiste que te gusta así. **LIMITANTE**, un límite que pusiste vos.
>
> Todo lo demás: el estado efímero muere con la sesión, y la documentación va a `docs/`. El CLAUDE.md guarda el path, nunca el contenido.

Esa única regla es la razón por la que los proyectos hi-claude se mantienen afilados mientras otros se ahogan en sus propias notas.

## Números, no promesas

- Validación oficial de plugins: aprobada, cero problemas críticos.
- 38 escenarios de activación probados en español e inglés, incluyendo trampas deliberadas: 100% de precisión, cero falsos disparos, 97.4% global.
- Probado de punta a punta en Windows, el entorno donde todo suele romperse. Construido multiplataforma.
- Este repo funciona con su propio método: root limpio, docs indexadas, los assets de marca donde corresponden.

## Probalo apenas lo instales

Abrí cualquier proyecto y simplemente hablá:

> *"No me gusta que uses tablas tan largas. Para la próxima, listas."*

Claude lo clasifica como preferencia, te propone la memoria exacta y espera tu OK. Desde ese día, todas las sesiones lo saben.

## Quién está detrás

**hi-claude** es de [**Hi Agencia**](https://hiagencia.com/?utm_source=github&utm_medium=readme&utm_campaign=hi-claude&utm_content=about_es), una agencia de marketing y automatización que opera todo sobre Claude Code: scrapers, sistemas de clientes, sitios web, cursos, herramientas internas. Este método no salió de una pizarra. Se ganó proyecto a proyecto durante 18 meses, y se empaquetó para que nuestros clientes, y vos, arranquen el día 1 donde nosotros llegamos después de un año y medio.

El logo dice *hi*. El plugin también.

[hiagencia.com](https://hiagencia.com/?utm_source=github&utm_medium=readme&utm_campaign=hi-claude&utm_content=footer_es) · [LinkedIn](https://www.linkedin.com/company/hiagencia/) · [X (@hiagenciacom)](https://x.com/hiagenciacom)

---

<p align="center">Requiere Claude Code ≥ 2.1.59 · En Windows, instalá <a href="https://git-scm.com/download/win">Git for Windows</a> para que todo funcione · MIT License · © <a href="https://hiagencia.com/?utm_source=github&utm_medium=readme&utm_campaign=hi-claude&utm_content=copyright">Hi Agencia</a></p>
