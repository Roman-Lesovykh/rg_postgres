# Используем официальный образ последней версии PostgreSQL
#FROM postgres:17-alpine
FROM postgres:17

# Метаданные
LABEL maintainer="roma.lesovykh@yandex.ru"
LABEL description="Custom PostgreSQL image"

# Значения по умолчанию
ENV POSTGRES_USER=rg_view_4m40 \
    PGDATA=/var/lib/postgresql/data/pgdata

# Открываем стандартный порт PostgreSQL
EXPOSE 5432

# Volume для хранения данных
VOLUME ["/var/lib/postgresql/data"]

# Healthcheck для проверки готовности БД
HEALTHCHECK --interval=10s --timeout=5s --retries=5 \
    CMD pg_isready -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" || exit 1
