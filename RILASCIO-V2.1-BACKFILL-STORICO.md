# Market Anomaly 2.1 — backfill storico e apprendimento controllato

## Scopo e confini

La 2.1 aggiunge un **backfill storico di eventi anomali di prezzo**. È un
dataset di ricerca separato dalla scansione live e dalla memoria degli
snapshot live: ricostruisce eventi passati, ne calcola gli esiti già maturi e
li conserva per valutare il modello. Non modifica pesi, soglie o modello in
produzione.

Il lato primario è sempre `downside`: il prodotto continua a studiare gli
shock negativi. Gli eventi `upside` sono salvati soltanto come coorte di
controllo/contesto e non vengono mescolati ai record downside, alle loro
statistiche o alle decisioni del modello. Le risposte statistiche espongono
sempre i due insiemi separatamente.

## Dati, point-in-time e prezzi

Per ciascun titolo il job legge lo storico fino alla data `as_of` richiesta,
individua eventi oltre la soglia negativa o positiva configurata e crea uno
snapshot immutabile per evento. Le feature dell'evento sono calcolate
unicamente dalle barre disponibili alla sua `event_session`; gli outcome sono
calcolati soltanto dalle sedute successive disponibili entro `as_of`. Una
richiesta con `as_of` futura è rifiutata.

La serie per la ricerca è **rettificata** (`price_adjustment: all`): lo
snapshot conserva `signal_adjusted_price`, il prezzo della seduta precedente e
il prezzo benchmark rettificato. Questo evita segnali ed esiti artificiali
dovuti a split/corporate action. La quota live mostrata dall'app resta raw/non
rettificata: non va confrontata direttamente con un prezzo storico rettificato.

Gli outcome richiesti sono esattamente a **+1, +3, +7, +30, +90 e +180
sedute** (configurabili con
`MARKET_ANOMALY_HISTORICAL_LEARNING_HORIZONS`). Ogni outcome conservato include
prezzo rettificato, rendimento assoluto, rendimento eccesso contro benchmark
quando disponibile, massimo drawdown, massima escursione avversa/favorevole,
recupero e numero di sedute al recupero. Con
`MARKET_ANOMALY_HISTORICAL_LEARNING_REQUIRE_ALL_HORIZONS=true` (default), un
evento incompleto non entra nel dataset di apprendimento.

Gli eventi e gli outcome storici sono append-only: hash di contenuto,
chiavi deterministiche, checkpoint per ticker e trigger SQLite impediscono
riscritture. Ripetere lo stesso run è idempotente; `resume: true` riprende una
run parziale/fallita compatibile, senza duplicare gli eventi. Una collisione di
chiave con contenuto diverso è un errore, non una sovrascrittura.

## Attivazione e configurazione

Il job è spento di default ed **escluso** da startup e scansione oraria. Su
Render impostare prima:

```text
MARKET_ANOMALY_HISTORICAL_BACKFILL_ENABLED=1
MARKET_ANOMALY_HISTORICAL_BACKFILL_DEFAULT_YEARS=10
MARKET_ANOMALY_HISTORICAL_BACKFILL_MAX_YEARS=15
MARKET_ANOMALY_HISTORICAL_BACKFILL_DEFAULT_SYMBOL_LIMIT=250
MARKET_ANOMALY_HISTORICAL_BACKFILL_MAX_SYMBOLS=10000
MARKET_ANOMALY_HISTORICAL_LEARNING_HORIZONS=1,3,7,30,90,180
MARKET_ANOMALY_HISTORICAL_LEARNING_BASELINE_SESSIONS=60
MARKET_ANOMALY_HISTORICAL_LEARNING_MINIMUM_HISTORY_SESSIONS=252
MARKET_ANOMALY_HISTORICAL_LEARNING_DOWNSIDE_THRESHOLD_PCT=-5.0
MARKET_ANOMALY_HISTORICAL_LEARNING_UPSIDE_THRESHOLD_PCT=5.0
MARKET_ANOMALY_HISTORICAL_LEARNING_ZSCORE_THRESHOLD=2.0
MARKET_ANOMALY_HISTORICAL_LEARNING_COOLDOWN_SESSIONS=5
MARKET_ANOMALY_HISTORICAL_LEARNING_RECOVERY_TOLERANCE_PCT=0.0
MARKET_ANOMALY_HISTORICAL_LEARNING_REQUIRE_ALL_HORIZONS=true
```

Conservare il disco persistente e i backup SQLite descritti in
`LEGGIMI-PRIMA.md`. Un backfill grande comporta molte richieste storiche:
partire da pochi ticker e controllare consumi, rate limit e copertura del piano
del provider prima di aumentare il limite.

## API operativa

Tutti gli endpoint seguenti richiedono `X-API-Key` se
`MARKET_ANOMALY_API_KEY` è configurata.

| Metodo | Endpoint | Uso |
|---|---|---|
| POST | `/api/historical-backfill` | Avvia un solo job in background; è rifiutato con 503 se il flag di attivazione è spento. |
| GET | `/api/historical-backfill/status` | Stato del processo e checkpoint persistito dell'ultima run. |
| GET | `/api/historical-learning/stats` | Conteggi e outcome per `downside` e `upside`, separati. |

Le statistiche restituiscono `events_by_side`,
`performance_by_side_and_horizon` e il riepilogo `directions.downside` /
`directions.upside`; non esiste un totale di performance che mescoli le due
popolazioni. Non è previsto un comando CLI di produzione: l'avvio supportato è
l'endpoint autenticato qui sotto (oppure, per ricerca offline, la funzione
Python `run_historical_backfill`).

Esempio di avvio prudente:

```bash
curl --fail -X POST "https://<server>/api/historical-backfill" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: $MARKET_ANOMALY_API_KEY" \
  --data '{
    "years": 5,
    "as_of": "2026-08-01",
    "tickers": ["AAPL.US", "MSFT.US"],
    "limit": 2,
    "resume": true
  }'

curl --fail -H "X-API-Key: $MARKET_ANOMALY_API_KEY" \
  "https://<server>/api/historical-backfill/status"

curl --fail -H "X-API-Key: $MARKET_ANOMALY_API_KEY" \
  "https://<server>/api/historical-learning/stats"
```

Il corpo accetta `years`, `as_of` (`YYYY-MM-DD`), `tickers`, `limit` e
`resume`. Se `tickers` è vuoto, il backend prova a costruire un universo
neutrale dagli exchange EODHD configurati, senza riutilizzare lo Screener dei
soli ribassi; se il provider non lo permette ripiega sulla lista locale reale.
I valori effettivi sono limitati dal server: di default 10 anni e 250 simboli,
massimo 15 anni e 10.000 simboli. Conviene aumentare il lotto gradualmente per
rispettare quota e tempi del provider. Un secondo job mentre il primo è
in corso non ne avvia un altro. Il `run_key` dipende da simboli, anni, `as_of`,
versione modello, orizzonti e soglie; conservarlo insieme all'export e alle
statistiche della run.

## Validazione e promozione champion/challenger

Il champion è la versione di produzione indicata da
`MARKET_ANOMALY_MODEL_VERSION`; rimane invariato dal backfill. Un challenger
può essere allenato o ricalibrato **fuori dalla produzione** solo sui record
downside, con coorte upside riportata separatamente come controllo. Questa
release non contiene né endpoint né automazione che promuova un challenger:
`automatic_production_weight_changes` è sempre `false`.

Prima di promuovere un challenger occorrono tutti questi artefatti versionati:

1. split temporale point-in-time, con le feature fermate alla data evento;
2. holdout mai usato per scegliere pesi/soglie;
3. walk-forward con finestre train antecedenti alle finestre test;
4. confronto champion/challenger sullo stesso universo, costi, benchmark e
   orizzonti +1/+3/+7/+30/+90/+180;
5. verifica per regime, settore, copertura, delisting/survivorship e qualità
   PIT, con intervalli d'incertezza e drawdown;
6. approvazione esplicita, nuova `MARKET_ANOMALY_MODEL_VERSION`, backup del DB
   e piano di rollback.

Un risultato medio positivo, unicamente in-sample o ottenuto mescolando le due
direzioni non è sufficiente per una promozione.

## Limiti del provider e interpretazione

- Il backfill può essere accurato solo quanto lo storico rettificato e il
  benchmark restituiti dal provider; piano, rate limit, simboli storici e
  corporate action possono ridurre la copertura.
- La lista ricavata dal server non dimostra da sola la membership storica
  completa. Senza un universo point-in-time con delisting, survivorship e
  coverage restano rischi da misurare nel bias audit.
- I fondamentali PIT non vengono inventati se la fonte non può restituire una
  pubblicazione disponibile alla data evento. Non usare fondamentali attuali
  per dichiarare una validazione storica.
- Le sedute sono quelle che il provider rende disponibili; festività,
  sospensioni, cambi di ticker e dati mancanti devono restare tracciati come
  copertura/errore, non essere riempiti con prezzi futuri.

## CI e test

Il workflow backend `Verifica backend` esegue già `pytest -q`, quindi include
automaticamente i nuovi test scoperti in `tests/`, inclusi
`tests/test_historical_learning.py` e
`tests/test_historical_backfill_integration.py`. Non è necessario aggiornare
il workflow CI per farli partire. Non aggiungere il backfill allo workflow
orario: è un'attività costosa e deliberatamente manuale; il workflow attuale
deve continuare ad aggiornare soltanto gli outcome live maturati.
