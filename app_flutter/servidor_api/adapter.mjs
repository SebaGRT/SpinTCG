// --- Validar números ---

/** Convierte a número o lanza un error. Un dato faltante NUNCA se vuelve 0. */
export function numeric(value, label) {
  const missing =
    value === null || value === undefined || value === '' || typeof value === 'boolean';
  if (missing) throw new Error(`Falta ${label}`);

  const n = Number(value);
  if (!Number.isFinite(n) || n < 0) throw new Error(`Valor inválido: ${label}`);
  return n;
}

// --- Leer un récord de victorias y derrotas ---

/**
 * La documentación da el récord como texto "450-133" en su ejemplo, pero su
 * tabla de campos dice "objeto". Se aceptan las formas conocidas:
 * "450-133", { wins, losses } y { w, l }. Cualquier otra cosa es un error.
 */
export function parseRecord(record, label) {
  if (typeof record === 'string') {
    const match = /^\s*(\d+)\s*-\s*(\d+)\s*$/.exec(record);
    if (!match) throw new Error(`Formato inválido: ${label} = "${record}"`);
    return { wins: Number(match[1]), losses: Number(match[2]) };
  }
  if (record && typeof record === 'object') {
    return {
      wins: numeric(record.wins ?? record.w, `${label} (victorias)`),
      losses: numeric(record.losses ?? record.l, `${label} (derrotas)`),
    };
  }
  throw new Error(`Falta ${label}`);
}

// --- Un tenista ---

/**
 * Junta una fila del ranking y las estadísticas de carrera de ese tenista
 * en una carta: { id, name, country, ranking, titles, winRate }.
 */
export function normalizePlayer(rankingRow, response) {
  const stats = response.data ?? response;
  const player = rankingRow.player;
  if (!player || !player.name || !player.id) {
    throw new Error('Ranking sin identidad de tenista');
  }

  // Récord de carrera: "total" (por ejemplo "450-133").
  const { wins, losses } = parseRecord(stats.total, 'total');
  if (wins + losses === 0) throw new Error('Sin partidos para calcular porcentaje');

  const position = numeric(rankingRow.position, 'position');
  if (position < 1) throw new Error('Ranking debe ser positivo');

  // Títulos ganados. Ojo: en el ejemplo oficial, totalTitles (36) es
  // totalTitlesWon (31) + totalFinalsWon (5), o sea, finales jugadas.
  // Por eso se usa SOLO totalTitlesWon.
  const titles = numeric(stats.totalTitlesWon, 'totalTitlesWon');

  return {
    id: `atp-${player.id}`,
    name: player.name,
    country: player.countryAcr ?? player.country?.acronym ?? 'N/D',
    ranking: position,
    titles,
    winRate: Math.round((1000 * wins) / (wins + losses)) / 10, // un decimal
  };
}

// --- El catálogo completo ---

/**
 * 1 consulta de ranking + 1 de estadísticas por tenista (máximo 25).
 * `request` es la función que llama a RapidAPI: en las pruebas es falsa.
 */
export async function fetchCatalog(request, { count = 24 } = {}) {
  const ranking = await request(`/tennis/v2/atp/ranking/singles?pageNo=1&pageSize=${count}`);
  if (!Array.isArray(ranking.data)) throw new Error('Ranking: se esperaba data[]');

  const cards = [];
  const skipped = []; // tenistas descartados y el motivo
  for (const row of ranking.data.slice(0, count)) {
    if (!row.player?.id) {
      skipped.push('Fila sin ID');
      continue;
    }
    const id = encodeURIComponent(row.player.id);
    const stats = await request(`/tennis/v2/profile/${id}/statistics?type=atp&includeAll=true`);
    try {
      const card = normalizePlayer(row, stats);
      if (!cards.some((c) => c.id === card.id)) cards.push(card);
    } catch (error) {
      skipped.push(`${row.player.name ?? row.player.id}: ${error.message}`);
    }
  }

  if (cards.length < 6) {
    throw new Error(
      `Solo ${cards.length} tenistas completos; se requieren al menos seis. ` +
        `Validar el esquema real: ${skipped.join('; ')}`,
    );
  }
  return {
    source: 'rapidapi',
    period: 'career',
    fetchedAt: new Date().toISOString(),
    cards,
    skipped,
  };
}

