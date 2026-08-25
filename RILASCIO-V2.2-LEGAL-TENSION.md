# Market Anomaly v2.2 — Legal & Global Market Tension

Questa release parte integralmente dalla v2.1 e mantiene scanner, Deep Engine, dati fondamentali, Value Trap Risk, Confidence, snapshot, outcome multi-orizzonte, backfill storico, apprendimento controllato e automazioni esistenti.

## Novità integrate

**Legal & Compliance Layer.** L'app mostra al primo avvio Termini e Privacy versionati; le due conferme restano distinte. Il backend salva soltanto l'hash dell'identificatore casuale dell'installazione con versione e timestamp. Sono inclusi Termini, Privacy, metodologia/fonti/ritardi, conflitti d'interesse, cancellazione dati e pagine web statiche pronte per la pubblicazione. Il linguaggio visibile è stato neutralizzato senza rompere lo schema tecnico legacy.

**Global Market Tension Engine.** È separato dalla shortlist dei titoli in ribasso per evitare selection bias. Costruisce un campione neutrale multi-exchange, calcola pressione valutativa da P/E, forward P/E, P/S, EV/Sales e FCF yield, combina una lettura region-balanced e cap-weighted, misura euforia dei prezzi su benchmark globali/regionali e fragilità da volatilità, dispersione e breadth. Espone sempre la copertura e può dichiararsi parziale o non disponibile. Non è etichettato come previsione di crash o certezza di bolla.

**Trasparenza dati.** Nelle schede sono mostrati fonte, stato/ritardo, timestamp prezzo, fonte/periodo dei fondamentali, completezza e versione modello.

## Endpoint v2.2

- `GET /api/legal/current`
- `POST /api/legal/acceptance`
- `DELETE /api/legal/installation/{installation_id}`
- `GET /api/market-tension`
- `POST /api/market-tension/refresh`
- `GET /api/market-tension/history`

## Compatibilità

`opportunity_score`, `min_opportunity` e campi equivalenti rimangono nello schema interno/API per non spezzare database, storico, test e client esistenti. Nell'interfaccia sono descritti come “Somiglianza con casi storici”.

## Verifica eseguita

`python -m compileall` completato e `pytest -q` concluso con 16 test superati. Nel repository Flutter il workflow GitHub continua a eseguire `flutter analyze`, `flutter test` e la compilazione APK in release.

## Pubblicazione

Il codice non richiede ritocchi manuali per le funzionalità introdotte. Restano necessariamente esterni al sorgente: la pubblicazione HTTPS delle pagine privacy/termini, le dichiarazioni nella Play Console, l'eventuale contratto commerciale del provider dati, configurazione reale dell'hosting/chiavi e la revisione professionale del testo rispetto al modello commerciale effettivamente adottato.
