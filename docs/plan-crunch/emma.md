# Emma Wescott S.: la carta, el equipo, Colección e Inicio

**Eres dueña de:** `widgets/countries.dart`, `court_lines.dart`, `player_figure.dart`, `player_card.dart` y `team_slot.dart`, además de `team_page.dart`, `detail_page.dart`, `collection_page.dart` y `home_page.dart`. También te toca la revisión visual contra el mockup.
**Tiempo estimado:** unas 12 h en total (~3 h por día).
**Mockup:** carpeta `Mockup móvil Court Cards/` del repo ([Figma](https://www.figma.com/make/SEwu72mlae6A5WAg1IJRJf/Mockup-m%C3%B3vil-Court-Cards?t=U8rvKbDcwpXIoU8D-20&fullscreen=1)).

No edites `app_controller.dart` ni `domain/`. Si necesitas un dato o un método nuevo, pídeselo a Sebastián por chat.

**El código de cada día está en tu guía:** [Día 1](../guias/emma/dia1.md) · [Día 2](../guias/emma/dia2.md) · [Día 3](../guias/emma/dia3.md) · [Día 4](../guias/emma/dia4.md).

---

## Martes 20 (noche, ~30 min)

- [ ] `flutter doctor`: que al menos Flutter y algún dispositivo (Linux, Windows, emulador o teléfono) estén en ✓.
- [ ] Tener `git` y `gh` listos. El miércoles en la mañana clonas el proyecto nuevo apenas Sebastián avise.

## Miércoles 21: la carta del tenista ([guía](../guias/emma/dia1.md))

- [ ] Mañana: países, líneas de cancha (📣 avisa a Miguel) y la ilustración del tenista.
- [ ] Tarde (con la base de Sebastián en `main`): `PlayerCard` y revisión con `lib/muestra.dart`.
- **Cierre:** PR con los 4 archivos.

## Jueves 22: equipo y Detalle ([guía](../guias/emma/dia2.md))

- [ ] PR con `team_slot.dart` y `team_page.dart` (Sebastián los usa en Jugar el viernes). Elegir equipo necesita `navigation.dart` de Sebastián (10:00).
- [ ] Detalle de carta, en un segundo PR.
- **Cierre:** Elegir equipo y Detalle funcionan en `lib/muestra.dart`.

## Viernes 23: Colección e Inicio ([guía](../guias/emma/dia3.md))

- [ ] Colección con buscador, filtro de duplicadas y grilla.
- [ ] Inicio del mockup, que reemplaza el provisional (necesita el Perfil de Miguel, ~12:00).
- **Cierre:** toda la app con el diseño nuevo; no quedan pestañas «En construcción».

## Sábado 24: QA visual ([guía](../guias/emma/dia4.md))

- [ ] Revisar pantalla por pantalla contra el mockup en ancho de teléfono; anotar en `docs/evidencia/qa-visual.md`.
- [ ] Capturas en `docs/evidencia/capturas/` (automáticas con la prueba de capturas, más 3 del teléfono real).
- [ ] Correcciones pequeñas **antes de las 18:00**. A las 21:00, ensayo general.

## Domingo 25

- [ ] Ensayar tu explicación de 2 min: `PlayerCard` y sus tamaños, cómo una pantalla secundaria se redibuja (`openPage` + `ListenableBuilder`), los estados vacíos y las diferencias declaradas con el mockup.
- [ ] Poder hacer la demo de Colección → equipo → partida **sin ayuda**.
