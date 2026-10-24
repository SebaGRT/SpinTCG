import test from 'node:test';
import assert from 'node:assert/strict';
import { normalizePlayer, fetchCatalog, parseRecord } from './adapter.mjs';
import { readFileSync } from 'node:fs';

test('Respuesta de ejemplo de la documentación (récord como texto)', () => {
  // Fila del ranking y estadísticas copiadas de tennisapidoc.matchstat.com.
  const row = { position: 1, player: { id: 47275, name: 'Jannik Sinner', countryAcr: 'ITA' } };
  const stats = { total: '450-133', totalTitles: 36, totalTitlesWon: 31, totalFinalsWon: 5 };
  assert.deepEqual(normalizePlayer(row, stats), {
    id: 'atp-47275',
    name: 'Jannik Sinner',
    country: 'ITA',
    ranking: 1,
    titles: 31, // totalTitlesWon, no totalTitles
    winRate: 77.2, // 450 / 583
  });
});

test('El récord también se acepta como objeto', () => {
  assert.deepEqual(parseRecord({ wins: 3, losses: 1 }, 'total'), { wins: 3, losses: 1 });
  assert.deepEqual(parseRecord({ w: '3', l: '1' }, 'total'), { wins: 3, losses: 1 });
});

test('Datos faltantes o raros no se convierten en ceros ficticios', () => {
  const row = { position: 1, player: { id: 1, name: 'A' } };
  assert.throws(() => normalizePlayer(row, { total: { wins: 2 }, totalTitlesWon: 3 }));
  assert.throws(() => normalizePlayer(row, { total: '12 victorias', totalTitlesWon: 3 }));
  assert.throws(() => normalizePlayer(row, { total: '10-2' })); // sin títulos
});

test('Una consulta de ranking y una de carrera por jugador; mínimo seis', async () => {
  const calls = [];
  // RapidAPI falsa: 6 tenistas en el ranking, todos con estadísticas.
  const fakeRequest = async (endpoint) => {
    calls.push(endpoint);
    if (endpoint.includes('ranking/singles')) {
      return {
        data: Array.from({ length: 6 }, (_, i) => ({ position: i + 1, player: { id: i + 1, name: `P${i}` } })),
      };
    }
    return { total: '9-1', totalTitlesWon: 1 };
  };

  const catalog = await fetchCatalog(fakeRequest, { count: 6 });
  assert.equal(catalog.cards.length, 6);
  assert.equal(calls.length, 7); // 1 ranking + 6 estadísticas
  assert.equal(catalog.source, 'rapidapi');

  // Un ranking vacío no alcanza las 6 cartas mínimas.
  await assert.rejects(() => fetchCatalog(async () => ({ data: [] }), { count: 6 }));
});

test('Respuesta real de RapidAPI guardada en fixtures/', () => {
  const read = (name) => JSON.parse(readFileSync(new URL(`./fixtures/${name}`, import.meta.url)));
  const ranking = read('ranking-singles.json');
  const stats = read('player-statistics.json');

  const card = normalizePlayer(ranking.data[0], stats);
  assert.equal(card.ranking, 1);
  assert.ok(card.winRate > 0 && card.winRate <= 100);
  assert.ok(card.titles >= 0);
});

