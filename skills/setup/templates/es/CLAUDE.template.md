<!-- Generado por hi-claude. Las notas en comentarios HTML no consumen contexto de Claude.
     El método NO se repite acá: sus principios viven en el CLAUDE.md global del usuario y el resto
     llega por el plugin cuando aplica. Este archivo lleva solo lo que es de ESTE proyecto. -->
# {{PROJECT_NAME}}

{{PROJECT_DESCRIPTION}}

## Arrancá por acá

1. **`docs/ROADMAP.md`** — lo que falta. Su bloque de trabajo abierto dice en qué se estaba trabajando.
2. **`docs/ESTADO.md`** — lo que ya hay, foto viva.
3. **`docs/INDEX.md`** — todo lo demás: leé el título, abrí solo lo que haga falta.

## Estructura del proyecto

```
{{FOLDER_TREE}}
```

Root limpio: nada temporal, de prueba ni obsoleto suelto. Cada cosa en su carpeta.

<!-- Mantené este árbol al día. El auditor de organización compara la estructura real contra esta declaración. -->

## Gotchas — lo que el árbol NO dice

<!-- Acá van los tokens que valen: lo que muerde y no se deduce mirando el repo.
     Nada de lo que se ve solo con listar archivos o leer un nombre de módulo. Va la regla y su porqué:
     las cifras y el caso que la originó van a docs/, y acá queda el path. -->

*(todavía no hay — se agregan cuando aparezca el primer mordisco)*

## Documentación

Documentos clave (solo atemporales — título descriptivo + path, y PARA QUÉ se abre cada uno):
{{KEY_DOCS}}

<!-- Los planes y estados viven en docs/INDEX.md, no acá. Solo lo atemporal gana una referencia en este archivo. -->

## Herramientas de este proyecto

| Herramienta | Tipo | Cuándo usarla acá |
|---|---|---|
{{TOOLS_TABLE}}

<!-- Esta tabla existe para que Claude USE estas herramientas sin que se lo pidan. Actualizala si conectás o desconectás algo. -->

## Reglas del usuario — NO NEGOCIABLES

{{USER_RULES}}
