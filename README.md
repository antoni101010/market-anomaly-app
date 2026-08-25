# Market Anomaly App 2.0

App Flutter/Android coordinata con Market Anomaly API 2.0.

Funzioni principali: dashboard filtrabile, ricerca globale, dettaglio con
grafico 1G/5G/1M/6M/1A/5A, valuta/fonte/orario prezzo, watchlist, storico,
feedback al modello e più configurazioni personali salvate.

Il workflow `.github/workflows/build_apk.yml` esegue:

```text
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

L'artefatto finale è `market-anomaly-apk/app-release.apk`. Le chiavi dei
provider finanziari non devono essere inserite nell'app: restano sul backend.
Per istruzioni complete usa `LEGGIMI-PRIMA.md` nella cartella superiore.
