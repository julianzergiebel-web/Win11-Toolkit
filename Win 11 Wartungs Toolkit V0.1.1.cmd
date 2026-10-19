<# : 2>nul
@echo off
setlocal
set "SCRIPT_PATH=%~f0"
set "SCRIPT_PATH_ESC=%SCRIPT_PATH:'=''%"

:: -------------------------------------------------------------------------------
:: 1. Admin-Prüfung & Selbsterhöhung (UAC-Prompt bei Bedarf)
:: -------------------------------------------------------------------------------
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process cmd -ArgumentList '/c \"\"%SCRIPT_PATH_ESC%\"\"' -Verb RunAs"
    exit /b
)

:: -------------------------------------------------------------------------------
:: 2. PowerShell GUI im Hintergrund starten (kein CMD-Fenster bleibt offen)
:: -------------------------------------------------------------------------------
start "" powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -Command "& ([ScriptBlock]::Create((Get-Content -LiteralPath $env:SCRIPT_PATH -Raw -Encoding UTF8)))"
exit /b
#>

# ===============================================================================
# AB HIER: POWERSHELL & WINDOWS FORMS GUI (Windows 11 Modern Dark Style)
# ===============================================================================
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

# --- Hauptfenster konfigurieren ---
$mainForm = New-Object System.Windows.Forms.Form
$mainForm.Text = "Windows 11 Wartungs- & Diagnose-Toolkit"
$mainForm.Size = New-Object System.Drawing.Size(900, 580)
$mainForm.StartPosition = "CenterScreen"
$mainForm.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
$mainForm.MaximizeBox = $false
$mainForm.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#202020")
$mainForm.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#F3F3F3")
$mainForm.Font = New-Object System.Drawing.Font("Segoe UI", 9.5)

# --- Header-Leiste ---
$headerPanel = New-Object System.Windows.Forms.Panel
$headerPanel.Location = New-Object System.Drawing.Point(0, 0)
$headerPanel.Size = New-Object System.Drawing.Size(900, 65)
$headerPanel.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#272727")
$mainForm.Controls.Add($headerPanel)

$headerTitle = New-Object System.Windows.Forms.Label
$headerTitle.Text = "Windows 11 System-Toolkit"
$headerTitle.Font = New-Object System.Drawing.Font("Segoe UI", 13, [System.Drawing.FontStyle]::Bold)
$headerTitle.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#60CDFF")
$headerTitle.Location = New-Object System.Drawing.Point(20, 10)
$headerTitle.AutoSize = $true
$headerPanel.Controls.Add($headerTitle)

$headerSub = New-Object System.Windows.Forms.Label
$headerSub.Text = "Angemeldet: $env:USERNAME  |  Gerät: $env:COMPUTERNAME  |  Status: Administrator"
$headerSub.Font = New-Object System.Drawing.Font("Segoe UI", 8.5)
$headerSub.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#9E9E9E")
$headerSub.Location = New-Object System.Drawing.Point(22, 36)
$headerSub.AutoSize = $true
$headerPanel.Controls.Add($headerSub)

# --- Live-Log / Ausgabe-Konsole ---
$logBox = New-Object System.Windows.Forms.RichTextBox
$logBox.Location = New-Object System.Drawing.Point(280, 80)
$logBox.Size = New-Object System.Drawing.Size(590, 410)
$logBox.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#141414")
$logBox.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#CCCCCC")
$logBox.Font = New-Object System.Drawing.Font("Consolas", 9.5)
$logBox.ReadOnly = $true
$logBox.BorderStyle = [System.Windows.Forms.BorderStyle]::None
$mainForm.Controls.Add($logBox)

# --- Statuszeile unten ---
$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Text = "Bereit."
$statusLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$statusLabel.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#888888")
$statusLabel.Location = New-Object System.Drawing.Point(280, 505)
$statusLabel.AutoSize = $true
$mainForm.Controls.Add($statusLabel)

# --- Button: Log leeren ---
$btnClearLog = New-Object System.Windows.Forms.Button
$btnClearLog.Text = "Log leeren"
$btnClearLog.Size = New-Object System.Drawing.Size(100, 26)
$btnClearLog.Location = New-Object System.Drawing.Point(770, 500)
$btnClearLog.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#2D2D30")
$btnClearLog.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#CCCCCC")
$btnClearLog.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnClearLog.FlatAppearance.BorderSize = 0
$btnClearLog.Font = New-Object System.Drawing.Font("Segoe UI", 8.5)
$btnClearLog.Cursor = [System.Windows.Forms.Cursors]::Hand
$btnClearLog.Add_Click({ $logBox.Clear(); Write-Log "Log zurückgesetzt." })
$mainForm.Controls.Add($btnClearLog)

# ===============================================================================
# HILFSFUNKTIONEN (Logging & Task Runner)
# ===============================================================================
$buttonList = New-Object System.Collections.Generic.List[System.Windows.Forms.Button]

function Write-Log([string]$message, [string]$colorHex = "#CCCCCC") {
    $time = (Get-Date).ToString("HH:mm:ss")
    $logBox.SelectionStart = $logBox.TextLength
    $logBox.SelectionLength = 0
    $logBox.SelectionColor = [System.Drawing.ColorTranslator]::FromHtml("#60CDFF")
    $logBox.AppendText("[$time] ")
    $logBox.SelectionColor = [System.Drawing.ColorTranslator]::FromHtml($colorHex)
    $logBox.AppendText("$message`r`n")
    $logBox.ScrollToCaret()
    [System.Windows.Forms.Application]::DoEvents()
}

function Run-ProcessStream([string]$fileName, [string]$arguments) {
    Write-Log "Befehl: $fileName $arguments" "#888888"
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $fileName
    $psi.Arguments = $arguments
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true
    
    $proc = [System.Diagnostics.Process]::Start($psi)
    
    $outTask = $proc.StandardOutput.ReadLineAsync()
    $errTask = $proc.StandardError.ReadLineAsync()
    $outDone = $false
    $errDone = $false

    while ((-not $proc.HasExited) -or (-not $outDone) -or (-not $errDone)) {
        $hasWork = $false

        if (-not $outDone -and $outTask.IsCompleted) {
            $line = $outTask.Result
            if ($line -ne $null) {
                Write-Log "  $line" "#A0A0A0"
                $outTask = $proc.StandardOutput.ReadLineAsync()
                $hasWork = $true
            } else {
                $outDone = $true
            }
        }

        if (-not $errDone -and $errTask.IsCompleted) {
            $errLine = $errTask.Result
            if ($errLine -ne $null) {
                Write-Log "  $errLine" "#A0A0A0"
                $errTask = $proc.StandardError.ReadLineAsync()
                $hasWork = $true
            } else {
                $errDone = $true
            }
        }

        [System.Windows.Forms.Application]::DoEvents()

        if (-not $hasWork) {
            [System.Threading.Thread]::Sleep(20)
        }
    }
    $proc.WaitForExit()
    return $proc.ExitCode
}

function Execute-Task([string]$taskName, [scriptblock]$action) {
    $statusLabel.Text = "Führe aus: $taskName..."
    $statusLabel.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#60CDFF")
    foreach ($b in $buttonList) { $b.Enabled = $false }
    [System.Windows.Forms.Application]::DoEvents()

    try {
        & $action
    } catch {
        Write-Log "[FEHLER] $($_.Exception.Message)" "#FF6B68"
    } finally {
        $statusLabel.Text = "Bereit."
        $statusLabel.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#888888")
        foreach ($b in $buttonList) { $b.Enabled = $true }
        [System.Windows.Forms.Application]::DoEvents()
    }
}

function Add-ModernButton([string]$text, [int]$yPos, [scriptblock]$clickEvent) {
    $btn = New-Object System.Windows.Forms.Button
    $btn.Text = "  $text"
    $btn.Location = New-Object System.Drawing.Point(20, $yPos)
    $btn.Size = New-Object System.Drawing.Size(240, 44)
    $btn.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#2D2D30")
    $btn.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#FFFFFF")
    $btn.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $btn.FlatAppearance.BorderSize = 1
    $btn.FlatAppearance.BorderColor = [System.Drawing.ColorTranslator]::FromHtml("#383838")
    $btn.Font = New-Object System.Drawing.Font("Segoe UI", 9.5)
    $btn.Cursor = [System.Windows.Forms.Cursors]::Hand
    $btn.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft

    # Windows 11 Hover-Effekt
    $btn.Add_MouseEnter({
        if ($this.Enabled) { $this.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#3A3A3D") }
    })
    $btn.Add_MouseLeave({
        if ($this.Enabled) { $this.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#2D2D30") }
    })
    $btn.Add_Click($clickEvent)

    $mainForm.Controls.Add($btn)
    $buttonList.Add($btn)
}

# ===============================================================================
# BUTTONS & WARTUNGSAUFGABEN
# ===============================================================================

# 1. Netzwerk & DNS Reset
Add-ModernButton "1. Netzwerk & DNS Reset" 80 {
    Execute-Task "Netzwerk-Reset" {
        Write-Log "=== Starte DNS- & Netzwerk-Bereinigung ===" "#60CDFF"
        [void](Run-ProcessStream "ipconfig" "/flushdns")
        [void](Run-ProcessStream "ipconfig" "/registerdns")
        Write-Log "[OK] DNS-Auflösungscache erfolgreich geleert." "#57C785"
    }
}

# 2. Temp-Dateien leeren
Add-ModernButton "2. Temp-Dateien bereinigen" 135 {
    Execute-Task "Temp-Bereinigung" {
        Write-Log "=== Bereinige temporäre System- & Benutzerdateien ===" "#60CDFF"
        $paths = @($env:TEMP, "$env:windir\Temp")
        $deleted = 0
        $freedBytes = 0

        foreach ($p in $paths) {
            Write-Log "Scanne Ordner: $p"
            # Zuerst Dateien verarbeiten (Größe korrekt erfassen und löschen)
            Get-ChildItem -Path $p -Recurse -Force -File -ErrorAction SilentlyContinue | ForEach-Object {
                try {
                    $len = $_.Length
                    Remove-Item -LiteralPath $_.FullName -Force -ErrorAction Stop
                    $deleted++
                    $freedBytes += $len
                } catch {
                    # Gesperrte/aktive Dateien sicher ignorieren
                }
            }

            # Anschließend leere Unterordner von unten nach oben löschen
            Get-ChildItem -Path $p -Recurse -Force -Directory -ErrorAction SilentlyContinue |
                Sort-Object -Property FullName -Descending | ForEach-Object {
                    try {
                        Remove-Item -LiteralPath $_.FullName -Force -ErrorAction Stop
                        $deleted++
                    } catch {
                        # Gesperrte oder nicht leere Ordner ignorieren
                    }
                }
        }
        $mb = [math]::Round($freedBytes / 1MB, 2)
        Write-Log "[OK] $deleted Elemente gelöscht ($mb MB freigegeben)." "#57C785"
    }
}

# 3. Systemdateien prüfen (SFC)
Add-ModernButton "3. Systemdateien prüfen (SFC)" 190 {
    Execute-Task "SFC Systemprüfung" {
        Write-Log "=== Starte System File Checker (SFC) ===" "#60CDFF"
        Write-Log "Dieser Vorgang kann einige Minuten dauern..." "#E0E0E0"
        $exitCode = Run-ProcessStream "sfc.exe" "/scannow"
        if ($exitCode -eq 0) {
            Write-Log "[OK] SFC-Prüfung erfolgreich beendet." "#57C785"
        } else {
            Write-Log "[FEHLER] SFC-Prüfung mit Exit-Code $exitCode beendet." "#FF6B68"
        }
    }
}

# 4. DISM Komponentenspeicher-Prüfung
Add-ModernButton "4. DISM Image-Check" 245 {
    Execute-Task "DISM Check" {
        Write-Log "=== Starte DISM Komponentenspeicher-Prüfung ===" "#60CDFF"
        $exitCode = Run-ProcessStream "dism.exe" "/Online /Cleanup-Image /ScanHealth"
        if ($exitCode -eq 0) {
            Write-Log "[OK] DISM-Prüfung erfolgreich abgeschlossen." "#57C785"
        } else {
            Write-Log "[FEHLER] DISM-Prüfung mit Exit-Code $exitCode beendet." "#FF6B68"
        }
    }
}

# 5. Energie- & Akku-Bericht
Add-ModernButton "5. Akku-/Energiebericht" 300 {
    Execute-Task "Energiebericht" {
        Write-Log "=== Generiere Akku- & Energiebericht ===" "#60CDFF"
        $reportPath = "$env:USERPROFILE\Desktop\battery_report.html"
        if (Test-Path -LiteralPath $reportPath) {
            Remove-Item -LiteralPath $reportPath -Force -ErrorAction SilentlyContinue
        }
        $exitCode = Run-ProcessStream "powercfg.exe" "/batteryreport /output `"$reportPath`""
        
        if ($exitCode -eq 0 -and (Test-Path -LiteralPath $reportPath)) {
            Write-Log "[OK] Bericht gespeichert auf dem Desktop: $reportPath" "#57C785"
            Start-Process $reportPath
        } else {
            Write-Log "[HINWEIS] Kein Akku gefunden (normal bei stationären Desktop-PCs)." "#FFD166"
        }
    }
}

# 6. System-Informationen abrufen
Add-ModernButton "6. System-Informationen" 355 {
    Execute-Task "System-Info" {
        Write-Log "=== Hardware & Systemübersicht ===" "#60CDFF"
        $os = Get-CimInstance Win32_OperatingSystem
        $cs = Get-CimInstance Win32_ComputerSystem
        $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
        $uptime = (Get-Date) - $os.LastBootUpTime
        $ramTotal = [math]::Round($cs.TotalPhysicalMemory / 1GB, 2)
        $ramFree = [math]::Round($os.FreePhysicalMemory / 1MB, 2)

        Write-Log "OS:         $($os.Caption) (Build $($os.BuildNumber))"
        Write-Log "CPU:        $($cpu.Name)"
        Write-Log "RAM:        $ramFree GB frei von $ramTotal GB"
        Write-Log "Laufzeit:   $($uptime.Days) Tage, $($uptime.Hours) Std, $($uptime.Minutes) Min"
        Write-Log "[OK] System-Info geladen." "#57C785"
    }
}

# Initialer Willkommens-Text im Log (nach Initialisierung des Formular-Handles)
$mainForm.Add_Shown({
    Write-Log "Windows 11 Wartungs-Toolkit initialisiert." "#60CDFF"
    Write-Log "Wähle eine Aktion aus dem linken Menü, um zu starten.`r`n"
})

# Formular starten
[void]$mainForm.ShowDialog()
