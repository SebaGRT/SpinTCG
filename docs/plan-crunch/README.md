# Plan crunch SpinTCG: martes 20 al domingo 25 de octubre de 2026

El cronograma original tenía cuatro semanas (12 oct – 8 nov). Lo comprimimos en **seis días** y entregamos el **domingo 25**.

Archivos por integrante: [Sebastián](sebastian.md) · [Emma](emma.md) · [Miguel](miguel.md). La plantilla de evidencia está en [`../evidencia/`](../evidencia/README.md).

**El código a escribir día por día está en las [guías de código](../guias/README.md)**, con el diseño del mockup *Court Cards*. Este archivo y los de cada integrante cubren lo que no es código: API, Android, pruebas manuales, evidencia y entrega.

## Estrategia

1. **Partimos de cero** (`flutter create`) y escribimos todo a mano, siguiendo las [guías de código](../guias/README.md). El respaldo del kit (`plan-desarrollo/codigo-emergencia/`) queda solo como consulta: funciona (verificado el 20 de octubre con Flutter 3.47.6), pero no es trabajo nuestro.
2. **Cada integrante escribe a mano su parte del diseño nuevo** siguiendo las [guías de código](../guias/README.md), la entiende línea por línea y deja evidencia propia. El kit lo dice explícitamente: el código preparado no cuenta como trabajo del estudiante, así que lo que se evalúa son sus cambios, sus pruebas y su explicación.
3. **Lo que de verdad falta** y define el resultado:
   - Consumo **real** de RapidAPI. Nunca se ha probado con la cuenta, y el parser está escrito a partir de la documentación.
   - Prueba en un **teléfono o emulador Android**: la APK nunca se instaló.
   - El **diseño del mockup**: la interfaz actual es genérica. Las [guías](../guias/README.md) traen cada pantalla del mockup, repartidas entre los tres.

## Calendario

| Día | Sebastián | Emma | Miguel | Cierre del día |
|---|---|---|---|---|
| **Mar 20** (noche) | Repositorio y GitHub; suscripción RapidAPI; confirmar el formato con el curso | Instalar Flutter | Instalar Flutter y leer las reglas | Los tres clonaron el repo |
| **Mié 21** | [Proyecto desde cero](../guias/sebastian/dia1.md): `flutter create` (~10:00), base visual (**13:00**) y núcleo (catálogo, reglas, almacenamiento, controlador) | [La carta del tenista](../guias/emma/dia1.md) | [Errores, widgets comunes, volteo y reverso](../guias/miguel/dia1.md); escenarios de prueba | Proyecto, base y núcleo en `main`; la carta y los widgets comunes en PR |
| **Jue 22** | [Navegación (**10:00**), cáscara, primera prueba, servidor y API real](../guias/sebastian/dia2.md) | [Equipo, Elegir equipo y Detalle](../guias/emma/dia2.md) | [Sobre, Sobres y revelación](../guias/miguel/dia2.md) | La app arranca con la barra del mockup; Sobres funciona; el servidor responde |
| **Vie 23** | [Partida (**12:00**), Jugar, Android](../guias/sebastian/dia3.md); **plan B a las 14:00** | [Colección e Inicio](../guias/emma/dia3.md) | [Perfil (**12:00**) y Resultado](../guias/miguel/dia3.md) | Toda la app con el diseño nuevo, en Android |
| **Sáb 24** | [Prueba de interfaz, APK, README](../guias/sebastian/dia4.md); **congelamiento a las 18:00** | [QA visual y capturas](../guias/emma/dia4.md) | [Pruebas propias, escenarios y evidencia](../guias/miguel/dia4.md) | **Ensayo general a las 21:00** |
| **Dom 25** | Instalar en el dispositivo de la presentación; tag `v1.0`; entregar | Ensayar su parte | Ensayar su parte | Entregado |

El domingo es día de reserva: solo se corrigen errores que bloqueen la entrega, sin funcionalidades nuevas.

## Reglas del crunch

1. **Check-in diario a las 21:00** (10 min por chat o llamada): qué hice, qué sigue, qué me bloquea.
2. **Ramas cortas** con el formato `nombre/diaN-tema`, por ejemplo `emma/dia2-cardtile`. Hacer push antes de las 22:00; Sebastián integra antes de las 23:30 o a las 9:00 del día siguiente.
3. **Solo Sebastián edita** `lib/application/app_controller.dart`, `lib/domain/` y `servidor_api/`. Si necesitas un cambio ahí, pídelo por chat indicando el método y lo que debería hacer.
4. **Cada archivo tiene un dueño** (tabla en el [índice de guías](../guias/README.md#quién-es-dueño-de-cada-archivo)). `player_card.dart` (Emma) y `common.dart` (Miguel) los usan todos: si cambian sus parámetros, se avisa en el chat.
5. **Desde el sábado existe `test/ui_flow_test.dart`**, que busca textos exactos. Desde ese momento, si cambias un texto visible, revisa la prueba en el mismo PR.
6. **Antes de cada push**, desde `app_flutter/`: `dart format lib test && flutter analyze && flutter test` (hasta el jueves no hay pruebas: basta `flutter analyze`). Si tocaste el servidor, ejecuta también `node --test adapter.test.mjs` desde `servidor_api/`.
7. **La clave de RapidAPI nunca va en el repositorio ni en Dart.** Antes de entregar, ejecutar `git grep -n -i "x-rapidapi-key:"` y revisar que los fixtures no tengan encabezados.
8. **Sin funcionalidades fuera de la propuesta:** nada de intercambios, multijugador, cuentas, monedas ni torneos.

## Qué se recorta si vamos atrasados (en este orden)

1. Animaciones (volteo de cartas): `FlipCard` puede mostrar el frente directamente.
2. Fidelidad al mockup en pantallas secundarias (Perfil y Resultado).
3. Detalles de dibujo (ilustración del tenista, sobre): basta con un color plano.
4. **Nunca se recorta:** el flujo completo, la persistencia, las pruebas en verde y la API real verificada, o bien su limitación declarada por escrito.

## Plan B de la API (decisión el viernes 23 a las 14:00)

Si a esa hora `/catalog` no entrega al menos 6 cartas reales, presentamos en **modo demo**. La limitación se declara en el README y en la presentación, y mostramos como evidencia las respuestas reales que sí obtuvimos (`servidor_api/fixtures/`). **Nunca presentar el modo demo como datos reales.**

## Riesgos conocidos

| Riesgo | Mitigación |
|---|---|
| Cuota del plan de RapidAPI | El plan FREE da **50 consultas por día** (4 por segundo). Una actualización completa son 25, y el servidor limita a 40 por día. Las pruebas con `curl` también gastan cuota: para desarrollar, bajar `count`. |
| El esquema real no coincide con `adapter.mjs` | Revisado contra la documentación ([`../api-tennis.md`](../api-tennis.md)): `total` es texto `"W-L"` y los títulos salen de `totalTitlesWon`. Se confirma con los fixtures reales. |
| HTTP solo funciona en debug | Para la presentación, usar `adb reverse tcp:8787 tcp:8787`. Después de la primera carga, el catálogo queda guardado en el teléfono y funciona sin el servidor. |
| `adb` no está en el PATH del PC de Sebastián | Está en `~/Android/Sdk/platform-tools/`. En fish: `fish_add_path ~/Android/Sdk/platform-tools`. Ya existe el emulador `Medium_Phone_API_37.0`. |
| Diferencias con el mockup | Ya resueltas en la referencia; las que quedan están declaradas en el [índice de guías](../guias/README.md#qué-cambia-respecto-del-mockup). |
| Mensajes de error crudos (`Bad state: …`, `Invalid argument(s): …`) | `mensajeDeError()` de Miguel (miércoles), usado en todas las pantallas nuevas. |

## Por confirmar hoy con el curso

- ¿El domingo es una **entrega** (repositorio, APK o zip) o una **presentación en vivo**? ¿Lleva diapositivas o video?
- ¿Se **exige** el consumo real de la API o basta con declarar la limitación?

## Cómo pedir ayuda paso a paso

Abrir Claude Code en esta carpeta y escribir, por ejemplo: *"Soy Emma, voy en el día 2, paso 2 (Elegir equipo) y `flutter analyze` me marca este error"*. Claude lee tu guía y te ayuda. La idea es que escribas y entiendas el código tú, no que lo pegues.
