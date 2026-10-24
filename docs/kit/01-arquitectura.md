# Arquitectura y contrato de datos

## Plataforma y almacenamiento

Objetivo inicial: Android. El respaldo incluye además Linux para ensayos. No incluye Flutter web porque el almacenamiento preparado utiliza `dart:io`. Windows o iOS requieren generar sus plataformas y verificar sus herramientas en una máquina compatible.

Flutter y Dart, `http` para consultar el servicio propio y `path_provider` para localizar el archivo JSON del progreso. La colección es pequeña; no se necesita SQLite en el MVP. Esta elección concreta reemplaza la alternativa inicial de shared_preferences.

## Capas y responsabilidades

- `domain/tennis_card.dart`: identidad y atributos; Sebastián mantiene el contrato.
- `domain/game.dart`: comparación y tres rondas; Sebastián.
- `data/catalog_repository.dart`: carga de catálogo normalizado; Sebastián.
- `data/local_store.dart`: archivo de progreso; Miguel implementa con revisión de Sebastián.
- `application/app_controller.dart`: fuente única de colección, equipo y perfil; Sebastián coordina sus cambios.
- `presentation/app_shell.dart`, `card_tile.dart`, `collection_page.dart`, `play_page.dart`: Emma.
- `presentation/packs_page.dart`, `profile_page.dart`: Miguel.
- `servidor_api/`: Sebastián. Mantiene la clave fuera del cliente.

## Contrato del servicio

`GET /catalog` devuelve JSON con `source: "rapidapi"`, `period: "career"`, `fetchedAt` y `cards`. Cada carta tiene `id` estable, `name`, `country`, `ranking` positivo, `titles` no negativo y `winRate` entre 0 y 100. El adaptador emplea `atp-<id>`; demo usa `demo-<n>`.

Ranking actual y estadísticas históricas de carrera son atributos de distinto período, rotulados como tales. El porcentaje se calcula para todos con el mismo criterio: `100 × victorias / (victorias + derrotas)` de carrera y cobertura ofrecida por el proveedor. No mezclar porcentaje anual con porcentaje de carrera entre cartas.

Se espera `ranking.data[].player.id`, `position`, y el registro `total` del endpoint de carrera (según la documentación revisada el 22 de octubre, texto `"W-L"`; ver `../api-tennis.md`). Verificar el JSON real de su cuenta antes de fijar el parser. Un dato faltante no vale cero: se excluye esa carta y se registra el motivo. Se buscan 24 jugadores; el servicio acepta al menos seis completos para operar. La meta del MVP sigue siendo aproximadamente 24.

## Catálogo y progreso

Se consulta el catálogo al primer inicio del modo API y se conserva una fotografía local, con IDs y estadísticas. No se actualizan automáticamente las cartas ya obtenidas al abrir otra vez, evitando perder cartas si cambia el ranking. En una evolución posterior se puede añadir actualización explícita con migración del catálogo; no está incluida.

El servidor comparte una caché de 24 horas y hasta 25 solicitudes por actualización (ranking + carrera de 24 jugadores). El presupuesto local es de 40 solicitudes por ventana de 24 horas y no controla llamadas hechas desde otras máquinas o RapidAPI directamente. Varias solicitudes simultáneas al servicio comparten la misma actualización.

El progreso se escribe primero en un archivo temporal y se renombra. Las operaciones esperan el guardado y revierten en memoria si falla. Demo y API usan archivos diferentes. Un archivo corrupto produce un error y no se sobrescribe silenciosamente. No hay nube ni recuperación tras reinstalación.

## Reglas cerradas

Seis cartas iniciales de tenistas diferentes. Un sobre por día local con tres cartas, con repetición posible. Equipo de tres IDs obtenidos y diferentes. Tres rondas en orden ranking, títulos y porcentaje. Rival aleatorio, oculto hasta la elección. Cada carta se usa una vez. Empate de atributo no suma puntos. Gana quien suma más rondas; empate final permitido. Una partida abandonada no incrementa el contador.

La apertura diaria es una regla de prototipo basada en la fecha del dispositivo. Retroceder el reloj no habilita un nuevo sobre; adelantarlo sí puede hacerlo. Una validación antifraude requeriría tiempo del servidor y cuentas, fuera del alcance.
