<!-- Archivo generado por scripts/guias/generar.py: edita la plantilla, no este archivo. -->
# Guías de código: SpinTCG desde cero, con el diseño del mockup

Estas guías traen **el código completo que cada uno escribe a mano**, día por día. El proyecto parte **vacío** (`flutter create`) y termina igual al mockup *Court Cards*, con la marca SpinTCG. No se copia nada del código del kit.

El orden está pensado para que **la app compile al cierre de cada día**. Lo verificamos simulando el trabajo completo, del miércoles al sábado, sobre un proyecto recién creado (`scripts/guias/simular_integracion.sh`).

| | Miércoles 21 | Jueves 22 | Viernes 23 | Sábado 24 |
|---|---|---|---|---|
| **Sebastián** | [Día 1](sebastian/dia1.md): proyecto nuevo, tema, botón, modelo, catálogo demo, reglas, almacenamiento y controlador | [Día 2](sebastian/dia2.md): navegación, cáscara con barra inferior, primera prueba, servidor y API real | [Día 3](sebastian/dia3.md): Partida, Jugar, plan B y Android | [Día 4](sebastian/dia4.md): prueba de interfaz, APK, README |
| **Emma** | [Día 1](emma/dia1.md): la carta del tenista | [Día 2](emma/dia2.md): espacios del equipo, Elegir equipo y Detalle | [Día 3](emma/dia3.md): Colección e Inicio | [Día 4](emma/dia4.md): QA visual y capturas |
| **Miguel** | [Día 1](miguel/dia1.md): errores, widgets comunes, volteo y reverso | [Día 2](miguel/dia2.md): sobre, Sobres y revelación | [Día 3](miguel/dia3.md): Perfil y Resultado | [Día 4](miguel/dia4.md): pruebas del núcleo, escenarios y evidencia |

## Cómo trabajar con la guía

1. **Escribe el código tú, sin copiar y pegar.** Es la evidencia de tu trabajo y la manera de entenderlo. Escribir 300 líneas toma unas 2 h; los errores de tipeo los encuentra `flutter analyze`.
2. Después de cada archivo, lee la sección **«Entiende»**. En la presentación te pueden preguntar por cualquier línea.
3. Después de cada paso, ejecuta en `app_flutter/`:
   ```bash
   dart format lib test && flutter analyze && flutter test
   ```
   Hasta que Sebastián suba la primera prueba (jueves), `flutter test` dice que no encuentra pruebas: es normal. Ese día basta con `flutter analyze`.
4. Haz un commit por paso, en tu rama del día (`nombre/diaN-tema`). Al terminar el día, haz push y abre el PR antes de las 22:00.
5. ¿Te equivocaste y no ves dónde? Compara tu archivo con el de la guía, o con `referencia/app_flutter/` (está en el computador de Sebastián y **no se sube al repo**).

### Cómo leer los bloques de código

- Cada guía empieza con un **Mapa del día**: los pasos, el archivo de cada uno y de quién dependes.
- 📄 **`app_flutter/…`** dice en qué archivo escribes. Todas las rutas parten de `app_flutter/` (o de `servidor_api/`).
- **«Crea» / «Reemplaza todo»:** el archivo queda exactamente como el bloque.
- **«parte 2 de 4 · sigue debajo de la parte anterior»:** los archivos largos vienen en partes. Escríbelas **una debajo de la otra, en el mismo archivo**. Justo después de cada parte viene su explicación.
- Las líneas `// --- Título ---` también se escriben: separan las secciones del archivo y ayudan a encontrar cosas después.
- **«versión provisional»:** un archivo que se reemplaza más adelante. La guía avisa cuándo.
- Después de cada archivo: `dart format lib && flutter analyze`. Si algo falla, el mensaje dice el archivo y la línea. Los errores más comunes son de tipeo: mayúsculas (`ColorScheme`, no `colorScheme`), una coma o un paréntesis que falta.

### Ver tu trabajo antes de que exista la pantalla

Algunas piezas (la carta, los widgets comunes y el Perfil) recién se ven en la app días después. Para verlas antes, las guías traen un archivo `lib/muestra.dart` que se ejecuta con:

```bash
flutter run -t lib/muestra.dart
```

`lib/muestra.dart` está en `.gitignore`: es solo para mirar y no se sube.

### Pestañas «En construcción»

Desde el jueves, la app arranca con la barra inferior del mockup. Las pestañas que todavía no existen muestran `PantallaPendiente`. Cuando terminas tu pantalla, cambias **una línea** en `app_shell.dart` (cada guía dice cuál) y agregas su `import`. Quien reemplace la última pestaña borra también `import 'pendiente.dart';` y el archivo `pendiente.dart`.

### Cómo debe verse

En [`objetivo/`](objetivo/) están las 14 pantallas de la versión terminada (390 × 844, con las fuentes reales). Compara tu resultado con ellas y con el mockup.

## Entregas con hora (lo que otro está esperando)

| Cuándo | Quién entrega | Qué | Quién lo necesita |
|---|---|---|---|
| **Mié 21, ~10:00** | Sebastián | Proyecto Flutter nuevo en `main` | Todos: recién ahí se puede clonar |
| **Mié 21, 13:00** | Sebastián | Tema, `CourtButton` y `TennisCard` | Emma (la carta) y Miguel (los widgets comunes) |
| Mié 21, 15:00 | Emma | `court_lines.dart` | Miguel (`card_back.dart`) |
| Mié 21, tarde | Sebastián | Catálogo demo (primero) y el núcleo (controlador) | Emma (pantallas de muestra) |
| **Jue 22, 10:00** | Sebastián | `navigation.dart` | Emma (Elegir equipo, Detalle) y Miguel (Sobres) |
| Jue 22, 11:00 | Miguel | `card_back.dart` y `common.dart` integrados | Emma (espacios del equipo) |
| **Vie 23, 12:00** | Miguel | `profile_page.dart` | Emma (Inicio) |
| **Vie 23, 12:00** | Sebastián | `match_page.dart` | Miguel (Resultado) |
| Vie 23, 15:00 | Miguel | `result_page.dart` | Sebastián (prueba en Android) |

Sebastián integra los PR apenas llegan: el trabajo de los demás depende de eso. Si una entrega se atrasa, avisa en el chat y adelanta un paso que no dependa de ella. Cada guía indica qué pasos se pueden hacer sin esperar.

## Quién es dueño de cada archivo

| Archivo | Dueño | Día |
|---|---|---|
| Proyecto (`pubspec.yaml`, Android, Linux, Windows), `presentation/theme.dart`, `widgets/court_button.dart`, `domain/tennis_card.dart` | Sebastián | 1 (mañana) |
| `data/demo_catalog.dart`, `domain/game.dart`, `data/local_store.dart`, `data/catalog_repository.dart`, `application/app_controller.dart` | Sebastián | 1 (tarde) |
| `presentation/navigation.dart`, `app_shell.dart`, `main.dart`, `test/catalog_test.dart`, `servidor_api/` | Sebastián | 2 |
| `presentation/match_page.dart`, `play_page.dart` | Sebastián | 3 |
| `test/ui_flow_test.dart` | Sebastián | 4 |
| `widgets/countries.dart`, `court_lines.dart`, `player_figure.dart`, `player_card.dart` | Emma | 1 |
| `widgets/team_slot.dart`, `team_page.dart`, `detail_page.dart` | Emma | 2 |
| `collection_page.dart`, `home_page.dart` | Emma | 3 |
| `errores.dart`, `widgets/common.dart`, `widgets/flip_card.dart`, `widgets/card_back.dart` | Miguel | 1 |
| `widgets/pack_art.dart`, `reveal_page.dart`, `packs_page.dart` | Miguel | 2 |
| `profile_page.dart`, `result_page.dart` | Miguel | 3 |
| `test/game_test.dart`, `test/progress_test.dart`, `test/equipo_y_apodo_test.dart` | Miguel | 4 |

**Archivos provisionales**, que después se reemplazan (cada guía avisa cuándo):
- `main.dart` del miércoles (dos versiones de prueba). Se reemplaza por el definitivo el jueves.
- `pendiente.dart` y las pestañas «En construcción» de `app_shell.dart` (del jueves al viernes).
- `home_page.dart` (Sebastián, jueves). Emma lo reemplaza el viernes por el Inicio del mockup.
- El final de `next()` en `match_page.dart`. Miguel lo conecta a Resultado el viernes.

## Qué cambia respecto del mockup

- **Marca:** el mockup dice *Court Cards*; la app dice **SpinTCG** (constante `kBrand` en `theme.dart`).
- **Fotos:** el mockup dibuja un tenista ilustrado en lugar de una foto. Lo replicamos con `PlayerFigure`, así que no necesitamos fotos con derechos de autor.
- **Banner de la ronda:** si la regla no cabe al lado del atributo, baja a una segunda línea en lugar de apretarse.
- **Botón de Sobres:** queda abajo de la pantalla, como en el diseño original (`mt-auto`).
