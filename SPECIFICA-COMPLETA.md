# Specifica funzionale Market Anomaly 2.1

## Obiettivo

Rilevare movimenti ribassisti anomali, separarli da possibili deterioramenti
strutturali e presentare evidenze verificabili. Il prodotto è uno strumento di
ricerca quantitativa: non formula raccomandazioni personali, prezzi obiettivo,
importi da investire o istruzioni di acquisto/vendita.

## Pipeline Light / Deep

1. Il Light Scanner interroga lo Screener EODHD su 19 mercati configurabili e
   filtra prezzo, liquidità, capitalizzazione e movimento giornaliero.
2. Deduplica ticker e scarta fondi, ETF, warrant, obbligazioni e preferred
   quando il tipo di strumento è disponibile.
3. Ordina gli shock peggiori e inoltra fino a 200 candidati al Deep Engine.
4. Il Deep Engine recupera storico, quota recente, fondamentali e filing;
   confronta ogni titolo con benchmark di mercato e settore coerenti.
5. I risultati superano filtri personali separati: mercato, dimensione,
   settori, rischio, anomalia, opportunità e affidabilità.

L'obiettivo Light è 10.000 strumenti coperti, non 10.000 richieste complete:
il provider applica i filtri sul proprio universo e restituisce solo i
candidati. Il numero effettivo dipende dalla copertura e dalle quote API.

## Prezzi e grafico

- La quota mostrata è raw/non rettificata e arriva dall'endpoint più recente.
- Gli indicatori e il grafico storico usano la serie rettificata dal provider
  per split e corporate action, evitando falsi crolli tecnici.
- Ogni prezzo espone valuta, provider, timestamp e stato: live, ritardato,
  ultima chiusura, vecchio, conflitto o non verificato.
- Le capitalizzazioni restano visibili nella valuta di quotazione, ma i filtri
  piccola/media/grande usano una colonna USD separata ottenuta dal cambio EOD;
  valori non convertibili non vengono confrontati con soglie USD.
- Una differenza superiore al 50% tra quota e ultimo storico attiva un conflitto
  e mantiene il prezzo storico verificato.
- Cache storica: 30 minuti; cache quota: 60 secondi; soglia prezzo vecchio: 72
  ore, tutte configurabili.
- Grafico: 1G, 5G, 1M, 6M, 1A e 5A; se l'intraday non è incluso nel piano,
  viene mostrata la serie giornaliera con una nota esplicita.

## Punteggi e dati mancanti

- Anomaly Score: drawdown, RSI, volume, momentum, shock e forza relativa.
- Valuation Score: multipli realmente disponibili, mai un valore neutro
  inventato.
- Quality, Financial Risk, Distress Risk e Dilution Risk: calcolati solo quando
  esistono dati pertinenti.
- Value Trap Risk: qualità, valutazione, crescita, margini, bilancio, diluizione
  e catalizzatore.
- Confidence: quota di campi fondamentali effettivamente disponibili.
- Opportunity: sintesi prudenziale, limitata dalla Confidence; non è una
  probabilità né un consiglio.

Un campo assente resta `null/n.d.`. La scheda elenca i dati esatti mancanti;
non ripete più su ogni azienda la stessa frase generica. I testi citano misure
specifiche e aggiungono il contesto per banche, REIT, biotech, SaaS e società
legate alle materie prime.

## Personalizzazioni

- modalità semplice o avanzata;
- mercato: globale, USA, Europa, Asia, Canada, Australia, Sudafrica;
- dimensione: tutte, grandi, medie, piccole;
- profilo filtro: prudente, bilanciato, esplorativo;
- selezione settori;
- soglie di anomalia, opportunità, affidabilità e value trap;
- in modalità avanzata: valutazione minima, ribasso minimo, volume medio
  minimo e filtro per evento identificato/earnings/rischio strutturale;
- ampiezza risultati, Deep Engine e analisi catalizzatori;
- più configurazioni nominate, salvabili, richiamabili ed eliminabili.

## Memoria, esiti e controllo del modello

Il database SQLite persistente conserva:

- snapshot immutabili e versione del modello;
- storico dei punteggi;
- esiti a 1/3/7/30/90/180 sedute;
- rendimento assoluto e contro benchmark;
- massimo ribasso e sedute di recupero;
- feedback manuale utile/falso segnale;
- esecuzioni scanner, errori, watchlist e storico;
- sette backup consistenti a rotazione.

La pagina diagnostica API espone completezza operativa e aggregati per
orizzonte. L'aggiornamento esiti è automatico, il retraining di produzione no:
serve una valutazione point-in-time con holdout, walk-forward e approvazione.

## Backfill storico 2.1 e apprendimento controllato

Il backfill è un processo manuale, autenticato e in background che analizza
storici fino a una data di conoscenza `as_of`, mai futura. Per ogni evento
conserva un caso point-in-time: le feature terminano sulla seduta evento e gli
outcome usano solo sedute successive già disponibili entro quella data. La
configurazione predefinita richiede una baseline di 60 sedute, almeno 252
sedute di storico, uno shock downside <= -5% con z-score <= -2 o un controllo
upside >= +5% con z-score >= +2; un cooldown di 5 sedute riduce gli eventi
ripetuti. Tutte le soglie sono configurabili dal server.

La base di ricerca usa prezzi interamente rettificati per corporate action
(`price_adjustment: all`). Ogni evento conserva prezzi rettificati di segnale,
seduta precedente e benchmark, return/z-score, cutoff PIT, versione modello,
versione schema e hash immutabili. Gli esiti sono a 1, 3, 7, 30, 90 e 180
sedute e riportano rendimento assoluto, benchmark/relativo se disponibile,
drawdown, escursione avversa/favorevole e recupero. Per downside, il recupero
è il ritorno al prezzo rettificato pre-shock; per upside è il ritorno inverso al
pre-spike. Con l'impostazione predefinita, eventi senza tutti gli orizzonti
maturi vengono esclusi.

I dataset sono distinti per direzione: `downside` è l'unico lato primario;
`upside` è una coorte di controllo e non deve essere aggregata con il primo.
Run, checkpoint, audit, snapshot e outcome storici sono idempotenti e
append-only: ripetere la stessa run non duplica record, mentre un conflitto di
contenuto viene rifiutato. Un job parziale o fallito può essere ripreso.

Il backfill genera evidenza, non retraining. Il champion resta la versione
indicata da `MARKET_ANOMALY_MODEL_VERSION`; un challenger può essere valutato
offline soltanto con split PIT, holdout, walk-forward e confronto sullo stesso
universo/costi/benchmark. La promozione richiede approvazione esplicita e una
nuova versione modello; non esiste una via automatica che modifichi i pesi di
produzione.

## Affidabilità operativa

- API protetta da chiave applicativa;
- chiavi provider esclusivamente sul server;
- errori provider senza URL/token sensibili;
- retry con backoff per 429 e 5xx;
- tetto alle richieste Screener per ciclo;
- cache con scadenza, controlli di prezzo e diagnostica;
- SQLite WAL, foreign key, busy timeout, disco persistente e backup;
- pipeline CI separata per backend e APK.

## Limiti esterni

La qualità globale dipende da licenza, copertura e disponibilità di EODHD e
SEC. La release non può creare fondamentali internazionali assenti dal piano,
correggere errori presenti alla fonte o trasformare una quota EOD in real-time.
Eventi macro, notizie non classificate e dati pubblicati in ritardo possono non
essere catturati. Ogni risultato deve quindi restare verificabile nelle fonti.

Il backfill non elimina survivorship bias se il provider non offre membership
storica, delisting, cambi ticker o prezzi rettificati completi per il mercato
scelto. I fondamentali PIT sono utilizzabili solo quando la fonte consente di
ricostruire ciò che era pubblicato alla data evento; non si sostituiscono con
fondamentali attuali. Rate limit, piano commerciale, copertura benchmark e
calendario delle sedute limitano ampiezza e interpretazione dei risultati.
