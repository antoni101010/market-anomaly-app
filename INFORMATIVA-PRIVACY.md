# Google Play — checklist v2.2

Questa cartella contiene i testi già integrati nell'app e le pagine web statiche pronte da pubblicare. Le dichiarazioni nella Play Console devono comunque corrispondere all'infrastruttura realmente usata al momento della pubblicazione.

## Posizionamento del prodotto

- Strumento di ricerca e analisi statistica.
- Nessuna profilazione finanziaria personale basata su reddito, patrimonio, obiettivi o tolleranza alle perdite.
- Nessuna esecuzione ordini o gestione di portafoglio.
- Nessun linguaggio utente “compra/vendi/mantieni/prezzo obiettivo”.
- Financial features declaration da compilare in modo coerente con le funzioni effettivamente pubblicate.

## Dati e privacy

- Privacy Policy inclusa nell'app e come pagina HTML in `legal-web/privacy.html`.
- Record di accettazione: identificatore d'installazione casuale inviato al server e memorizzato solo come SHA-256, versione Termini/Privacy, timestamp, versione app e piattaforma.
- Preferenze e configurazione restano localmente tramite SharedPreferences.
- Nessun advertising personalizzato, marketing diretto o analytics facoltativo incluso in questa build.
- Cancellazione del record pseudonimo disponibile da Impostazioni > Legale e privacy > Elimina dati di installazione.
- Pagina web informativa sulla cancellazione inclusa in `legal-web/data-deletion.html`.

## Prima della pubblicazione

Verificare soltanto elementi esterni al codice: URL pubblico HTTPS della Privacy Policy, dichiarazione Data safety coerente con hosting/log/provider reali, Financial features declaration, licenza commerciale dei dati, eventuali abbonamenti reali e revisione professionale dei testi rispetto al modello commerciale effettivo.
