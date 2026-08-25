# Market Anomaly App 2.3

App Flutter/Android per Market Anomaly API 2.3.

La home mostra separatamente **Universo**, **Candidati Light** e **Deep**. La
classifica predefinita è ordinata prima per forza dell'anomalia statistica; i
filtri permettono di includere movimenti normali, forti o molto forti.

La v2.3 corregge i periodi 1G/5G/1M/6M/1A/5A, rende leggibili fonti e stato dei
dati, elimina il badge `LIVE` fuorviante e usa `DATI REALI` quando il backend è
in produzione. Una quota può essere indicata come ritardata, ultima chiusura,
non recente, mercato chiuso oppure tempo reale verificato. Per le schede USA il
backend tenta il WebSocket realtime EODHD dell'All-In-One e ricade sulla quota
REST ritardata se il feed streaming non è disponibile.

La scheda titolo usa linguaggio statistico neutro: somiglianza con casi
storici, pattern storici comparabili, qualità/completezza dati, rischi e
catalizzatori. Non contiene istruzioni di acquisto/vendita o target price.

Il workflow `.github/workflows/build_apk.yml` esegue:

```text
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

Versione app: `2.3.0+23`.
