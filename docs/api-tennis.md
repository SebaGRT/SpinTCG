# Revisión de la API de tenis (Matchstat · RapidAPI)

Documentación: <https://tennisapidoc.matchstat.com/>, revisada el 22 de octubre de 2026 contra `app_flutter/servidor_api/`. Es el mismo proveedor que `docs.tennis-api.com`: mismo host y mismas rutas.

> La documentación no reemplaza una consulta real con la cuenta del grupo. Las respuestas reales guardadas en `app_flutter/servidor_api/fixtures/` tienen la última palabra.

## Lo que usamos

| | Valor | ¿Coincide con nuestro código? |
|---|---|---|
| Host | `tennis-api-atp-wta-itf.p.rapidapi.com` | ✅ |
| Autenticación | Encabezados `X-RapidAPI-Key` y `X-RapidAPI-Host`. No existe la opción de clave en la URL | ✅ (solo en el servidor) |
| Ranking | `GET /tennis/v2/atp/ranking/singles?pageNo=1&pageSize=24`. `pageSize` vale 10 por defecto, máximo 500 | ✅ |
| Fila del ranking | `data[].position`, `data[].player.id`, `.name`, `.countryAcr` (código de 3 letras, también en `.country.acronym`) | ✅ |
| Estadísticas de carrera | `GET /tennis/v2/profile/{id}/statistics?type=atp` (objeto plano, sin `data`) | ✅ |
| Récord victorias-derrotas | `total` | ❌ **Corregido.** Ver abajo |
| Títulos | `totalTitlesWon` | ⚠️ **Corregido.** El parser caía a `totalFinalsWon`, que es otra cosa |

## Hallazgos

### 1. `total` es texto, no un objeto (crítico, ya corregido)

El ejemplo oficial dice `"total": "450-133"`. El adaptador del kit leía `total.wins` y `total.losses`. Con texto, **todos** los tenistas se descartaban y `/catalog` fallaba con «Solo 0 tenistas completos».

La propia documentación se contradice: su tabla de campos dice que `total` es un «objeto de victorias/derrotas». Por eso `parseRecord()` acepta `"450-133"`, `{wins, losses}` y `{w, l}`, y rechaza cualquier otra forma. Una prueba usa la respuesta de ejemplo de la documentación tal cual.

### 2. Títulos: usar solo `totalTitlesWon` (ya corregido)

En el ejemplo, `totalTitles` = 36, `totalTitlesWon` = 31 y `totalFinalsWon` = 5. Como 36 = 31 + 5, `totalTitles` cuenta **finales jugadas**. La documentación no lo aclara. El adaptador probaba `totalTitlesWon ?? totalFinalsWon ?? totalTitles`: si faltaba el primero, habría mostrado finales como títulos. Ahora usa solo `totalTitlesWon`, y si falta, descarta al tenista.

### 3. Qué partidos cuenta el récord: `includeAll=true`

Con `includeAll=true`, el récord suma Challenger, ITF y clasificaciones. Sin ese parámetro, cuenta solo partidos oficiales (Grand Slam, Masters, ATP Tour, Finals, Copa Davis y JJ. OO.).

- **Hoy:** `fetchCatalog` usa `includeAll=true`. Las dos respuestas están guardadas para comparar: `fixtures/player-statistics.json` (con el parámetro) y `fixtures/player-statistics-main-tour.json` (sin él).
- **Alternativa:** quitarlo hace que el % de victorias coincida con el de atptour.com y evita que un tenista joven sume títulos Challenger. Es un cambio de una sola línea en `fetchCatalog`.
- Sea cual sea, tiene que ser **igual para todos** los tenistas: no se mezclan criterios entre cartas.

### 4. Cuota del plan FREE: alcanza justo

| Plan | Cuota | Velocidad |
|---|---|---|
| **FREE** | **50 consultas/día** | 4 por segundo |
| PRO | 150 000/mes | 10 por segundo |

Todos los planes ven los mismos datos que usamos: la diferencia es solo la cuota. Pasarse devuelve **429**.

- Una actualización completa son **25 consultas** (1 de ranking + 24 de estadísticas). Nuestro servidor espera 300 ms entre consultas (~3 por segundo, bajo el límite de 4).
- El presupuesto local es de 40 cada 24 h, y las pruebas a mano con `curl` también gastan cuota de RapidAPI. **Con FREE caben 1 actualización y unas pocas pruebas por día.** No reiniciar el servidor una y otra vez para «reintentar».
- Para desarrollar, conviene bajar `count` (por ejemplo, `fetchCatalog(request, { count: 8 })` = 9 consultas) y volver a 24 para la entrega.
- La documentación no dice a qué hora se reinicia la cuota diaria. Nuestra ventana es de 24 h desde la primera consulta.

### 5. Errores que hay que reconocer

| HTTP | Significa |
|---|---|
| 401 | Clave inválida |
| 403 | Host mal escrito, o `plan_restricted` (el plan no incluye ese dato) |
| 429 | Cuota o velocidad agotada: esperar |

El servidor ahora incluye el `message` de RapidAPI en el error, así se sabe cuál de los tres fue.

### 6. Datos útiles que no usamos (y por qué)

- **Fotos:** `/tennis/v2/ms-api/uploads/Photo/atp/{id}.jpg`. Serían 24 consultas más (no caben en FREE) y tienen derechos de imagen. Seguimos con `PlayerFigure`.
- **Perfil** (`/player/profile/{id}`): fecha de nacimiento, sin datos que la carta necesite.
- **Ranking por fecha** (`filter=RankingDate:AAAA-MM-DD`): podría congelar el ranking para la demo. No hace falta: el catálogo ya queda guardado en el teléfono.

## Qué cambió en el código

- `app_flutter/servidor_api/adapter.mjs`: `parseRecord()` para `total`; títulos solo desde `totalTitlesWon`.
- `app_flutter/servidor_api/server.mjs`: el error incluye la explicación de RapidAPI.
- `app_flutter/servidor_api/adapter.test.mjs`: 5 pruebas, una con la respuesta de ejemplo oficial y otra con las respuestas reales de `fixtures/`.
