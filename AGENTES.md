# Flujo de agentes para cambios en AgroCampo

Este archivo define un flujo simple para tomar una solicitud del usuario, entender exactamente qué pestaña/elemento/requerimiento afecta, aplicar el cambio y revisar si corresponde con lo pedido.

wowo

## 1. Agente Analista de Tarea

Objetivo: leer la solicitud y convertirla en una instrucción clara antes de editar.

Debe identificar:

- Pestaña afectada: Inicio, Sectores, Mapa, Registrar, Suelo, Riego, IA, Historial, Más, Perfil u otra.
- Elemento afectado: header, footer, tarjeta, botón, icono, formulario, mapa, cuadrante, historial, etc.
- Requerimiento a cambiar: qué texto, comportamiento, estilo o flujo debe modificarse.
- Alcance: si el cambio aplica solo a una pantalla o se repite en varias.
- Restricciones: qué no se debe tocar.

Salida esperada:

```txt
Pestaña: ...
Elemento: ...
Cambio requerido: ...
No tocar: ...
Validación esperada: ...
```

Reglas:

- No inventar funcionalidades nuevas.
- Si el usuario pide sacar un texto, buscar si aparece repetido.
- Si el usuario pide cambiar un estilo, revisar si el mismo componente se usa en más de una pantalla.
- Si hay ambigüedad, elegir la interpretación más acotada y dejarla explícita.

## 2. Agente Editor

Objetivo: aplicar el cambio en el prototipo.

Debe:

- Editar solo los archivos necesarios.
- Mantener HTML, CSS y JavaScript simples.
- Reutilizar componentes existentes cuando corresponda.
- Mantener la navegación por hash.
- Mantener el estado mock coherente.
- No agregar backend, APIs reales ni frameworks.

Checklist antes de editar:

- Confirmar qué función genera la pantalla afectada.
- Confirmar qué clase CSS controla el elemento visual.
- Confirmar si hay pruebas de aceptación relacionadas.

Checklist después de editar:

- El cambio se ve reflejado en la pantalla correcta.
- El texto solicitado fue agregado, cambiado o eliminado.
- La navegación sigue funcionando.
- Los botones siguen teniendo `data-route` o handler equivalente.
- Los iconos siguen usando el sistema existente.

## 3. Agente Revisor / Asegurador

Objetivo: revisar que el cambio corresponda exactamente con lo pedido.

Debe comparar:

- Solicitud original del usuario.
- Pestaña realmente modificada.
- Elemento realmente modificado.
- Resultado visible esperado.
- Posibles efectos colaterales.

Debe verificar:

- Que no se agregó contenido no pedido.
- Que no se eliminó contenido necesario.
- Que no reaparecen palabras o textos que el usuario pidió sacar.
- Que el flujo táctil sigue siendo usable en móvil.
- Que el JavaScript embebido no tiene errores de sintaxis.
- Que la prueba de aceptación pasa.

Comandos mínimos de verificación:

```bash
node -e "const fs=require('fs'); const html=fs.readFileSync('agrocampo-highfi.html','utf8'); const scripts=[...html.matchAll(/<script>([\\s\\S]*?)<\\/script>/g)].map(m=>m[1]); for (const script of scripts) new Function(script); console.log('Embedded JavaScript syntax OK:', scripts.length);"
node agrocampo-acceptance.test.js
```

Salida esperada:

```txt
Revisión:
- Pestaña modificada: ...
- Elemento modificado: ...
- Coincide con lo pedido: Sí/No
- Riesgos o pendientes: ...
- Verificación: ...
```

## Orden obligatorio

1. Analista de Tarea entiende la solicitud.
2. Editor aplica el cambio.
3. Revisor / Asegurador comprueba el resultado.

No se debe cerrar una tarea como terminada sin la revisión final.
