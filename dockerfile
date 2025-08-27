FROM python:3.11-slim

ENV DEBIAN_FRONTEND=noninteractive \
    ODOO_HOME=/opt/odoo \
    ODOO_BRANCH=18.0

# 最基礎依賴：git + build-essential + libpq (Postgres 驅動)
RUN apt-get update && apt-get install -y --no-install-recommends \
    git build-essential libpq-dev \
    libldap2-dev libsasl2-dev \
 && rm -rf /var/lib/apt/lists/*

# 建使用者
RUN useradd -ms /bin/bash odoo

# 取 Odoo 原始碼
RUN git clone --depth 1 --branch ${ODOO_BRANCH} https://github.com/odoo/odoo.git ${ODOO_HOME}
WORKDIR ${ODOO_HOME}

# Python 相依
RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt

# 建立基本資料夾
RUN mkdir -p /var/lib/odoo /var/log/odoo /mnt/extra-addons \
 && chown -R odoo:odoo /var/lib/odoo /var/log/odoo /mnt/extra-addons ${ODOO_HOME}

COPY config/odoo.dev.conf /etc/odoo/odoo.conf
RUN chown odoo:odoo /etc/odoo/odoo.conf

USER odoo
EXPOSE 8069

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]