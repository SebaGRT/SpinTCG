# Verificación del respaldo preparado

Verificaciones efectuadas el 10 de octubre de 2026. Estas evidencias corresponden al código de respaldo generado; las carpetas personales de evidencia siguen destinadas al trabajo posterior de los integrantes.

## Resultados comprobados

| Comprobación | Resultado | Alcance |
|---|---|---|
| `flutter analyze --no-pub` | Sin incidencias | Código y pruebas del proyecto Flutter. |
| `flutter test --no-pub --reporter expanded` | 11 pruebas aprobadas | Tres de reglas, tres de progreso, tres de catálogo y dos de interfaz. |
| `node adapter.test.mjs` | 3 pruebas aprobadas | Transformación de fixtures, rechazo de datos incompletos y cantidad de consultas. |
| `flutter build apk --debug --no-pub` | Compilación correcta | APK Android universal de demostración, sin API_BASE_URL. |
| Servidor local sin clave | Verificado | /health devuelve 200 y keyConfigured=false; /catalog devuelve 503 con mensaje de configuración. No se llamó al proveedor. |
| Documentos Word | Revisados visualmente | Tres páginas de propuesta y seis del plan; sin cortes ni tablas desbordadas. |
| Estructura del plan | Verificada | Cuatro semanas y doce carpetas personales con tareas, dos guías y módulos preparados. |

Las pruebas de interfaz recorren un tamaño de 390 × 844, edición del apodo, apertura y revelación de tres cartas y una partida completa con guardado del resultado. Las pruebas de progreso comprueban persistencia mediante MemoryLocalStore, la apertura diaria, equipo válido, resultado único y reversión de un sobre si falla el guardado. No comprueban el almacenamiento físico del teléfono.

Las consultas de catálogo de Flutter y del adaptador se probaron con respuestas simuladas; no acreditan consumo real de RapidAPI.

## Comprobaciones pendientes del equipo

- **Sebastián:** suscribirse al plan del proveedor, consultar una respuesta autenticada y confirmar los campos de títulos, victorias y derrotas en adapter.mjs. Conservar un ejemplo sin credenciales. Verificar el límite de consultas del plan elegido.
- **Sebastián y Miguel:** instalar y probar en el dispositivo que usarán para presentar; comprobar reinicio y escritura real con FileLocalStore.
- **Emma:** comparar la interfaz con Figma. El enlace se incorporó, pero su contenido no pudo inspeccionarse desde este entorno. El respaldo tiene una interfaz funcional propia.
- **Todo el equipo:** confirmar con el curso la fecha final de implementación. El 11 de octubre es la fecha de entrega de la propuesta; el 12 de octubre al 8 de noviembre es el calendario sugerido de desarrollo.

## Binario de ensayo

[APK demo debug](codigo-emergencia/binarios/tennis-tcg-demo-debug.apk) (153,236,068 bytes). No está instalada en un dispositivo. SHA-256: `3a38a3ffc01fed4282685a387bab4907b820aa3816cb85ef2e299064d8235db8`. Consultar la [guía de arranque](03-arranque-emergencia.md).

El servidor no está publicado, no se incluyen claves y el acceso HTTP de Android se habilita únicamente en debug. Para una versión release conectada se requiere un endpoint HTTPS accesible.
