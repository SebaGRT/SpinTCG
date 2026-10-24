import http from 'node:http';
import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { setTimeout as delay } from 'node:timers/promises';
import { fetchCatalog } from './adapter.mjs';

// --- Configuración ---

const host = 'tennis-api-atp-wta-itf.p.rapidapi.com';
const key = process.env.RAPIDAPI_KEY; // la clave SOLO vive aquí, nunca en la app
const port = Number(process.env.PORT ?? 8787);

// Caché y presupuesto en servidor_api/.local/ (ignorado por git).
const dir = path.join(path.dirname(fileURLToPath(import.meta.url)), '.local');
const cacheFile = path.join(dir, 'catalog.json');
const budgetFile = path.join(dir, 'budget.json');

const DAY = 24 * 60 * 60 * 1000; // el catálogo dura 24 horas
const MAX_REQUESTS_PER_DAY = 40;
const RETRY_WAIT = 5 * 60 * 1000; // tras un fallo, esperar 5 minutos

let catalog; // última respuesta buena
let budget = { since: Date.now(), count: 0 }; // consultas hechas en 24 h
let pending; // actualización en curso (para no lanzar dos a la vez)
let cooldown = 0; // hasta cuándo no se reintenta

// Al arrancar, recuperar lo guardado (si existe).
try {
  catalog = JSON.parse(await fs.readFile(cacheFile, 'utf8'));
} catch {
  // Sin caché previa.
}
try {
  budget = JSON.parse(await fs.readFile(budgetFile, 'utf8'));
} catch {
  // Primer uso.
}

// --- Una consulta a RapidAPI ---

async function request(endpoint) {
  if (!key) throw new Error('Configura RAPIDAPI_KEY en el servidor');

  // Presupuesto: máximo 40 consultas cada 24 horas.
  if (Date.now() - budget.since >= DAY) budget = { since: Date.now(), count: 0 };
  if (budget.count >= MAX_REQUESTS_PER_DAY) {
    throw new Error('Presupuesto local diario agotado; esperar 24 horas');
  }
  budget.count++;
  await fs.mkdir(dir, { recursive: true });
  await fs.writeFile(budgetFile, JSON.stringify(budget));

  await delay(300); // pausa entre consultas para no saturar la API
  const response = await fetch(`https://${host}${endpoint}`, {
    headers: { 'X-RapidAPI-Key': key, 'X-RapidAPI-Host': host },
    signal: AbortSignal.timeout(15000),
  });
  if (!response.ok) {
    // 401 = clave mala, 403 = plan sin acceso, 429 = cuota o velocidad agotada.
    const body = await response.json().catch(() => ({}));
    const detail = body.message ?? body.error ?? 'revisar plan y cuota';
    throw new Error(`RapidAPI HTTP ${response.status}: ${detail}`);
  }
  return response.json();
}

// --- El catálogo, con caché ---

async function getCatalog() {
  // Si el catálogo tiene menos de 24 horas, se entrega sin consultar.
  if (catalog && Date.now() - Date.parse(catalog.fetchedAt) < DAY) return catalog;
  if (Date.now() < cooldown) {
    throw new Error('Actualización fallida; reintentar en cinco minutos');
  }
  pending ??= refresh();
  return pending;
}

async function refresh() {
  try {
    const next = await fetchCatalog(request);
    // Escritura segura: primero .tmp y después se renombra.
    await fs.mkdir(dir, { recursive: true });
    await fs.writeFile(`${cacheFile}.tmp`, JSON.stringify(next));
    await fs.rename(`${cacheFile}.tmp`, cacheFile);
    catalog = next;
    return next;
  } catch (error) {
    cooldown = Date.now() + RETRY_WAIT;
    throw error;
  } finally {
    pending = undefined;
  }
}

// --- Rutas HTTP ---

function send(res, status, body) {
  res.writeHead(status, { 'Content-Type': 'application/json; charset=utf-8' });
  res.end(JSON.stringify(body));
}

const server = http.createServer(async (req, res) => {
  if (req.method !== 'GET') return send(res, 405, { error: 'Método no permitido' });
  if (req.url === '/health') return send(res, 200, { ok: true, keyConfigured: Boolean(key) });
  if (req.url !== '/catalog') return send(res, 404, { error: 'Ruta no encontrada' });
  try {
    send(res, 200, await getCatalog());
  } catch (error) {
    send(res, 503, { error: error.message });
  }
});

// Solo 127.0.0.1: nadie más en la red puede usarlo.
server.listen(port, '127.0.0.1', () => {
  console.log(`Servidor local: http://127.0.0.1:${port} (clave configurada: ${Boolean(key)})`);
});

