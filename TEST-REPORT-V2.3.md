# Test report v2.3

Data: 25/08/2026

## Backend locale

- `python -m py_compile *.py providers/*.py api/*.py tests/*.py`: **SUPERATO**
- `python release_verification.py`: **SUPERATO** (`RELEASE_VERIFICATION_OK`)
- suite pytest completa: **31/31 SUPERATI**

Test v2.3 specifici:

1. regressione APP/AppLovin-like nel Bulk Global Light Scanner;
2. core exchange globale preservato anche con vecchie env Render ristrette;
3. cash runway con FCF positivo trattato come non applicabile;
4. Confidence ridotta quando manca il contesto catalizzatore;
5. finestre prezzo calendar-based + min/max/drawdown sulla serie completa;
6. selezione completa di 300 Deep su universo sintetico da 20.000 titoli;
7. riconciliazione automatica di un caso NVDA con prezzo/multipli/capitalizzazione incoerenti;
8. quotazione secondaria: multipli price-dependent esclusi quando non riconciliabili;
9. ricerca ticker: quotazione primaria preferita rispetto alle listing secondarie;
10. intraday 1G/5G: campi null/NaN sanitizzati senza generare errori JSON/500;
11. browsing delle fasce Light: un universo da 20.000 può mostrare anomalie normali/moderate non ancora Deep, con analisi Deep on-demand all'apertura;
12. normalizzazione vecchie env NASDAQ/NYSE/AMEX/BATS verso il Bulk exchange EODHD `US`;
13. scheda/grafico USA: preferenza per WebSocket realtime con fallback alla quota REST ritardata.

## App Flutter

La ZIP contiene il workflow GitHub che esegue automaticamente:

- `flutter pub get`;
- `flutter analyze`;
- `flutter test`;
- `flutter build apk --release`.

Nel container di preparazione non è installato Flutter, quindi non dichiariamo
un build APK locale che non è stato realmente eseguito. Il repository contiene
i test Flutter v2.3 e il workflow blocca l'APK se analyze/test/build falliscono.

## Provider reale

La release non contiene la chiave EODHD. Dopo il deploy usa la chiave già
configurata su Render. La v2.3 separa quotazione primaria/secondaria, valuta di
listing e valuta dei fondamentali e applica controlli di coerenza prima di
mostrare market cap, P/E, P/S e FCF yield.

I contatori `Universo / Candidati Light / Deep` mostrano quante azioni sono
state effettivamente passate dai diversi livelli dello scanner. Il realtime USA
è on-demand: non viene usato per migliaia di titoli durante il Global Light
Scanner.
