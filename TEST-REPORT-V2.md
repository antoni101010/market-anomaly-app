# Rapporto di verifica — Market Anomaly 2.1

Data verifica: 25 agosto 2026.

## Controlli completati nell'ambiente di preparazione

| Controllo | Esito |
|---|---|
| Compilazione e parsing dei 33 file Python | Superato |
| Verifica offline critica `release_verification.py` | Superata |
| Dati mancanti senza valori neutri inventati | Superato |
| Storico raw/rettificato e assenza di look-ahead | Superato |
| Quote correnti, valuta e conversione FX separata | Superato |
| Snapshot, outcome, feedback collegato e backup SQLite | Superato |
| Cache SEC a scadenza, inclusi i filing recenti | Superato |
| Filtri mercato/dimensione/settore | Superato |
| Smoke test quantitativo con holdout | Superato |
| Tre test diretti di fondamentali, rischi e dati mancanti | Superati |
| Bilanciamento sintattico e import locali dei 16 file Dart | Superato |
| Parsing dei 5 file YAML e workflow | Superato |
| Entrypoint di produzione `run.sh` | Superato |
| Ricerca di chiavi/token reali nel pacchetto | Nessuna credenziale inclusa |

La verifica critica ha restituito:

```text
RELEASE_VERIFICATION_OK
checks=missing_data,narrative,adjusted_prices,no_lookahead,fx,snapshots,
feedback,backup,filters,quote,missing_score,sec_cache,history_outcomes,
watchlist_events,advanced_filters
```

Lo smoke test ha prodotto 340 righe di feature e 17 segnali, con un blocco
holdout separato. Questi numeri certificano l'esecuzione del motore di test,
non costituiscono una previsione delle prestazioni future.

## Controlli eseguiti automaticamente dopo il caricamento su GitHub

L'ambiente locale di preparazione non include Flutter né l'intero stack
FastAPI/pytest. Per questo i controlli seguenti sono obbligatori nel CI e sono
già configurati nei due repository:

- backend: installazione pulita, compilazione, verifica offline e `pytest -q`;
- app: `flutter analyze`, `flutter test` e build APK release;
- caricamento dell'APK soltanto se tutti i passaggi precedenti sono verdi.

Non scaricare l'APK da un'esecuzione rossa. Il file
`LEGGIMI-PRIMA.md` indica esattamente l'ordine di caricamento e verifica.

## Addendum 2.1 — backfill storico

| Controllo | Esito nell'ambiente di preparazione |
|---|---|
| Compilazione moduli Python, incluso `historical_learning.py` | Superato |
| Import/smoke del core storico e configurazione default (+1/+3/+7/+30/+90/+180, downside, prezzi `all`) | Superato |
| Verifica offline 2.1 `release_verification.py` | Superata; copre anche universo neutrale, PIT, direzioni separate e immutabilità storica |
| `tests/test_historical_learning.py` | Superato: 3 test in ambiente pytest isolato |
| Suite pytest completa, incluso `test_historical_backfill_integration.py` | Superata: 13 test, 1 warning di deprecazione Starlette/TestClient senza failure |
| Chiamata reale al provider per backfill | Non eseguita: richiede chiave, piano e quota reali |

I test 2.1 coprono separazione downside/upside, prezzi rettificati e assenza di
look-ahead nelle feature, outcome/recupero, idempotenza, checkpoint/ripresa,
immutabilità SQLite e assenza di modifiche ai pesi; l'integrazione copre anche
autorizzazione `X-API-Key`, disabilitazione sicura per default e avvio
background. Il CI backend usa già `pytest -q`, quindi non richiede una modifica
del workflow per scoprirli. La suite completa isolata ha dato 13 passed; resta
comunque un gate obbligatorio l'esecuzione verde del CI GitHub sulla release
caricata.

Il workflow `Scansione automatica oraria` non deve invocare
`/api/historical-backfill`: l'operazione è costosa, esplicitamente abilitata e
manuale. Può continuare a invocare `/api/outcomes/update` per gli esiti live.

## Limite verificabile soltanto con la chiave EODHD aggiornata

Screener globale, intraday e fondamentali internazionali dipendono dagli
endpoint effettivamente inclusi nell'abbonamento. Parser, fallback e attivazione
automatica sono verificati offline; l'accesso commerciale reale potrà essere
certificato solo dopo l'upgrade, eseguendo una scansione e controllando la
diagnostica del server.
