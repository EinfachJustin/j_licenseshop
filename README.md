# j_licenseshop

Kleines ESX-Skript für die Verwaltung von Lizenzen (Waffenschein, Führerschein etc.).

**Kurz (Deutsch):**
- Plugin für FiveM / ESX, benötigt `es_extended` und `oxmysql`.

**Installation**
1. Ordner `j_licenseshop` in `resources` kopieren.
2. In `server.cfg` eintragen: `ensure j_licenseshop`.
3. `config.default.lua` kopieren nach `config.lua` und Werte anpassen (Discord Webhook, ServerName, ...).
4. Datenbank: Tabelle `user_licenses` muss existieren (Schema/SQL nicht enthalten — übliche Struktur: `type`, `owner`).

**WICHTIG**
- Entferne niemals echte Webhooks/Passwörter bevor du das Repo veröffentlichst.
- `config.lua` ist in `.gitignore` eingetragen — verwende lokale `config.lua` für Secrets.

**Konfiguration**
- `Config.DiscordWebhook`: Discord-Webhook für Logs (optional). Setze diesen nur lokal.
- `Config.PoliceJobs`: Liste der Job-Namen, die Lizenzen ausstellen dürfen.

**Benutzung**
- Polizisten können über das Menü Lizenzen erteilen/entziehen.

**Lizenz**
- Dieses Projekt wird unter der MIT-Lizenz bereitgestellt (siehe `LICENSE`).

Wenn du möchtest, übernehme ich gern weitere Schritte (z.B. SQL-Create-Statements, Tests, oder ein Release-Template).
