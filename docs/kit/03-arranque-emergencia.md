# Arranque para emergencia de tiempo

## Si faltan horas

Integrar el módulo preparado en la carpeta personal. Mantener el flujo y las pruebas, simplificar animaciones y fotografías. Abrir la guía rápida de esa semana y revisar qué archivos reemplaza.

## Si faltan minutos

Usar la aplicación completa en `codigo-emergencia/app_flutter/`. El nombre oficial sigue pendiente; el respaldo utiliza “TCG de tenis”. Esta versión preparada permite demostrar las pantallas y reglas; la integración con datos reales se verifica aparte.

### APK de ensayo ya compilada

Si no hay tiempo para compilar, está disponible [la APK demo debug](codigo-emergencia/binarios/tennis-tcg-demo-debug.apk). Transferirla al teléfono Android e instalarla, o usar desde la raíz del plan:

```bash
adb install -r codigo-emergencia/binarios/tennis-tcg-demo-debug.apk
```

Requiere Android compatible y depuración USB para adb. Esta APK usa datos ficticios y todavía debe probarse en su dispositivo. El tamaño y SHA-256 están en `codigo-emergencia/binarios/README.md`. Para API real, compilar con la dirección del servidor según las instrucciones siguientes.

### Modo demostración

Desde la raíz del plan:

```bash
cd codigo-emergencia/app_flutter
flutter pub get
flutter devices
flutter run -d ID_DEL_DISPOSITIVO
```

Reemplazar `ID_DEL_DISPOSITIVO` por un ID de `flutter devices`. No pasar API_BASE_URL: se usan 24 cartas con estadísticas ficticias identificadas. No presentar este modo como consumo real de API.

### Modo API real

Requiere suscripción y clave del grupo. Node 22 o superior. En una terminal desde la raíz del plan:

```bash
cd codigo-emergencia/servidor_api
read -rsp 'Clave RapidAPI: ' RAPIDAPI_KEY
export RAPIDAPI_KEY
node server.mjs
```

El comando `read -rsp` corresponde a Bash; la clave se introduce sin mostrarla ni escribirla en el historial. En otro sistema, definir la variable de entorno del proceso de forma privada. No introducir la clave en Flutter.

En otra terminal, comprobar primero:

```bash
curl http://127.0.0.1:8787/health
curl http://127.0.0.1:8787/catalog
```

Si /catalog devuelve 503, revisar clave, cuota y el mensaje de validación. No repetir consultas sin leer el error: existe un intervalo de cinco minutos y un presupuesto diario. Si devuelve menos de 24 cartas, revisar `skipped`; no crear estadísticas para reemplazar datos ausentes.

Para emulador Android:

```bash
cd codigo-emergencia/app_flutter
flutter run -d ID_DEL_EMULADOR --dart-define=API_BASE_URL=http://10.0.2.2:8787
```

Para teléfono Android por USB, ejecutar `adb reverse tcp:8787 tcp:8787` y usar `--dart-define=API_BASE_URL=http://127.0.0.1:8787`. Para Linux local usar también 127.0.0.1. La conexión HTTP está permitida solo en compilaciones Android debug; una entrega release conectada necesita un endpoint HTTPS accesible. El servidor incluido escucha solo en el equipo local, no está publicado.

### Compilación de ensayo

Desde app_flutter:

```bash
flutter analyze
flutter test
flutter build apk --debug
```

La APK sin API_BASE_URL es de demostración. Para una APK debug conectada por USB, compilar con `--dart-define=API_BASE_URL=http://127.0.0.1:8787` y mantener adb reverse y el servidor activos durante el ensayo. No mezclar esta dirección con la del emulador.

No se ha desplegado el servicio ni incluido una clave. El estado exacto de las compilaciones y pruebas realizadas está en `04-validacion.md`.

## Recorrido de dos minutos

1. Mostrar Inicio y explicar si se usan datos demo o API.
2. Abrir el sobre diario y revelar las tres cartas.
3. En Colección, abrir tres cartas obtenidas y añadirlas al equipo.
4. En Jugar, completar tres rondas y mostrar el resultado.
5. Editar el apodo en Perfil, cerrar y abrir, y comprobar persistencia.

Si el sobre de hoy ya está abierto, mostrar su estado y la colección obtenida. No borrar el progreso o adelantar la fecha para aparentar una apertura legítima; ensayar el recorrido antes de la presentación.
