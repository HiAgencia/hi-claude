<!-- Generado por hi-claude. Las notas en comentarios HTML no consumen contexto de Claude. -->
# {{PROJECT_NAME}}

{{PROJECT_DESCRIPTION}}

## Cómo trabajar acá — método hi-claude

Este proyecto se rige por el plugin **hi-claude** (instalado y activo): él inyecta este método en cada sesión y custodia las escrituras a este archivo y a la memoria. Auditorías: `/hi-claude:audit`.

- A este archivo y a la memoria solo entra lo **ATEMPORAL, PREFERENCIAL o LIMITANTE**. Nada de estado, avances ni pendientes con fecha.
- **Consultar SIEMPRE antes** de guardar, modificar o borrar en memoria o en este archivo.
- La documentación **NO vive acá**: va a `docs/` (indexada en `docs/INDEX.md`) y acá solo se referencia el path.
- Root limpio: nada temporal, de prueba ni obsoleto suelto. Cada cosa en su carpeta.

## Memoria persistente de este proyecto

- Vive en: `{{MEMORY_PATH}}`
- Índice: `MEMORY.md` — se carga al inicio de cada sesión (máx 200 líneas). Las memorias individuales se leen a demanda.
- Tipos: `user` (quién es el usuario) · `feedback` (correcciones y enfoques validados) · `project` (decisiones) · `reference` (sistemas externos).
- Solo entra lo ATEMPORAL, PREFERENCIAL o LIMITANTE — siempre con aprobación del usuario.

## Estructura del proyecto

```
{{FOLDER_TREE}}
```

<!-- Mantené este árbol al día. El auditor de organización compara la estructura real contra esta declaración. -->

## Documentación

Toda la documentación está indexada en **`docs/INDEX.md`** — empezá por ahí.

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
- Si el usuario corrige, confirma un enfoque o declara una preferencia → proponé guardarla (protocolo hi-claude).
- Tras cambios grandes, podés sugerir `/hi-claude:audit`.
