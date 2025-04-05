function Check-Command($command) {
    $null -ne (Get-Command $command -ErrorAction SilentlyContinue)
}

function Ask-User($message) {
    $response = Read-Host "$message (y/n)"
    return $response -match '^[Yy]'
}

Write-Host 'Verifica prerequisiti...' -ForegroundColor Cyan

# 1. Check CMake
if (Check-Command "cmake") {
    Write-Host 'CMake è installato.' -ForegroundColor Green
} else {
    Write-Host 'CMake non è installato.' -ForegroundColor Red
    if (Ask-User 'Vuoi installarlo ora tramite winget?') {
        winget install Kitware.CMake -e
    } else {
        Write-Host 'Interrompo lo script. Installa CMake e riprova.' -ForegroundColor Yellow
        exit 1
    }
}

# 2. Check compilatore C++ MSYS2 (es. g++.exe)
$gppPath = Get-Command "g++.exe" -ErrorAction SilentlyContinue
if ($gppPath -and ($gppPath.Source -like "*msys*")) {
    Write-Host 'Compilatore C++ MSYS2 rilevato: $($gppPath.Source)' -ForegroundColor Green
} else {
    Write-Host 'Compilatore C++ MSYS2 non trovato.' -ForegroundColor Red
    if (Ask-User 'Vuoi installare MSYS2 ora tramite winget?') {
        winget install MSYS2.MSYS2 -e
        Write-Host 'Dopo installazione, aggiungi MSYS2 al PATH e installa il gruppo base-devel usando pacman.' -ForegroundColor Yellow
        exit 1
    } else {
        Write-Host 'Interrompo lo script. Installa il compilatore C++ MSYS2 e riprova.' -ForegroundColor Yellow
        exit 1
    }
}

Write-Host 'Tutti i prerequisiti sono soddisfatti. Procedo con la build' -ForegroundColor Green

# 3. Configura il progetto CMake (crea la cartella build e genera i file necessari)
cmake -S . -B build

# 4. Compila il progetto usando i file generati nella cartella build
cmake --build build

# 5. Entra nella cartella build, ed esegui ctest solo se cd è andato a buon fine
Set-Location build
if ($?) {
    ctest
}

# 6. (Opzionale) Torna indietro alla directory originale
Set-Location ..