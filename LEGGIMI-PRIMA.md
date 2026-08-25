# AGGIORNAMENTO v2.3.0 — 25 agosto 2026

Questa ZIP sostituisce la v2.2 per il codice applicativo. La novità principale è il **Global Light Scanner**: l'intero universo azionario eleggibile viene controllato prima di scegliere i candidati Deep. Il caso APP/AppLovin è coperto da un test di regressione. Sono incluse anche le correzioni emerse dai test reali su grafici, intraday, completezza, Confidence, catalizzatori, fonti dati e tensione globale.

Apri `RILASCIO-V2.3-GLOBAL-SCANNER.md`, `MANIFESTO-V2.3.txt` e `TEST-REPORT-V2.3.md` per i dettagli. **Non servono modifiche manuali al codice dopo l'upload**; il backend preserva il core globale anche se Render contiene vecchie env della v2.2.

---

# AGGIORNAMENTO v2.2.0 — 25 agosto 2026

Questa ZIP include ora il Legal & Compliance Layer e il Global Market Tension Engine. Per il riepilogo completo apri `RILASCIO-V2.2-LEGAL-TENSION.md` e `MANIFESTO-V2.2.txt`. I testi legali sono in `LEGAL/` e le pagine web statiche in `legal-web/`.

---

# Market Anomaly — pacchetto coordinato (storico v2.1, aggiornato fino a v2.3)

Questo ZIP contiene **entrambi i repository completi e coordinati**. Non devi
ricopiare blocchi né correggere nuovamente i file già modificati.

- `market-anomaly-api-main`: backend FastAPI, scanner e memoria storica.
- `market-anomaly-app-main`: app Flutter/Android.

## Ordine di installazione

### 1. Backend GitHub

1. Estrai lo ZIP sul computer.
2. Apri la radice del repository GitHub del backend.
3. Seleziona **Add file > Upload files**.
4. Trascina **il contenuto** di `market-anomaly-api-main`, inclusa `.github`.
   Non trascinare la cartella contenitore.
5. Crea un unico commit: `Market Anomaly API v2.3`.
6. Attendi che su GitHub Actions `Verifica backend` sia verde e che Render
   completi il deploy.

I file con lo stesso percorso vengono sostituiti da GitHub. Non cancellare
prima i vecchi file e non creare sottocartelle aggiuntive.

### 2. Persistenza su Render (obbligatoria per la memoria)

Monta un disco persistente in `/var/data` e imposta su Render:

```text
MARKET_ANOMALY_DB=/var/data/market_anomaly.db
MARKET_ANOMALY_PRICE_CACHE_DIR=/var/data/price_cache
MARKET_ANOMALY_BACKUP_DIR=/var/data/backups
```

Senza disco persistente, Render può eliminare snapshot, esiti, feedback,
watchlist e storico a ogni nuovo deploy. Il motore crea anche sette backup
SQLite rotanti.

Conserva inoltre le variabili già presenti:

```text
MARKET_ANOMALY_DATA_MODE=live
MARKET_ANOMALY_PROVIDER=eodhd
EODHD_API_KEY=<chiave EODHD>
MARKET_ANOMALY_API_KEY=<chiave privata scelta da te>
SEC_USER_AGENT=MarketAnomaly tua-email@example.com
```

Non inserire mai le chiavi nei file o negli screenshot.

Per la scansione automatica, nel repository GitHub del backend apri
**Settings > Secrets and variables > Actions > New repository secret** e crea
`MARKET_ANOMALY_API_KEY` con lo stesso valore impostato su Render. Il workflow
non contiene la chiave e non può avviarsi senza questo secret.

### 3. App Android GitHub

1. Apri la radice del repository GitHub dell'app.
2. Seleziona **Add file > Upload files**.
3. Trascina **il contenuto** di `market-anomaly-app-main`, inclusa `.github`.
4. Crea un unico commit: `Market Anomaly app v2.3`.
5. Attendi che `Build Android APK` sia verde.
6. Scarica l'artefatto `market-anomaly-apk`, estrailo e installa
   `app-release.apk` sopra l'app esistente.

L'identificativo Android non cambia: URL del server, chiave API,
personalizzazioni e configurazioni salvate restano sul telefono.

## Piano EODHD e uso della v2.3

La v2.3 è predisposta per il piano **EODHD All-In-One** già configurato sul
backend. Il Global Light Scanner usa il Bulk EOD `extended` per interi exchange:
non effettua una richiesta completa per ogni singola società. Il codice usa il
composito `US` per il mercato statunitense (poi filtra le venue
NASDAQ/NYSE/AMEX/BATS tramite metadati), evitando endpoint Bulk non validi.

Obiettivo operativo: controllare il maggior numero possibile di azioni ordinarie
eleggibili, con limite di sicurezza a **50.000 righe**. Il numero effettivo varia
con copertura EODHD e filtri di liquidità/prezzo/capitalizzazione; il contatore
`Universo` mostra quello realmente processato, non un target teorico. Fino a 300
candidati ricevono il Deep Engine automatico e fino a 120 il Catalyst Engine.
Un catalogo Light ampio resta consultabile per le fasce Normale/Forte/Molto forte.

Per le azioni USA, quando apri una scheda o un grafico, il backend tenta il feed
**WebSocket realtime EODHD** incluso nell'All-In-One; se non riceve un trade entro
il timeout, torna automaticamente alla quota REST ritardata. Per i mercati non
USA la quota recente REST resta normalmente ritardata secondo il provider.

Il fallback di emergenza a un piccolo universo serve solo se il Bulk provider è
temporaneamente indisponibile e viene segnalato esplicitamente nella diagnostica;
non è la modalità normale della v2.3.

## Primo controllo dopo il deploy

1. Apri `https://<server>/health`: deve mostrare `version: 2.3.0`,
   `data_mode: live` e `real_data_only: true`.
2. Nell'app apri **Impostazioni > Testa**: vengono verificati anche database,
   snapshot ed esiti storici.
3. Apri **Personalizza analisi**, scegli mercato/profilo/settori e salva.
4. Avvia una scansione. La prima può essere lenta su Render gratuito.
5. Controlla una scheda: deve mostrare grafico 1G/5G/1M/6M/1A/5A, valuta,
   fonte e orario del prezzo, oltre ai dati esattamente mancanti.

## Cosa viene ricordato dal motore

Ogni analisi salva uno snapshot immutabile con versione modello, prezzi, fonte,
completezza e punteggi. Il workflow aggiorna gli esiti dopo 1, 3, 7, 30, 90 e
180 sedute, inclusi rendimento assoluto/relativo, massimo ribasso e recupero.
Il feedback `Utile` o `Possibile errore` viene registrato nella stessa memoria.

I pesi **non cambiano automaticamente in produzione**: una nuova versione può
essere promossa solo dopo backtest point-in-time, holdout, walk-forward e
approvazione esplicita. Questo evita che il sistema “impari” rumore o errori.

## 2.1 — Backfill storico (attivazione manuale)

La 2.1 può ricostruire eventi anomali già avvenuti per creare un dataset di
ricerca. Il job è **spento di default**, non parte al deploy e non va aggiunto
al workflow orario. Per abilitarlo impostare su Render:

```text
MARKET_ANOMALY_HISTORICAL_BACKFILL_ENABLED=1
```

Avviarlo inizialmente su pochi ticker e con un orizzonte contenuto; il valore
predefinito è 10 anni/250 simboli, mentre i limiti predefiniti del server sono
15 anni/10.000 simboli. Se non indichi ticker, EODHD costruisce un universo
neutrale dagli exchange configurati; in assenza dell'endpoint usa la lista
locale reale. Il job usa prezzi storici rettificati, registra outcome a
1/3/7/30/90/180 sedute e conserva le popolazioni `downside` e `upside`
separate. Non cambia mai pesi o modello in produzione.

```bash
curl --fail -X POST "https://<server>/api/historical-backfill" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: $MARKET_ANOMALY_API_KEY" \
  --data '{"years":5,"as_of":"2026-08-01","tickers":["AAPL.US"],"limit":1,"resume":true}'
```

Poi interrogare `/api/historical-backfill/status` fino al termine e
`/api/historical-learning/stats` per le statistiche per direzione e orizzonte.
La procedura completa, le variabili, i limiti provider e il gate
champion/challenger sono in `RILASCIO-V2.1-BACKFILL-STORICO.md`.

## Verifiche incluse

- workflow backend: compilazione Python, verifica critica offline e test pytest;
- workflow app: `flutter analyze`, `flutter test` e APK release;
- test specifici per dati mancanti, prezzi raw/rettificati, quote correnti,
  snapshot, esiti, feedback, backup, valuta e testi non ripetitivi.

Consulta `SPECIFICA-COMPLETA.md` e `IMPLEMENTATO-E-PREDISPOSTO.md` per il
dettaglio tecnico e per distinguere ciò che è attivo da ciò che dipende dal
provider dati. `TEST-REPORT-V2.md` separa inoltre i controlli già completati
da quelli che GitHub eseguirà nell'ambiente Flutter/FastAPI pulito.
