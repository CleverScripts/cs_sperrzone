# FiveM Sperrzonen-Skript

## Beschreibung
Das FiveM Sperrzonen-Skript ermöglicht Server-Administratoren die Definition und Verwaltung von Sperrzonen auf der Karte. Es bietet präzise Kontrolle über Spieleraktivitäten in bestimmten Bereichen.

## Hauptfunktionen
- Zonendefinition mit anpassbaren Parametern
- Unterstützung für mehrere Sperrzonen
- Automatische Spielerbenachrichtigungen
- Datenbankintegration für persistente Zonen

## Installation
1. Skript aus dem Release-Bereich herunterladen
2. Inhalt ins `resources`-Verzeichnis extrahieren
3. `ensure cs_sperrzone` zur `server.cfg` hinzufügen
4. Discord Webhook hinzufügen config.lua
5. SQL in die Datenbank hochladen: 
CREATE TABLE IF NOT EXISTS sperzonen (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    radius FLOAT NOT NULL,
    x FLOAT NOT NULL,
    y FLOAT NOT NULL,
    z FLOAT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
6. FiveM-Server neustarten oder Ressource laden

## Verwendung
- `/sperzone`: Neue Sperrzone erstellen (Config Anpassbar)
- `/sperzone`: Sperzonen verwalten / löschen (Config Anpassbar)

## Abhängigkeiten
- ESX Framework (optional)
- oxmysql oder ähnliche Datenbankressource

## Support

Bei Fragen oder Problemen wenden Sie sich bitte an unser Support-Team unter cleverschripts@gmail.com oder über Discord: https://discord.gg/HT9SJXQ9gC.

## Lizenz

Dieses Skript ist urheberrechtlich geschützt und darf nur mit Genehmigung von Clever Scripts verwendet werden. Unerlaubte Verbreitung oder Nutzung ist untersagt.

---

© 2024 Clever Scripts. Alle Rechte vorbehalten.
