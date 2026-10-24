# Используем официальный образ последней версии PostgreSQL
FROM postgres:17-alpine
#FROM postgres:17

# Метаданные
LABEL maintainer="roma.lesovykh@yandex.ru"
LABEL description="Custom PostgreSQL 17 image"

# Значения по умолчанию — используются только если переменная не передана при запуске.
# Реальные значения подставляет скрипт через `docker run -e ...`
ENV POSTGRES_USER=rg_view_4m40 \
    #POSTGRES_PASSWORD=strong_password_here \
    #POSTGRES_DB=rg_db \
    PGDATA=/var/lib/postgresql/data/pgdata

# Открываем стандартный порт PostgreSQL
EXPOSE 5432

# Volume для хранения данных
VOLUME ["/var/lib/postgresql/data"]

# Healthcheck для проверки готовности БД
HEALTHCHECK --interval=10s --timeout=5s --retries=5 \
    CMD pg_isready -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" || exit 1
