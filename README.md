# Win11-Toolkit
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
