# Odoo (18.0) — Source Install in a Minimal Docker Image

This repo shows how to run **Odoo from source** inside a Docker container using only the **minimal system packages**, wire it to **PostgreSQL via docker‑compose**, and **switch environments (dev/prod)** using a simple `.env` file and config bindings.

> Goal: understand Odoo internals first (no heavy extras). You can add optional libs (wkhtmltopdf, image codecs, Node/rtlcss) later when you need a feature.

⚠️ Security Notice: The current base image scan reports 2 High vulnerabilities, 1 Medium, and 21 Low (0 Critical). Please review and update dependencies regularly.

---

## Contents

* [Prerequisites](#prerequisites)
* [Project Layout](#project-layout)
* [Environment Variables](#environment-variables)
* [Quick Start](#quick-start)
* [Common Commands](#common-commands)
* [Troubleshooting / Add‑ons later](#troubleshooting--add-ons-later)

---

## Prerequisites

* Docker & Docker Compose
* Git
* (Optional) VS Code with the **Docker** and **Dev Containers** extensions

---

## Project Layout

```
odoo-src/
├─ Dockerfile                  # minimal base (no wkhtmltopdf, no node, etc.)
├─ docker-compose.yml          # Odoo + Postgres
├─ .env                        # runtime vars & environment switching
├─ addons/                     # your custom addons (mounted into the container)
└─ config/
   ├─ odoo.dev.conf            # dev config (verbose logging / dev toggles)
   └─ odoo.prod.conf           # prod-ish config (quieter logs / worker-ready)
```

**We do not print the Dockerfile here** — it installs only the basic packages (e.g., `git`, `build-essential`, `libpq-dev`, `libldap2-dev`, `libsasl2-dev`), clones Odoo **18.0** source, installs `requirements.txt`, and runs `odoo-bin`.

---

## Environment Variables

Create a file named **`.env`** at the repo root. This file controls both the Odoo runtime and which config file to bind inside the container.

**.env (dev default)**

```env
# Database (dev defaults)
DB_PORT=5432
DB_USER=odoo
DB_PASSWORD=odoo
```

---

## Quick Start

1. **Clone & open** the folder in your editor/terminal.
2. **Create `.env`** with the dev defaults above (or just copy the snippet).
3. **Start services**:

   ```bash
   docker compose up -d --build
   ```
4. **Access Odoo** at `http://localhost:8069`.

   * When prompted for the **Master Password**, it is the env var `ADMIN_PASS` you set in `.env`.
   * Create your first database.

### What the compose file does (in short)

* Runs **Postgres 17** as `db` with a named volume for data persistence.
* Builds the **Odoo minimal image** and runs it as `odoo`.
* Injects runtime DB parameters via CLI flags (so we don’t hardcode them in the config file).
* Binds a config file from `./config` into `/etc/odoo/odoo.conf` so you can switch between dev/prod easily.
* Mounts `./addons` into `/mnt/extra-addons` for local addon development.

### Config templates

**config/odoo.dev.conf** (minimal, dev friendly)

```ini
[options]
; Keep this file environment-agnostic (no DB creds here)
db_host = db
db_port = 5432
db_user = odoo
db_password = odoo
admin_passwd = superadmin

; Core paths
addons_path = /opt/odoo/addons,/mnt/extra-addons
data_dir    = /var/lib/odoo
logfile     = /var/log/odoo/odoo.log

; Sensible default logging
log_level   = info

; --- Optional toggles (uncomment when needed) ---
; dev_mode   = reload,qweb,assets
```

**config/odoo.prod.conf** (quieter logs, worker‑ready if you scale later)

```ini
[options]
addons_path = /opt/odoo/addons,/mnt/extra-addons
data_dir = /var/lib/odoo
logfile = /var/log/odoo/odoo.log
log_level = info
proxy_mode = True
; Example worker settings (tune for your infra)
; workers = 2
; limit_time_cpu = 60
; limit_time_real = 120
; limit_memory_hard = 536870912
; limit_memory_soft = 268435456
```

---

## Common Commands

```bash
# Build + start (detached)
docker compose up -d --build

# Follow logs
docker compose logs -f odoo

# Exec into the Odoo container
docker compose exec odoo bash

# Stop / remove containers (preserve volumes)
docker compose down

# Reset Postgres data (⚠️ destructive)
docker compose down -v
```

---

## Troubleshooting / Add‑ons later

* **PDF printing fails** → add `wkhtmltopdf` to the image later.
* **Image format errors** (resize/thumbnail) → add image libs (`libjpeg`, `libwebp`, etc.).
* **RTL assets** → add Node + `rtlcss` later for full asset building.
* **Port already in use** → change `8069:8069` or `DB_PORT` in `.env`.
* **Database creation blocked** → ensure the **Master Password** you type in the UI matches `${ADMIN_PASS}`.

> The idea is incremental: run Odoo with the smallest possible base first, then only add system packages when you actually need a feature.

---

## Notes

* This setup is great for local learning and development. For production you’ll likely run Odoo behind a reverse proxy (HTTPS), put Postgres on a managed service (e.g., Cloud SQL), and add the missing system libs.
* If you later move to Cloud Run or GCE, keep the same layout: image build stays minimal; database connection details should be managed in the config file; environment variables are primarily used during database creation.

---

## License

This project is licensed under the GNU LGPL v3.0 (same as Odoo).
See the [LICENSE](./LICENSE) file for details.

Odoo is a registered trademark of Odoo S.A. This project is not affiliated with Odoo S.A.