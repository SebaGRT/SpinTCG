# Sebastián Herrera S.: coordinación, API, reglas e integración

**Eres dueño de:** el proyecto Flutter (creado desde cero), `lib/domain/`, `lib/data/`, `lib/application/`, `main.dart`, `servidor_api/`, el tema, el botón, la navegación, `app_shell.dart`, Partida y Jugar, además de la integración y la compilación.

**El código de cada día está en tu guía:** [Día 1](../guias/sebastian/dia1.md) · [Día 2](../guias/sebastian/dia2.md) · [Día 3](../guias/sebastian/dia3.md) · [Día 4](../guias/sebastian/dia4.md). Aquí quedan la API, Android y la entrega.
**Tiempo estimado:** unas 14 h en total (2–3 h por día).

---

## Martes 20 (noche, ~1 h): arranque

- [ ] Leer `README.md` de este plan y enviar a Emma y Miguel su archivo correspondiente.
- [ ] Preguntar al curso: ¿el domingo es entrega o presentación? ¿Se exige la API real? (Ver el README.)
- [ ] Crear el repositorio y subirlo:
  ```bash
  cd ~/Documents/UDD/Trimestre11/Tecnologias-Web/Proyectos/SpinTCG
  rm -rf app_flutter servidor_api   # copias del kit: el código se escribe desde cero
  git init -b main
  git add . && git status        # revisar: no deben aparecer build/, .dart_tool/ ni .local/
  git commit -m "Plan, documentos y scripts del proyecto"   # el código se crea el miércoles desde cero
  gh repo create SpinTCG --private --source . --push
  gh repo edit --add-collaborator <usuario-emma>   # o invitar desde GitHub → Settings → Collaborators
  ```
- [ ] RapidAPI: con la cuenta del grupo, suscribirse a **Tennis API – ATP WTA ITF** y **anotar el límite del plan** (consultas por mes y por segundo). Si el límite es menor a 30 por día, avisar en el chat: hay que bajar `count` en `adapter.mjs`.

## Miércoles 21 (~3 h): API real y base (semana 1)

- [ ] **Proyecto desde cero** ([guía, día 1](../guias/sebastian/dia1.md)): esqueleto en `main` a las ~10:00, base visual a las 13:00 y núcleo en la tarde. Emma y Miguel esperan cada entrega.
- [ ] Las dos consultas reales de abajo se pueden dejar para el jueves si el día no alcanza.

- [ ] **Dos consultas reales**, sin que la clave quede en el historial:
  ```fish
  # fish
  read -s -x -g -P 'Clave RapidAPI: ' RAPIDAPI_KEY
  set H tennis-api-atp-wta-itf.p.rapidapi.com
  curl -s "https://$H/tennis/v2/atp/ranking/singles?pageNo=1&pageSize=24" \
    -H "X-RapidAPI-Key: $RAPIDAPI_KEY" -H "X-RapidAPI-Host: $H" \
    > servidor_api/fixtures/ranking-singles.json
  # tomar un player.id del archivo anterior:
  curl -s "https://$H/tennis/v2/profile/<ID>/statistics?type=atp&includeAll=true" \
    -H "X-RapidAPI-Key: $RAPIDAPI_KEY" -H "X-RapidAPI-Host: $H" \
    > servidor_api/fixtures/player-statistics.json
  ```
  En bash, la primera línea es `read -rsp 'Clave RapidAPI: ' RAPIDAPI_KEY; export RAPIDAPI_KEY`.
- [ ] Comparar los fixtures con lo que espera `servidor_api/adapter.mjs`: `data[].position`, `data[].player.{id,name,countryAcr}`, `total` (texto `"450-133"` según la documentación) y `totalTitlesWon`. **Ajustar el parser si algo difiere.** Ver la [revisión de la API](../api-tennis.md).
- [ ] Decidir `includeAll` (ver la revisión, punto 3): una consulta del mismo tenista con y sin el parámetro.
- [ ] Agregar una prueba en `adapter.test.mjs` que lea los fixtures reales y verifique que `normalizePlayer` produce una carta válida.
- [ ] Renombrar a **SpinTCG** en `android/app/src/main/AndroidManifest.xml` (`android:label`) y `linux/runner/my_application.cc` (los dos títulos de ventana). En Dart ya está hecho: `kBrand` en `theme.dart`. El `applicationId` se mantiene para no romper la compilación.
- [ ] Llamada de 15 min con el equipo: modelo `TennisCard`, `Challenge`, reglas de la partida y quién edita qué archivo.
- **Cierre:** fixtures reales en el repo **sin clave**; la app se llama SpinTCG; los tres ejecutan la app.

## Jueves 22 (~3 h): catálogo real e integración (semana 2)

- [ ] Servidor con la clave y catálogo completo:
  ```bash
  cd servidor_api && node server.mjs        # con RAPIDAPI_KEY exportada
  curl http://127.0.0.1:8787/health
  curl http://127.0.0.1:8787/catalog > fixtures/catalog-ejemplo.json
  ```
  Revisar la cantidad de cartas y el campo `skipped`. Si devuelve 503, **leer el mensaje antes de reintentar**: hay una espera de 5 min y un presupuesto de 40 consultas por día.
- [ ] App con datos reales en Linux: `flutter run -d linux --dart-define=API_BASE_URL=http://127.0.0.1:8787`. Inicio debe decir "Catálogo guardado desde RapidAPI".
- [ ] **Prioridad:** `navigation.dart` en `main` **a las 10:00** ([guía, día 2](../guias/sebastian/dia2.md)); después la cáscara, la primera prueba y el servidor escrito a mano.
- [ ] Integrar apenas lleguen los PR de Emma (equipo, Detalle) y Miguel (Sobres).
- [ ] 15 min con Miguel: explicarle `_change()` (guarda, y si falla revierte en memoria). Lo necesita el viernes.
- **Cierre:** la app arranca con la barra del mockup y Sobres funciona; `flutter test` en verde.

## Viernes 23 (~3 h): Android y API real (semana 3)

- [ ] Agregar `adb` al PATH: `fish_add_path ~/Android/Sdk/platform-tools`.
- [ ] Probar en el emulador: `flutter emulators --launch Medium_Phone_API_37.0` y luego `flutter run -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:8787`.
- [ ] Probar en el **teléfono real** por USB: `adb reverse tcp:8787 tcp:8787` y luego `flutter run -d <id> --dart-define=API_BASE_URL=http://127.0.0.1:8787`.
- [ ] Comprobar que, después de la primera carga, la app abre **sin el servidor** (el catálogo queda guardado en el teléfono).
- [ ] **14:00: decisión de plan B.** Si hay al menos 6 cartas reales, seguimos con la API. Si no, demo y limitación declarada (ver el README).
- [ ] Integrar los PR del día. Ejecutar `git grep -n -i "x-rapidapi-key:"`: solo debe aparecer `server.mjs`.
- **Cierre:** app en Android con datos reales; el reinicio conserva cartas, equipo y apodo.

## Sábado 24 (~3 h): congelamiento y compilación (semana 4)

- [ ] Integrar lo último **antes de las 18:00**. Después de esa hora, solo se corrigen errores.
- [ ] `flutter analyze`, `flutter test` y `node --test adapter.test.mjs` en verde.
- [ ] APK: `flutter build apk --debug --dart-define=API_BASE_URL=http://127.0.0.1:8787` (con datos reales) y `flutter build apk --debug` (demo de respaldo).
- [ ] README raíz final: qué es, cómo ejecutar el modo demo y el modo API, limitaciones (HTTP solo en debug, servidor local, fecha del dispositivo) y quién hizo qué.
- [ ] 21:00: ensayo general con el recorrido de 2 minutos (`docs/kit/03-arranque-emergencia.md`).

## Domingo 25: entrega

- [ ] Verificar el catálogo real por última vez e instalar en el dispositivo de la presentación.
- [ ] Tag: `git tag v1.0 && git push --tags`. Entregar en el formato que pidió el curso.
- [ ] Preparar tu explicación de 2 min: arquitectura, servidor intermediario (por qué la clave no va en la app), reglas y caché.
