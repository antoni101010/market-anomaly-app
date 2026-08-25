# Market Anomaly v2.3 — Global Scanner

## Obiettivo

La v2.3 elimina il collo di bottiglia emerso nel test reale della v2.2: un
titolo come APP/AppLovin poteva risultare tra le anomalie più forti quando
analizzato manualmente ma non entrare nella scansione automatica.

## Nuovo flusso

1. **Bulk Global Light Scanner** — controlla tutte le azioni ordinarie eleggibili
   degli exchange configurati, fino a 50.000 righe di sicurezza.
2. **Global ranking** — drawdown 250d, shock giornaliero, volume anomalo,
   distanza EMA50/EMA200 e liquidità/capitalizzazione.
3. **Deep selection** — fino a 300 candidati; 70% dei posti ai punteggi globali
   più forti e il resto a copertura geografica, così i mercati piccoli non
   vengono cancellati dal peso degli USA.
4. **Deep Engine** — storia, fondamentali, valuation, Value Trap, rischi,
   benchmark e settore.
5. **Catalyst Engine** — news EODHD e filing disponibili sui candidati più
   rilevanti, fino a 120 per scansione.
6. **Persistenza** — snapshot Deep + catalogo Light ampio con conteggio reale
   dell'universo globale controllato.
7. **Fasce consultabili** — in modalità semplice le fasce sono separate: Normale
   20–39,9, Forte 40–59,9, Molto forte 60–100. I risultati Light non ancora
   approfonditi sono marcati come preliminari e, quando aperti, avviano il Deep
   Engine on-demand prima di mostrare la scheda completa.

## Universo

Core predefinito: Stati Uniti tramite il Bulk exchange `US` (con venue NASDAQ/NYSE/AMEX/BATS filtrate dai metadati), LSE, Toronto, TSX Venture, Parigi,
Xetra/Francoforte, Milano, Svizzera, Amsterdam, Bruxelles, Madrid, Lisbona,
Nordics, Tokyo, Hong Kong, Australia, Sudafrica e Varsavia. Gli exchange
configurati sul server vengono aggiunti al core, non lo sostituiscono.

Il main scanner mantiene le esclusioni già definite: strumenti non azionari,
illiquidi/penny e micro-cap sotto la soglia core. La ricerca manuale resta
separata.

## Caso-regressione APP

La suite contiene un test sintetico AppLovin-like con drawdown >50%, trend
negativo e volume elevato ma senza obbligo di un crollo giornaliero estremo.
Il titolo deve emergere automaticamente in cima al Light ranking ed entrare
nel Deep Engine. Se questo test fallisce, la regressione blocca la release.

## Correzioni incluse

- finestre grafici calendar-based;
- statistiche grafico sulla serie completa prima del downsampling;
- 1G/5G con sanitizzazione e fallback esplicito;
- P/S calcolabile da market cap/revenue TTM;
- cash runway positivo trattato come N/A;
- Confidence complessiva non più 100 con catalizzatore/dati mancanti;
- sorgenti/timestamp leggibili;
- tensione globale con campione neutrale più ampio e diagnostica errore;
- ranking home basato prima sull'Anomaly Score;
- catalogo Light persistito fino a 20.000 anomalie/rilevazioni utili per non
  nascondere i movimenti normali/moderati dietro ai soli 300 Deep;
- filtri semplici a fascia, non solo a soglia minima, così “Normale” non viene
  sommerso dalle anomalie più forti;
- `Casi storici` rinominato `Somiglianza`;
- nessun falso badge `LIVE`;
- nelle schede/grafici USA viene tentato il WebSocket EODHD realtime (<50 ms di trasporto dichiarato dal provider, incluso nell'All-In-One); se non disponibile si torna automaticamente alla quota REST ritardata;
- il Bulk scanner USA usa il codice exchange EODHD `US` e non i nomi venue NASDAQ/NYSE/AMEX/BATS come endpoint, evitando la perdita silenziosa dell'universo statunitense;
- ricerca ticker che privilegia la quotazione primaria (`isPrimary`) e mantiene
  le quotazioni secondarie separate e riconoscibili;
- riconciliazione prezzo × azioni, P/E da prezzo/EPS TTM e P/S da market cap/ricavi;
- esclusione automatica di multipli/capitalizzazioni incompatibili invece di
  mostrarli come numeri validi;
- valuta di quotazione separata dalla valuta dei fondamentali, con FX solo
  quando il confronto è deterministico;
- formattazione prezzi senza arrotondamenti fissi a due decimali quando il
  mercato usa una precisione diversa;
- test regressione NVDA per impedire casi come prezzo 14.040 USD, market cap
  336.430 mld e P/E 1,4x dovuti a listing/scala incompatibili.

## Posizionamento

Market Anomaly resta uno strumento di analisi statistica e ricerca, non
consulenza finanziaria, raccomandazione personalizzata o garanzia di risultati
futuri. Termini, Privacy e documentazione metodologica della v2.2 restano
inclusi e validi salvo revisione professionale prima della vendita pubblica.
