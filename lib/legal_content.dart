class LegalContent {
  static const String termsVersion = '2026-08-25-v1';
  static const String privacyVersion = '2026-08-25-v1';
  static const String methodologyVersion = 'market-tension-1.0';

  static const String operatorName =
      'TIMONE TRASLOCHI E SERVIZI DI HELT ANTONI';
  static const String operatorVat = 'IT03132390216';
  static const String operatorAddress =
      'Via San Giacomo 53/A-1, 39055 Laives (BZ), Italia';
  static const String privacyContact = 'antonilavoro@pec.it';

  static const String shortFinancialNotice =
      'Market Anomaly è uno strumento di analisi statistica e ricerca. '
      'Non fornisce consulenza finanziaria personalizzata, indicazioni di '
      'acquisto o vendita, gestione di portafoglio, esecuzione di ordini o '
      'garanzie sui risultati futuri. Dati e calcoli possono essere incompleti, '
      'ritardati o inesatti. Ogni decisione deve essere verificata autonomamente.';

  static const String terms = '''
TERMINI E CONDIZIONI D'USO — MARKET ANOMALY
Versione: $termsVersion

1. Fornitore del servizio
Market Anomaly è fornito da $operatorName, P. IVA $operatorVat, con sede in $operatorAddress. Contatto privacy e comunicazioni formali: $privacyContact.

2. Natura del servizio
Market Anomaly è un software di ricerca e analisi statistica dei mercati finanziari. Il servizio raccoglie, elabora e presenta dati quantitativi, fondamentali, storici e relativi a eventi di mercato. Le etichette, i punteggi e le classificazioni descrivono caratteristiche statistiche dei dati osservati.

Il servizio non effettua profilazione finanziaria dell'utente basata su reddito, patrimonio, esperienza, obiettivi o tolleranza alle perdite; non determina se uno strumento sia adatto a una specifica persona; non impartisce istruzioni di acquisto, vendita o mantenimento; non esegue ordini; non gestisce denaro o portafogli; non garantisce rendimenti o recuperi di prezzo.

3. Nessuna consulenza finanziaria personalizzata
Le informazioni sono generali e rivolte agli utenti come materiale di ricerca. Non devono essere interpretate come consulenza finanziaria, raccomandazione personale, sollecitazione, offerta, invito a negoziare o promessa di rendimento. Un punteggio elevato non significa che un titolo debba essere acquistato e un punteggio basso non significa che debba essere venduto.

4. Significato dei punteggi
"Anomalia" misura quanto un movimento osservato differisca da condizioni statistiche di riferimento. "Somiglianza con casi storici" confronta il quadro corrente con casi presenti nel dataset e non stima il rendimento futuro. "Rischio value trap", "Affidabilità" e gli altri indicatori sono stime quantitative soggette a errore, dati mancanti e modifiche metodologiche.

L'indicatore "Tensione globale dei mercati" sintetizza valutazioni, euforia dei prezzi, fragilità e copertura dei dati. Non identifica con certezza una bolla, non prevede una correzione e non stima quando un eventuale ribasso possa avvenire.

5. Dati, fonti, ritardi ed errori
Prezzi, fondamentali, notizie e metadati possono provenire da fornitori terzi. I dati possono essere EOD, differiti, aggiornati con frequenze diverse, incompleti, errati o temporaneamente indisponibili. L'app mostra, quando disponibile, fonte, orario, stato del prezzo, completezza e limiti dell'analisi. L'utente deve verificare le informazioni presso fonti indipendenti prima di assumere decisioni economiche.

6. Dati storici e backtest
Risultati storici, statistiche di recupero, simulazioni, backtest e confronti con benchmark non costituiscono una previsione e non garantiscono risultati futuri. I mercati possono comportarsi in modo diverso dai casi storici.

7. Uso consentito
L'utente può utilizzare il servizio per consultazione e ricerca personale o professionale lecita. È vietato tentare di aggirare controlli tecnici, abusare delle API, estrarre massivamente dati in violazione dei diritti dei fornitori, interferire con il servizio, introdurre codice dannoso o utilizzare il prodotto per attività illegali.

8. Disponibilità e modifiche
Il servizio può essere aggiornato, modificato, sospeso o limitato per manutenzione, sicurezza, variazioni dei provider, requisiti normativi o ragioni tecniche. Metodologie e soglie possono cambiare; quando una modifica è sostanziale, la versione applicabile viene aggiornata.

9. Abbonamenti
La presente build non attiva automaticamente un abbonamento a pagamento. Se in futuro saranno introdotti piani a pagamento, prezzo, durata, rinnovo, prova gratuita, modalità di cancellazione ed eventuali rimborsi saranno mostrati prima dell'acquisto e gestiti secondo il canale di vendita applicabile e la normativa inderogabile. Una modifica sostanziale delle condizioni commerciali richiederà una nuova versione dei Termini.

10. Limitazione di responsabilità
Nei limiti consentiti dalla legge, il servizio è fornito senza garanzia che i dati siano sempre esatti, completi, tempestivi o adatti a uno specifico scopo. Il fornitore non risponde di decisioni di investimento assunte autonomamente dall'utente sulla sola base dell'app. Nulla in questi Termini esclude o limita responsabilità che non possono essere escluse per legge, inclusi i diritti inderogabili dei consumatori, dolo o colpa grave ove applicabili.

11. Proprietà intellettuale
Software, interfaccia, metodologia proprietaria, testi originali, struttura dei punteggi e dataset proprietari restano protetti nei limiti previsti dalla legge e dagli accordi con i rispettivi fornitori di dati.

12. Privacy
Il trattamento dei dati personali è descritto nell'Informativa Privacy separata. L'accettazione dei Termini non costituisce consenso a trattamenti facoltativi. In questa build non sono attivati consensi marketing o advertising comportamentale.

13. Cancellazione dati
L'app permette di eliminare dal backend il record pseudonimo di accettazione associato all'installazione. La rimozione reimposta localmente l'accettazione e richiede una nuova accettazione per continuare a usare il servizio. Eventuali dati che debbano essere conservati per obblighi di legge o difesa di diritti possono essere trattenuti nei limiti consentiti.

14. Legge applicabile e foro
Si applica la legge italiana, fatti salvi i diritti inderogabili riconosciuti al consumatore dalla normativa applicabile. Per i consumatori resta competente il foro previsto dalle norme imperative; nessuna clausola dei presenti Termini deroga a tali tutele.

15. Contatti
Per richieste sul servizio o sui dati personali: $privacyContact.
''';

  static const String privacy = '''
INFORMATIVA PRIVACY — MARKET ANOMALY
Versione: $privacyVersion

1. Titolare del trattamento
$operatorName — P. IVA $operatorVat
$operatorAddress
Contatto privacy: $privacyContact

2. Dati trattati
La build corrente può trattare: un identificatore casuale di installazione, memorizzato sul server soltanto in forma hash per registrare la versione dei Termini accettata; data e ora dell'accettazione; versione dell'app e piattaforma; dati tecnici indispensabili alla comunicazione con il backend; preferenze e configurazioni salvate localmente sul dispositivo; ticker, watchlist, feedback o note immessi nelle funzioni dell'app; dati di mercato richiesti al backend.

La chiave API e l'indirizzo del backend sono salvati localmente nelle preferenze dell'app. Le chiavi dei provider di mercato restano sul server e non vengono distribuite nell'app.

3. Finalità e basi giuridiche
I dati sono trattati per erogare il servizio e applicare i Termini; mantenere sicurezza, integrità e diagnostica tecnica; dimostrare la versione dei Termini accettata; rispondere a richieste dell'utente; adempiere a eventuali obblighi di legge. Le basi giuridiche possono includere esecuzione del contratto, obbligo legale e legittimo interesse alla sicurezza e difesa del servizio, secondo il caso.

L'informativa privacy non viene presentata come consenso. Eventuali trattamenti facoltativi che in futuro richiedano consenso saranno separati, specifici e revocabili. In questa build non sono attivati advertising personalizzato, marketing diretto o analytics facoltativi dell'app.

4. Destinatari e fornitori
I dati possono essere trattati da fornitori tecnici necessari all'hosting, rete, distribuzione dell'app e servizi dati, nella misura necessaria a fornire le funzionalità. I dati di mercato possono essere richiesti a provider esterni secondo i rispettivi termini. Non vengono venduti dati personali agli inserzionisti.

5. Trasferimenti
Alcuni fornitori tecnici o di mercato possono operare fuori dallo Spazio Economico Europeo. Quando applicabile, il trasferimento deve avvenire mediante un meccanismo riconosciuto dalla normativa europea o altra base valida prevista dal GDPR.

6. Conservazione
I record di accettazione sono conservati per il tempo necessario a documentare il rapporto con l'utente e gestire eventuali obblighi o contestazioni, salvo richiesta di cancellazione e salvo obblighi di conservazione. Preferenze locali restano sul dispositivo finché l'utente non cancella i dati dell'app. Log tecnici eventualmente prodotti dall'infrastruttura seguono i tempi di conservazione configurati dal rispettivo fornitore.

7. Diritti dell'interessato
Nei casi previsti dal GDPR, l'interessato può chiedere accesso, rettifica, cancellazione, limitazione, portabilità, opposizione e può proporre reclamo all'autorità di controllo competente. Le richieste possono essere inviate a $privacyContact.

8. Decisioni automatizzate
I punteggi di Market Anomaly sono elaborazioni statistiche sui mercati e non producono decisioni giuridiche o effetti analogamente significativi sulla persona dell'utente. L'app non determina automaticamente l'idoneità finanziaria personale dell'utente.

9. Minori
Il servizio è destinato a persone che possono validamente accettare i Termini secondo la normativa applicabile e non è progettato come servizio rivolto ai minori.

10. Modifiche
In caso di modifiche sostanziali all'informativa, la versione e la data vengono aggiornate e l'utente può consultare il testo corrente nell'app.
''';

  static const String methodology = '''
METODOLOGIA, FONTI E LIMITI
Versione metodologia globale: $methodologyVersion

Market Anomaly utilizza due livelli di analisi: uno scanner leggero individua movimenti statisticamente rilevanti; l'analisi approfondita calcola indicatori di anomalia, valutazione, rischio strutturale, qualità dei dati e somiglianza con casi storici. La ricerca manuale può analizzare un titolo su richiesta.

Somiglianza con casi storici
Il valore interno storicamente denominato opportunity_score viene mantenuto nell'API per compatibilità tecnica, ma nell'interfaccia è descritto come "Somiglianza con casi storici". Esso combina segnali quantitativi e fondamentali e viene penalizzato da rischio value trap e bassa completezza. Non rappresenta una probabilità di guadagno, un target price o un'indicazione operativa.

Tensione globale dei mercati
Il motore usa un campione neutrale multi-mercato, separato dalla shortlist dei titoli già crollati. La componente Valutazioni considera, quando disponibili, P/E, forward P/E, prezzo/ricavi, EV/ricavi e rendimento del free cash flow su un campione neutrale dei principali titoli liquidi per exchange. La lettura valutativa combina 40% media bilanciata tra regioni e 60% ponderazione per capitalizzazione, così un solo mercato non domina ma il peso economico globale resta rappresentato. La componente Euforia prezzi usa benchmark regionali e globali e misura distanza dalle medie mobili, prossimità ai massimi e momentum. La componente Fragilità considera volatilità, dispersione e breadth dei benchmark. Il punteggio complessivo usa pesi 45% valutazioni, 35% euforia e 20% fragilità, ricalibrati solo sui componenti effettivamente disponibili.

Copertura
La copertura viene mostrata separatamente. Se fondamentali, exchange o benchmark sono insufficienti, lo stato diventa "parziale" o "non disponibile". Il motore non deve trasformare dati mancanti in un punteggio apparentemente preciso.

Fonti e ritardi
Prezzi, fondamentali e metadati possono provenire da EODHD, Twelve Data, SEC EDGAR o altri provider configurati nel backend. L'indicatore globale usa dati EOD e fondamentali e non è real-time. Ogni scheda mostra, quando disponibile, fonte, orario osservato, stato e campi mancanti.

Apprendimento
Ogni segnale può essere salvato come snapshot immutabile. Gli esiti vengono verificati a +1, +3, +7, +30, +90 e +180 sedute, includendo rendimento assoluto, rendimento relativo al benchmark, massimo drawdown e recupero. Il dataset può alimentare modelli candidati, ma non modifica automaticamente e incontrollatamente il modello di produzione.

Limiti
Dati storici e backtest possono contenere bias residui, cambiamenti di regime, errori del provider e limiti di copertura. Nessuna relazione statistica garantisce che un caso futuro si comporti come il passato.
''';

  static const String conflicts = '''
POLITICA SU CONFLITTI D'INTERESSE E NEUTRALITÀ

Market Anomaly è progettato per presentare analisi statistiche in modo neutrale. Il prodotto non deve aumentare un punteggio perché il fornitore, uno sponsor o un partner trae beneficio economico da una specifica operazione.

Nella build corrente non sono previste commissioni di brokeraggio per acquisto o vendita di strumenti e l'app non esegue operazioni. Qualora in futuro vengano introdotti rapporti commerciali, sponsorizzazioni, affiliazioni con intermediari o interessi economici relativi a strumenti analizzati, tali rapporti dovranno essere identificati e comunicati in modo chiaro, separato dai risultati quantitativi.

Le fonti, le ipotesi rilevanti, la metodologia e i dati mancanti devono essere mostrati o documentati in modo verificabile. Eventuali contenuti sponsorizzati non devono essere presentati come risultati del motore statistico.
''';

  static const String regulatorySources = '''
RIFERIMENTI DI PROGETTAZIONE NORMATIVA

- Direttiva 2014/65/UE (MiFID II) e Regolamento delegato (UE) 2017/565: definizione di consulenza/raccomandazione personale.
- Regolamento (UE) 596/2014 (MAR), inclusa la disciplina delle informazioni che raccomandano o suggeriscono strategie d'investimento.
- Regolamento (UE) 2016/679 (GDPR), in particolare gli obblighi informativi.
- Norme Google Play su dati utente, Financial features declaration e servizi finanziari.

Questi riferimenti spiegano le scelte di progettazione, ma non sostituiscono una valutazione legale professionale sul modello commerciale concreto, sui mercati target e sulle funzionalità effettivamente pubblicate.
''';
}
