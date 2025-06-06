# C++ Unit Testing Framework

Una soluzione pronta all'uso per unit testing in C++ che utilizza GoogleTest, CMake e PowerShell, progettata per permetterti di iniziare a scrivere test immediatamente indipendentemente dal progetto specifico.

## 📋 Panoramica

Questo framework è progettato per eliminare la configurazione ripetitiva richiesta per implementare unit testing nei progetti C++. La calcolatrice inclusa è semplicemente un esempio dimostrativo - il vero valore risiede nella struttura del progetto e negli script di automazione che ti permettono di concentrarti sulla scrittura dei test piuttosto che sulla configurazione dell'ambiente.

## 🎯 Obiettivo del Progetto

Fornire un framework di testing **immediato e pronto all'uso** per qualsiasi progetto C++ con:
- Nessuna configurazione richiesta per iniziare
- Supporto per progetti multipli indipendenti nella stessa directory
- Automazione completa del ciclo di sviluppo guidato dai test (TDD)
- Generazione di report di copertura del codice
- Supporto per CI/CD

## 🔧 Struttura del Framework

```
framework/
├── CMakeLists.txt       # Sistema di build configurato per il testing automatizzato
├── build.ps1            # Script di automazione completo
├── src/                 # Il tuo codice va qui
│   ├── example.h        # (esempio sostituibile con il tuo codice)
│   └── example.cpp      # (esempio sostituibile con il tuo codice)
└── test/                # I tuoi unit test vanno qui
    └── example_test.cpp # (esempio sostituibile con i tuoi test)
```

## 🔄 Flusso di Lavoro Test-Driven (TDD)

Con questo framework, puoi facilmente seguire un approccio TDD:

![Ciclo TDD](tdd-cycle.png


1. **Scrivi un test** in `test/my_test.cpp`
2. **Avvia lo script** con `.\build.ps1 -Watch`
3. **Osserva il test fallire**
4. **Implementa il codice** in `src/`
5. **Vedi il test passare** automaticamente quando lo script rileva le modifiche
6. **Ripeti** per ogni nuova funzionalità

## 🚀 Come Utilizzare il Framework

### 1. Clona o copia la struttura del framework

```bash
git clone https://github.com/GiancarloMartino/cpp_framework_unit_testing.git my-project
```

### 2. Sostituisci l'esempio con il tuo codice

- Sostituisci i file in `src/` con i tuoi file sorgente
- Aggiungi i tuoi test nella cartella `test/`

### 3. Esegui lo script di build

```powershell
.\build.ps1
```

È tutto! I tuoi test verranno compilati ed eseguiti automaticamente.

## 💻 Capacità dello Script PowerShell

Lo script `build.ps1` automatizza l'intero ciclo di sviluppo guidato dai test:

### Modalità di Utilizzo

- **Sviluppo Rapido**:
  ```powershell
  .\build.ps1 -Watch
  ```
  Rileva automaticamente le modifiche ai file e ricompila/esegue i test, ideale per TDD

- **Configurazione IDE**:
  ```powershell
  .\build.ps1 -CompileCommands
  ```
  Genera i file necessari per un'esperienza ottimale dell'editor con IntelliSense

- **Build Pulita**:
  ```powershell
  .\build.ps1 -Clean -RebuildAll
  ```
  Ricostruisce completamente il progetto e i test

- **Report di Copertura**:
  ```powershell
  .\build.ps1 -Coverage
  ```
  Genera report di copertura del codice per il progetto

- **Modalità CI/CD**:
  ```powershell
  .\build.ps1 -CI
  ```
  Configurazione specifica per ambienti di integrazione continua

- **Output Verboso**:
  ```powershell
  .\build.ps1 -Verbose
  ```
  Fornisce output di compilazione dettagliato

- **Configurazione Completa**:
  ```powershell
  .\build.ps1 -Clean -RebuildAll -CompileCommands -Coverage -Watch
  ```
  Setup completo con report di copertura e modalità di osservazione attiva

### Caratteristiche Principali

- **Rilevamento Ambiente**: Verifica e installa automaticamente le dipendenze necessarie
- **Testing Continuo**: Ricompila ed esegue i test ad ogni modifica dei file
- **Supporto Multi-Progetto**: Ogni copia del framework è autonoma e indipendente
- **Zero Configurazione**: Nessuna modifica al CMakeLists.txt richiesta per progetti semplici
- **Generazione Report**: Produce report di copertura del codice per un'analisi approfondita

## 📝 CMakeLists.txt Spiegato

Il file CMakeLists.txt è progettato per essere universale e non richiedere modifiche per la maggior parte dei progetti:

1. **Download Automatico di GoogleTest**:
   - Utilizza FetchContent per scaricare e configurare GoogleTest
   - Nessuna dipendenza esterna da installare manualmente

2. **Rilevamento Automatico dei Test**:
   - Rileva automaticamente tutti i file di test nella directory `test/`
   - Ogni file di test diventa un eseguibile separato

3. **Configurazione dei Percorsi di Inclusione**:
   - Configura automaticamente i percorsi di inclusione per test e librerie
   - Assicura che i test possano sempre accedere ai file header

4. **Indipendenza del Progetto**:
   - Funziona con qualsiasi struttura di codice sorgente
   - Non richiede convenzioni di denominazione specifiche

5. **Supporto per la Copertura del Codice**:
   - Opzione integrata per abilitare i report di copertura del codice
   - Compatibile con strumenti come gcov e lcov

## 🛠️ Requisiti

- CMake (3.14 o superiore)
- Un compilatore C++ (configurato per MSYS2/GCC su Windows)
- PowerShell 5.1 o superiore

## ❓ Troubleshooting

### Problemi Comuni

1. **Errore: "CMake non è installato"**
   - Soluzione: Installa CMake tramite `winget install Kitware.CMake -e`

2. **Errore: "Compilatore C++ MSYS2 non trovato"**
   - Soluzione: Installa MSYS2 tramite `winget install MSYS2.MSYS2 -e` e aggiungi il percorso al PATH

3. **File compile_commands.json non generato**
   - Soluzione: Esegui lo script come amministratore con `.\build.ps1 -CompileCommands`

4. **Test non trovati da CTest**
   - Soluzione: Assicurati che i test utilizzino le macro di GoogleTest come `TEST` o `TEST_F`

### Supporto per Linux/macOS

Per utilizzare il framework su Linux o macOS:

1. Sostituisci `build.ps1` con un equivalente script bash
2. Utilizza g++ o clang++ come compilatore
3. Usa `make` o `ninja` come sistema di build

## 📄 License

[MIT](LICENSE)