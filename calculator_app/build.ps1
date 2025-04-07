param (
    [switch]$Watch,
    [switch]$Clean,
    [switch]$CompileCommands,
    [switch]$RebuildAll
)

function Check-Command($command) {
    return $null -ne (Get-Command $command -ErrorAction SilentlyContinue)
}

function Ask-User($message) {
    $response = Read-Host "$message (y/n)"
    return $response -match '^[Yy]'
}

function Check-Prerequisites {
    Write-Host "`n>> Verifica prerequisiti..." -ForegroundColor Cyan

    if (Check-Command 'cmake') {
        Write-Host "OK: CMake è installato." -ForegroundColor Green
    } else {
        Write-Host "ERRORE: CMake non è installato." -ForegroundColor Red
        if (Ask-User "Vuoi installarlo ora tramite winget?") {
            winget install Kitware.CMake -e
            if (-not (Check-Command 'cmake')) {
                Write-Host "ERRORE: Installazione fallita o CMake non è nel PATH." -ForegroundColor Red
                return $false
            }
        } else {
            Write-Host "Interrompo. Installa CMake e riprova." -ForegroundColor Yellow
            return $false
        }
    }

    $gppPath = Get-Command 'g++.exe' -ErrorAction SilentlyContinue
    if ($gppPath -and ($gppPath.Source -like '*msys*')) {
        Write-Host "OK: Compilatore C++ MSYS2 rilevato: $($gppPath.Source)" -ForegroundColor Green
    } else {
        Write-Host "ERRORE: Compilatore C++ MSYS2 non trovato." -ForegroundColor Red
        if (Ask-User "Vuoi installare MSYS2 ora tramite winget?") {
            winget install MSYS2.MSYS2 -e
            Write-Host "Dopo l'installazione, aggiungi MSYS2 al PATH e installa 'base-devel'." -ForegroundColor Yellow
            return $false
        } else {
            Write-Host "Interrompo. Installa MSYS2 e riprova." -ForegroundColor Yellow
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

    $needsConfigure = $ForceRebuild -or !(Test-Path 'build') -or $GenerateCompileCommands
    $cmakeConfigOptions = @('-S', '.', '-B', 'build')

    if ($GenerateCompileCommands) {
        $cmakeConfigOptions = $cmakeConfigOptions + '-DCMAKE_EXPORT_COMPILE_COMMANDS=ON' + '-G' + '"MSYS Makefiles"'
    }

    if ($needsConfigure) {
        Write-Host "`n>> Configurazione del progetto..." -ForegroundColor Cyan
        & cmake $cmakeConfigOptions
        if ($LASTEXITCODE -ne 0) {
            Write-Host "ERRORE: Configurazione CMake fallita." -ForegroundColor Red
            return $false
        }
    }

    Write-Host "`n>> Compilazione del progetto..." -ForegroundColor Cyan
    & cmake --build build
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERRORE: Compilazione fallita." -ForegroundColor Red
        return $false
    }

    return $true
}

function Run-Tests {
    Write-Host "`n>> Esecuzione dei test..." -ForegroundColor Cyan
    Push-Location build
    try {
        & ctest --output-on-failure
        $testResult = $LASTEXITCODE
    } finally {
        Pop-Location
    }

    if ($testResult -eq 0) {
        Write-Host "OK: Tutti i test sono passati." -ForegroundColor Green
        return $true
    } else {
        Write-Host "ERRORE: Alcuni test sono falliti." -ForegroundColor Red
        return $false
    }
}

function Create-CompileCommandsLink {
    if (Test-Path "build/compile_commands.json") {
        if (Test-Path "compile_commands.json") {
            Remove-Item "compile_commands.json" -Force
        }
        
        # Copia diretta senza provare il link simbolico
        Copy-Item "build/compile_commands.json" -Destination "compile_commands.json" -Force
        Write-Host "File compile_commands.json copiato nella directory principale." -ForegroundColor Green
        
        # Verifica se il file è stato copiato correttamente
        if (Test-Path "compile_commands.json") {
            Write-Host "Configurazione IDE completata." -ForegroundColor Green
        } else {
            Write-Host "Errore nella copia del file compile_commands.json." -ForegroundColor Red
        }
    } else {
        Write-Host "File compile_commands.json non trovato nella directory build." -ForegroundColor Red
        Write-Host "Assicurati che CMake sia configurato con -DCMAKE_EXPORT_COMPILE_COMMANDS=ON" -ForegroundColor Yellow
    }
}

function Watch-ForChanges {
    param (
        [string[]]$Directories = @('src', 'test', 'CMakeLists.txt')
    )

    Write-Host "`n>> Modalità Watch attiva... Premi Ctrl+C per uscire." -ForegroundColor Cyan
    Write-Host "Monitoraggio: $($Directories -join ', ')" -ForegroundColor Cyan

    $watcher = New-Object System.IO.FileSystemWatcher
    $watcher.Path = $PWD.Path
    $watcher.IncludeSubdirectories = $true
    $watcher.EnableRaisingEvents = $true
    $watcher.Filter = '*.*'

    $action = {
        $path = $Event.SourceEventArgs.FullPath
        $changeType = $Event.SourceEventArgs.ChangeType
        $relativePath = $path.Substring($PWD.Path.Length + 1)

        $shouldTrigger = $Directories | Where-Object { $relativePath.StartsWith($_) }
        if ($shouldTrigger) {
            $timeStamp = Get-Date -Format 'HH:mm:ss'
            Write-Host '`n[$timeStamp] Modifica: ${changeType} -> ${relativePath}' -ForegroundColor Yellow
            Start-Sleep -Seconds 1
            Write-Host ">> Ricompilazione..." -ForegroundColor Yellow
            powershell -NoProfile -Command {
                if (Build-Project) { Run-Tests }
            }
        }
    }

    $handlers = @(
        Register-ObjectEvent -InputObject $watcher -EventName Changed -Action $action
        Register-ObjectEvent -InputObject $watcher -EventName Created -Action $action
        Register-ObjectEvent -InputObject $watcher -EventName Deleted -Action $action
        Register-ObjectEvent -InputObject $watcher -EventName Renamed -Action $action
    )

    try {
        while ($true) { Start-Sleep -Seconds 1 }
    } finally {
        $handlers | ForEach-Object { Unregister-Event -SourceIdentifier $_.Name }
    }
}

# === MAIN ===

if (-not (Check-Prerequisites)) { exit 1 }

if ($Clean) {
    Write-Host "`n>> Pulizia della directory build..." -ForegroundColor Cyan
    if (Test-Path 'build') {
        Remove-Item -Recurse -Force 'build'
    }
    Write-Host "OK: Pulizia completata." -ForegroundColor Green
    if (-not ($Watch -or $RebuildAll -or $CompileCommands)) {
        exit 0
    }
}

$buildSuccess = Build-Project -ForceRebuild:$RebuildAll -GenerateCompileCommands:$CompileCommands

if ($buildSuccess) {
    Run-Tests
    if ($CompileCommands) {
        Create-CompileCommandsLink
    }
    if ($Watch) {
        Watch-ForChanges
    }
}

exit ([int](-not $buildSuccess))
