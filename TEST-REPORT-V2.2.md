# Test report — Market Anomaly v2.2.0

Data verifica: 25 agosto 2026.

## Backend Python

Comandi eseguiti sul pacchetto finale:

```bash
python -m compileall -q market-anomaly-api-main
cd market-anomaly-api-main
pytest -q
```

Esito: **16 passed**.

La suite comprende i test precedenti v2.1 e i nuovi test v2.2 per:

- distinzione tra pressione valutativa elevata e moderata;
- calcolo del Global Market Tension Engine con copertura e componenti;
- combinazione region-balanced/cap-weighted;
- tracciamento dell'accettazione legale con identificatore hash;
- cancellazione del record pseudonimo;
- endpoint legali versionati.

## Flutter

Sono stati aggiunti test di parsing per `market_tension` e coerenza dei testi legali v2.2. Il repository contiene già un workflow GitHub che esegue, con Flutter stable:

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

Nell'ambiente di generazione della ZIP non è installato Flutter SDK; per questo la compilazione APK non è stata eseguita localmente. È stata comunque eseguita una verifica lessicale di bilanciamento su tutti i file Dart e la configurazione YAML dei workflow è stata validata.
