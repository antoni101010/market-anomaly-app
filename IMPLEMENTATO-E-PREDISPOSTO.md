# Stato reale della release 2.1

## Implementato nel codice

| Area | Stato |
|---|---|
| App Flutter con dashboard, ricerca, dettaglio, watchlist e storico | Attivo |
| Grafico 1G/5G/1M/6M/1A/5A | Attivo |
| Valuta, fonte, orario e stato del prezzo | Attivo |
| Separazione quota raw e storico split-adjusted | Attivo |
| Conversione FX separata per filtri di capitalizzazione globali | Attivo quando il cambio EOD è disponibile |
| Cache a scadenza e controllo conflitto prezzo | Attivo |
| Light/Deep scanner, 19 mercati, limite Deep 200 | Attivo |
| Benchmark regionali e settoriali | Attivo con proxy ETF configurati |
| Dati mancanti `null`, Confidence e testi specifici | Attivo |
| Contesto banche/REIT/biotech/SaaS/minerari | Attivo nelle spiegazioni e nei controlli di lettura |
| Personalizzazioni e più configurazioni salvate | Attivo |
| Snapshot, esiti multi-orizzonte, feedback e versioni modello | Attivo |
| SQLite WAL, disco persistente configurabile e backup rotanti | Attivo |
| Retry/backoff, budget Screener e diagnostica | Attivo |
| CI backend e CI APK con test | Attivo |
| Backfill storico manuale e autenticato, con limiti anni/simboli | Attivo, spento di default |
| Snapshot PIT storici rettificati e append-only | Attivo |
| Outcome storici +1/+3/+7/+30/+90/+180 | Attivo per eventi con orizzonti maturi |
| Coorti storiche downside/upside separate | Attivo; downside è il solo lato primario |
| Checkpoint, ripresa e idempotenza del backfill | Attivo |

## Si attiva automaticamente quando il piano lo consente

| Funzione | Condizione esterna |
|---|---|
| Screener globale al posto dei 25 titoli di riserva | Endpoint EODHD Screener autorizzato |
| Grafico intraday reale 1G/5G | Endpoint intraday autorizzato |
| Fondamentali EODHD completi | Endpoint Fundamentals autorizzato |
| Più mercati e strumenti effettivi | Copertura del piano EODHD |

Non è necessario modificare file quando cambia il piano: la stessa chiave viene
usata alla scansione successiva e il fallback scatta solo su HTTP 403.

## Predisposto ma non dichiarato come “magicamente risolto”

- Login multiutente, pagamenti e abbonamenti dell'app.
- Distribuzione iOS/App Store: il codice Flutter è multipiattaforma, ma questo
  pacchetto automatizza soltanto APK Android; firma e pipeline iOS richiedono
  account Apple e certificati.
- Notifiche push, più lingue e temi selezionabili dall'utente.
- Database PostgreSQL multiistanza: SQLite persistente è adeguato alla singola
  istanza attuale; la migrazione sarà necessaria con più server concorrenti.
- Feed notizie premium e consensus analisti internazionali.
- Calendari di borsa completi per ogni festività: gli esiti usano sedute
  business-day e prezzi effettivamente disponibili, ma l'adapter calendario
  dedicato resta un'estensione futura.
- Identificatori ISIN/FIGI e riconciliazione completa ADR/dual listing: oggi la
  deduplicazione usa il ticker del provider.
- Retraining automatico: volutamente disattivato per evitare apprendimento
  incontrollato. Il repository contiene backtest, holdout, walk-forward e bias
  audit per la promozione controllata di una nuova versione.
- Promozione automatica champion/challenger: non implementata volutamente. Il
  backfill costruisce evidenza immutabile; selezione del challenger, confronto
  out-of-sample, approvazione e rollback restano un processo di rilascio umano.
- Universo storico completo per tutti i mercati: il job può processare ticker
  indicati o l'universo locale disponibile, ma membership PIT, delisting,
  ridenominazioni e prezzi rettificati completi dipendono dal provider/dataset
  esterno e devono essere verificati nel bias audit.

## Verifica del piano a pagamento

Gli endpoint a pagamento non possono essere certificati prima che EODHD li
autorizzi sulla chiave reale. Il codice, i parser, i fallback e i test offline
sono pronti; dopo l'upgrade va eseguita una scansione e controllato in
`/api/diagnostics` che `last_scan_mode` sia live, che i mercati siano coperti e
che non compaia `fallback_without_screener`.

## v2.3 implementato

- Bulk Global Light Scanner EODHD multi-exchange, limite sicurezza 50.000.
- Ranking globale + copertura geografica Deep fino a 300.
- News EODHD Catalyst Engine fino a 120 candidati.
- Conteggi distinti Universo / Light / Deep / risultati filtrati.
- Correzioni grafici calendar-based e 1G/5G robusti.
- P/S derivato, cash runway N/A, Confidence multi-layer.
- Diagnostica Global Market Tension.
- UI senza falso `LIVE`, WebSocket realtime USA on-demand e sorgenti leggibili.
- 31/31 test backend superati, inclusi test APP-like, universo 20.000, NVDA/listing primaria e intraday 1G/5G.
