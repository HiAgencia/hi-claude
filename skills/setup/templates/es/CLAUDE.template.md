<!-- Generado por hi-claude. Las notas en comentarios HTML no consumen contexto de Claude. -->
# {{PROJECT_NAME}}

> **hi-claude gobierna este trabajo** — el formato, la práctica y la retroactividad de cada sesión.
> Sus cinco principios, sus dos ejes (admisión y redacción) y la jerarquía que resuelve conflictos
> entre ellos llegan solos a cada arranque. Ante duda de forma, criterio o alcance, decide hi-claude.

{{PROJECT_DESCRIPTION}}

## Arrancá por acá

1. **`docs/ROADMAP.md`** — lo que falta. Su bloque de trabajo abierto dice en qué se estaba trabajando.
2. **`docs/ESTADO.md`** — lo que ya hay, foto viva.
3. **`docs/INDEX.md`** — todo lo demás: leé el título, abrí solo lo que haga falta.

## Cómo trabajar acá — método hi-claude

Este proyecto se rige por el plugin **hi-claude** (instalado y activo): él inyecta este método en cada sesión y custodia las escrituras a este archivo y a la memoria. Auditorías: `/hi-claude:audit`.

- A este archivo y a la memoria solo entra lo que pasa el eje de **ADMISIÓN**: PREFERENCIAL, LIMITANTE, ATEMPORAL. El trabajo abierto va a `docs/ROADMAP.md`.
- Lo que se escribe pasa además el eje de **REDACCIÓN**: OBJETIVO (el hecho con su evidencia, nunca un juicio) y NO CONDICIONANTE (el estado observado, nunca una puerta cerrada).
- **Consultar SIEMPRE antes** de guardar, modificar o borrar en memoria o en este archivo.
- La documentación **NO vive acá**: va a `docs/` (indexada en `docs/INDEX.md`) y acá solo se referencia el path.
- Un subagente INVESTIGA y **nunca decide qué se hace**. Lo que trae es hipótesis: la lee y resuelve el Claude principal que lo desplegó, verificándola de primera mano.
- Root limpio: nada temporal, de prueba ni obsoleto suelto. Cada cosa en su carpeta.

## Memoria persistente de este proyecto

- Vive en: `{{MEMORY_PATH}}`
- Índice: `MEMORY.md` — se carga al inicio de cada sesión (máx 200 líneas). Las memorias individuales se leen a demanda.
- Tipos: `user` (quién es el usuario) · `feedback` (correcciones y enfoques validados) · `project` (decisiones) · `reference` (sistemas externos).
- Solo entra lo que pasa el eje de ADMISIÓN — siempre con aprobación del usuario.

## Estructura del proyecto

```
{{FOLDER_TREE}}
```

<!-- Mantené este árbol al día. El auditor de organización compara la estructura real contra esta declaración. -->

## Gotchas — lo que el árbol NO dice

<!-- Acá van los tokens que valen: lo que muerde y no se deduce mirando el repo.
     Nada de lo que se ve solo con listar archivos o leer un nombre de módulo. -->

*(todavía no hay — se agregan cuando aparezca el primer mordisco)*

## Documentación

Toda la documentación está indexada en **`docs/INDEX.md`** — empezá por ahí: leé el título y abrí solo lo que haga falta.

Documentos clave (solo atemporales — título descriptivo + path):
{{KEY_DOCS}}

<!-- Los planes y estados viven en docs/INDEX.md, no acá. Solo lo atemporal gana una referencia en este archivo. -->

## Herramientas de este proyecto

| Herramienta | Tipo | Cuándo usarla acá |
|---|---|---|
{{TOOLS_TABLE}}

<!-- Esta tabla existe para que Claude USE estas herramientas proactivamente. Actualizala si conectás o desconectás algo. -->

## Reglas del usuario — NO NEGOCIABLES

{{USER_RULES}}

## Proactividad

- Usá las herramientas de la tabla sin que te lo pidan, cuando correspondan.
- Consultá la memoria persistente aunque creas recordar las preferencias.
- Mantené `docs/ROADMAP.md` al día mientras trabajás — es lo que sobrevive a una compactación.
- Si el usuario corrige, confirma un enfoque o declara una preferencia → proponé guardarla (protocolo hi-claude).
- Tras cambios grandes, podés sugerir `/hi-claude:audit`.
