# Controlla i parametri
param (
    [switch]$Watch,
    [switch]$Clean,
    [switch]$CompileCommands,
    [switch]$RebuildAll
)

function Check-Command($command) {
    $null -ne (Get-Command $command -ErrorAction SilentlyContinue)
}

function Ask-User($message) {
    $response = Read-Host "$message (y/n)"
    return $response -match '^[Yy]'
}

function Check-Prerequisites {
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
            return $false
        }
    }

    # 2. Check compilatore C++ MSYS2
    $gppPath = Get-Command "g++.exe" -ErrorAction SilentlyContinue
    if ($gppPath -and ($gppPath.Source -like "*msys*")) {
        Write-Host "Compilatore C++ MSYS2 rilevato: $($gppPath.Source)" -ForegroundColor Green
    } else {
        Write-Host 'Compilatore C++ MSYS2 non trovato.' -ForegroundColor Red
        if (Ask-User 'Vuoi installare MSYS2 ora tramite winget?') {
            winget install MSYS2.MSYS2 -e
            Write-Host 'Dopo installazione, aggiungi MSYS2 al PATH e installa il gruppo base-devel usando pacman.' -ForegroundColor Yellow
            return $false
        } else {
            Write-Host 'Interrompo lo script. Installa il compilatore C++ MSYS2 e riprova.' -ForegroundColor Yellow
            return $false
        }
    }

    return $true
}

function Build-Project {
    param (
        [switch]$ForceRebuild,
        [switch]$GenerateCompileCommands
    )

    # Decidi se riconfigurare basandoti sui parametri o sullo stato della cartella build
    $needsConfigure = $ForceRebuild -or !(Test-Path "build")
    
    # Configura opzioni di CMake
    $cmakeConfigOptions = @("-S", ".", "-B", "build")
    if ($GenerateCompileCommands) {
        $cmakeConfigOptions += "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON"
    }
    
    if ($needsConfigure) {
        Write-Host "Configurazione del progetto..." -ForegroundColor Cyan
        & cmake $cmakeConfigOptions
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Errore nella configurazione del progetto CMake." -ForegroundColor Red
            return $false
        }
    }

    Write-Host "Compilazione del progetto..." -ForegroundColor Cyan
    & cmake --build build
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Errore nella compilazione del progetto." -ForegroundColor Red
        return $false
    }

    return $true
}

function Run-Tests {
    Write-Host "Esecuzione dei test..." -ForegroundColor Cyan
    Push-Location build
    ctest --output-on-failure
    $testResult = $LASTEXITCODE
    Pop-Location
    
    if ($testResult -eq 0) {
        Write-Host "Tutti i test sono passati!" -ForegroundColor Green
        return $true
    } else {
        Write-Host "Alcuni test sono falliti." -ForegroundColor Red
        return $false
    }
}

function Create-CompileCommandsLink {
    if (Test-Path "build/compile_commands.json") {
        if (Test-Path "compile_commands.json") {
            Remove-Item "compile_commands.json" -Force
        }
        
        # Tentativo di creare un link simbolico
        try {
            New-Item -ItemType SymbolicLink -Path "compile_commands.json" -Target "build/compile_commands.json" -ErrorAction Stop
            Write-Host "Link simbolico a compile_commands.json creato." -ForegroundColor Green
        } catch {
            # Se il link simbolico fallisce, copia il file
            Copy-Item "build/compile_commands.json" -Destination "compile_commands.json"
            Write-Host "File compile_commands.json copiato (i link simbolici richiedono privilegi amministrativi)." -ForegroundColor Yellow
        }
    }
}

function Watch-ForChanges {
    param (
        [string[]]$Directories = @("src", "test", "CMakeLists.txt")
    )
    
    Write-Host "Avvio modalità watch... Premi Ctrl+C per uscire." -ForegroundColor Cyan
    Write-Host "Monitoraggio delle directory: $($Directories -join ', ')" -ForegroundColor Cyan
    
    try {
        $watcher = New-Object System.IO.FileSystemWatcher
        $watcher.Path = $PWD.Path
        $watcher.IncludeSubdirectories = $true
        $watcher.EnableRaisingEvents = $true
        
        $action = {
            $path = $Event.SourceEventArgs.FullPath
            $changeType = $Event.SourceEventArgs.ChangeType
            $timeStamp = Get-Date -Format "HH:mm:ss"
            
            Write-Host '[$timeStamp] File $changeType: $path' -ForegroundColor Yellow
            
            # Aspetta un attimo per evitare compilazioni multiple in rapida successione
            Start-Sleep -Seconds 1
            
            Write-Host "Ricompilazione automatica in corso..." -ForegroundColor Yellow
            # Esegui la build in un nuovo processo per evitare problemi con gli eventi
            Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -Command `"& {. '$PSCommandPath'; if (Build-Project) { Run-Tests }}`"" -NoNewWindow -Wait
        }
        
        # Registra gli eventi per ogni tipo di modifica
        $handlers = @()
        $handlers += Register-ObjectEvent -InputObject $watcher -EventName Changed -Action $action
        $handlers += Register-ObjectEvent -InputObject $watcher -EventName Created -Action $action
        $handlers += Register-ObjectEvent -InputObject $watcher -EventName Deleted -Action $action
        $handlers += Register-ObjectEvent -InputObject $watcher -EventName Renamed -Action $action
        
        # Filtra solo le directory che vogliamo monitorare
        $filter = {
            $relativePath = $_.FullPath.Substring($PWD.Path.Length + 1)
            foreach ($dir in $Directories) {
                if ($relativePath.StartsWith($dir)) {
                    return $true
                }
            }
            return $false
        }
        
        $watcher.Filter = "*.*"
        
        # Mantieni lo script in esecuzione finché non viene interrotto manualmente
        while ($true) {
            Start-Sleep -Seconds 1
        }
    }
    finally {
        # Pulisci gli handler quando si esce
        if ($handlers) {
            $handlers | ForEach-Object { Unregister-Event -SourceIdentifier $_.Name }
        }
    }
}

# Punto di ingresso principale dello script

# Controllo dei prerequisiti
if (-not (Check-Prerequisites)) {
    exit 1
}

# Gestisci la pulizia se richiesta
if ($Clean) {
    Write-Host "Pulizia della directory build..." -ForegroundColor Cyan
    if (Test-Path "build") {
        Remove-Item -Recurse -Force "build"
    }
    Write-Host "Pulizia completata." -ForegroundColor Green
    if ($Clean.IsPresent -and -not ($Watch.IsPresent -or $RebuildAll.IsPresent)) {
        exit 0
    }
}

# Build del progetto
$buildSuccess = Build-Project -ForceRebuild:$RebuildAll -GenerateCompileCommands:$CompileCommands

# Se la build ha avuto successo, esegui i test
if ($buildSuccess) {
    Run-Tests
}

# Se richiesto, passa alla modalità watch
if ($Watch -and $buildSuccess) {
    Watch-ForChanges
}

# Se richiesto, compila i comandi in json
if ($CompileCommands -and $buildSuccess) {
    Create-CompileCommandsLink
}