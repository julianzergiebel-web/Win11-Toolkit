# Win11-Toolkit V0.0.6-BETA
Ein leichtgewichtiges All-in-One Wartungs- &amp; Diagnose-Tool für Windows 11. Mit moderner PowerShell Dark-GUI zur einfachen Bereinigung von Temp-Dateien, DNS-Reset, SFC- &amp; DISM-Systemreparatur, Erstellung von Akku-Berichten und Anzeige von Hardware-Infos. Keine Installation nötig, startet direkt mit Admin-Rechten.

# 🛠️ Windows 11 Toolkit

Ein leichtgewichtiges, modernes Open-Source-Tool zur Systembereinigung, Wartung und Diagnose unter Windows 11. 

Das Tool kommt als hybrides CMD/PowerShell-Skript – **keine Installation erforderlich**. Es fordert automatisch die nötigen Administratorrechte an und startet eine dunkle, übersichtliche Windows 11 GUI.

---

## ✨ Features

- 🧹 **Temp-Cleaner:** Löscht gefahrlos temporäre System- und Benutzerdateien und zeigt den freigegebenen Speicherplatz an.
- 🌐 **Netzwerk & DNS Reset:** Leert den DNS-Cache (`flushdns`) und registriert die DNS-Einstellungen neu.
- 🩺 **System-Reparatur:**
  - **SFC-Scan:** Überprüft und repariert beschädigte Windows-Systemdateien (`sfc /scannow`).
  - **DISM Image-Check:** Prüft den Zustand des Komponentenspeichers (`/ScanHealth`).
- 🔋 **Akkubericht:** Erstellt einen detaillierten HTML-Energiebericht auf dem Desktop (für Laptops/Tablets).
- 📊 **System-Info:** Schnelle Übersicht zu OS-Version, CPU, freiem Arbeitsspeicher (RAM) und Systemlaufzeit.
- 🎨 **Modernes Dark UI:** Integrierte PowerShell Forms Benutzeroberfläche im Windows 11 Design mit Live-Konsole/Logging.

---

## ⚠️ Hinweis zur Sicherheit

Das Skript nutzt ausschließlich native Windows-Tools (`ipconfig`, `sfc`, `dism`, `powercfg`, `Get-CimInstance`). Es werden keine externen Programme installiert oder fremde Abhängigkeiten benötigt.

---

# Version 0.0.6-BETA 

### Weiter betsehende Warnings / Infos 

Infos: 
- [Write-Log-Aufruf vor Initialisierung des Formular-Handles](https://github.com/julianzergiebel-web/Win11-Toolkit/issues/12)
- [Fehlerhafte Eingabeumlenkung in Batch-Headerzeile <# :](https://github.com/julianzergiebel-web/Win11-Toolkit/issues/11)

Warnings: 
- [Falsch-positive Erfolgsmeldung beim Akku-/Energiebericht durch alte Berichtdateien](https://github.com/julianzergiebel-web/Win11-Toolkit/issues/8)
- [Parsing-Fehler bei Skriptpfaden mit einfachen Anführungszeichen](https://github.com/julianzergiebel-web/Win11-Toolkit/issues/10)
- [Falsche Erfolgsmeldung durch fehlende Exit-Code-Prüfung (SFC & DISM)](https://github.com/julianzergiebel-web/Win11-Toolkit/issues/9)

---

### Behobene Bugs

Bugs: 
- [Fehlerhafte Größenberechnung und verwaiste Exceptions bei der Temp-Bereinigung](https://github.com/julianzergiebel-web/Win11-Toolkit/issues/7)
- [Einfrieren der Benutzeroberfläche (GUI-Freeze) durch blockierendes ReadLine()](https://github.com/julianzergiebel-web/Win11-Toolkit/issues/6)
- [Deadlock-Gefahr durch unvollständige Stream-Umleitung von StandardError](https://github.com/julianzergiebel-web/Win11-Toolkit/issues/5)
- [Verlust von Prozessausgaben durch Schleifenabbruch bei while (-not $proc.HasExited)](https://github.com/julianzergiebel-web/Win11-Toolkit/issues/4)
- [Unsichtbare Benutzeroberfläche durch -WindowStyle Hidden mit Application::Run](https://github.com/julianzergiebel-web/Win11-Toolkit/issues/3)
- [Syntaxfehler durch reservierten Parameternamen $args in PowerShell](https://github.com/julianzergiebel-web/Win11-Toolkit/issues/2)
