# Miguel Figueroa G.: sobres, resultado, perfil y validación

**Eres dueño de:** `errores.dart`, `widgets/common.dart`, `flip_card.dart`, `card_back.dart`, `pack_art.dart`, `reveal_page.dart`, `packs_page.dart`, `result_page.dart` y `profile_page.dart`, además de las pruebas del núcleo (`game_test`, `progress_test`, `equipo_y_apodo_test`) y la evidencia de pruebas.
**Tiempo estimado:** unas 12 h en total (~3 h por día).

No edites `app_controller.dart`. Si necesitas un cambio ahí, pídeselo a Sebastián por chat.

**El código de cada día está en tu guía:** [Día 1](../guias/miguel/dia1.md) · [Día 2](../guias/miguel/dia2.md) · [Día 3](../guias/miguel/dia3.md) · [Día 4](../guias/miguel/dia4.md).

---

## Martes 20 (noche, ~30 min)

- [ ] `flutter doctor`: que al menos Flutter y algún dispositivo estén en ✓.
- [ ] Leer «Reglas cerradas» en `docs/kit/01-arquitectura.md`.

## Miércoles 21: piezas comunes y escenarios ([guía](../guias/miguel/dia1.md))

- [ ] Mañana (cuando Sebastián avise que el proyecto está en `main`): `errores.dart` y `flip_card.dart`.
- [ ] Tarde (con la base de Sebastián y `court_lines.dart` de Emma): `common.dart` y `card_back.dart`.
- [ ] Crear `docs/escenarios-prueba.md`, una tabla con **pasos y resultado esperado** para:
  1. Apodo vacío o de solo espacios.
  2. Apodo de más de **16** caracteres.
  3. Abrir el sobre dos veces el mismo día.
  4. Sobre con cartas repetidas (Nueva/Duplicada y conteo de copias).
  5. Iniciar partida con el equipo incompleto (0, 1 o 2 cartas).
  6. Cerrar y reabrir la app (cartas, equipo, apodo y partidas).
  7. Retroceder la fecha del dispositivo (el sobre **no** debe habilitarse).
  8. Partida empatada.
  9. Elegir equipo: con 3 elegidos el resto no se puede tocar; salir con ← no guarda el borrador.
  10. Partida: el rival nunca es uno de tus tenistas.
- **Cierre:** PR con los 4 archivos; escenarios subidos. 📣 Emma los necesita el jueves a las 11:00.

## Jueves 22: Sobres ([guía](../guias/miguel/dia2.md))

- [ ] Dibujo del sobre, pantalla de revelación y pestaña Sobres.
- **Cierre:** cada sobre suma exactamente 3 copias; la segunda apertura queda bloqueada; «Nueva» y «Duplicada» se ven bien.

## Viernes 23: Perfil y Resultado ([guía](../guias/miguel/dia3.md))

- [ ] **Antes de las 12:00:** Perfil con el error del apodo dentro del campo (Emma lo usa en Inicio).
- [ ] Resultado y su conexión con `match_page.dart` (después de la Partida de Sebastián, ~12:00).
- [ ] 15 min con Sebastián para entender `_change()`: se guarda primero y, si falla, se revierte.
- [ ] En el dispositivo de Sebastián: abrir el sobre, armar el equipo, cambiar el apodo, jugar, **cerrar la app por completo** y reabrir. ¿Se conserva todo?
- **Cierre:** una partida termina en Resultado y queda guardada.

## Sábado 24: validación final ([guía](../guias/miguel/dia4.md))

- [ ] Pruebas del núcleo: `game_test.dart` (reglas), `progress_test.dart` (progreso guardado) y `equipo_y_apodo_test.dart` (equipo, rival y apodo).
- [ ] Recorrer **los 10 escenarios** en la versión integrada y marcarlos con ✓ o ✗ y captura.
- [ ] Reportar cada ✗ en el chat **antes de las 18:00**.
- [ ] Evidencia en `docs/evidencia/miguel.md`. A las 21:00, ensayo general.

## Domingo 25

- [ ] Ensayar tu explicación de 2 min: cómo se abre un sobre (aleatorio con repetición, una vez por día local), cómo se guarda una partida (Resultado → `recordMatch` → `_change()`) y dónde vive el progreso (archivo JSON en el directorio de la app, escrito primero en un `.tmp` y luego renombrado).
- [ ] Poder hacer la demo de Sobres, Resultado y Perfil **sin ayuda**, y aclarar si los datos son demo o de la API.
