#!/usr/bin/env bash
set -e

# 等 Postgres 準備好（借用官方做法精神）
python - <<'PY'
import os, time, sys
import psycopg2
host=os.getenv('DB_HOST','db'); port=int(os.getenv('DB_PORT','5432'))
user=os.getenv('DB_USER','odoo'); pwd=os.getenv('DB_PASSWORD','odoo')
for _ in range(60):
    try:
        psycopg2.connect(host=host, port=port, user=user, password=pwd, dbname='postgres').close()
        sys.exit(0)
    except Exception:
        time.sleep(1)
print("PostgreSQL not ready after 60s", file=sys.stderr); sys.exit(1)
PY

exec python /opt/odoo/odoo-bin -c /etc/odoo/odoo.conf
