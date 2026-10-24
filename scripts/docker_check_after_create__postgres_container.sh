#!/bin/bash

#Запоминаем скрипт родитель
PARENT_SCRIPT_NAME="$SCRIPT_NAME"
PARENT_SCRIPT_PATH="$SCRIPT_DIR"
PARENT_SCRIPT_DIR="$SCRIPT_PATH"

#Устанавливаем переменные
SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
SCRIPT_PATH="$(realpath "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(dirname "$0")"

# Сохраняем весь вывод (stdout и stderr) в файл dcocker_log.txt
# И одновременно показываем на экране через tee
#exec > >(tee -a "$SCRIPT_DIR/log/log_docker.txt") 2>&1

# Добавляем пробелы если файл уже создан
# if [ -f "$SCRIPT_DIR/log/log_docker.txt" ]; then
#     # Файл найден
#     echo ""
#     echo ""
#     echo ""
#     echo ""
#     echo ""
# else
#     # Файл не найден
#     echo ""
# fi

echo ""
echo "---------------------------"
echo "INFO: Script start = $(date)"
echo "INFO: Script path  = $SCRIPT_NAME"


# Загружаем переменные из файла .env
# Проверяем, существует ли файл .env именно рядом со скриптом
echo "---------------------------"
echo "INFO: Load variables from file '.env'..."
if [ -f "$SCRIPT_DIR/.env" ]; then
    # Файл найден
    set -a
    source "$SCRIPT_DIR/.env"
    set +a

    echo "INFO: Load variables from file '.env'...Ok"
else
    # Файл не найден
    echo "INFO: File not found in path = $SCRIPT_DIR/.env"
    echo "INFO: Load variables from file '.env'...Error"
    exit 1
fi


# Устанаовка Volume для Compose
DOCKER_COMPOSE_VOLUME_NAME="${SCRIPT_WORK_DIR}_${DOCKER_VOLUME_NAME}"

# Выводим переменные
echo "---------------------------"
echo "INFO: SCRIPT_NAME = $SCRIPT_NAME"
echo "INFO: SCRIPT_DIR  = $SCRIPT_DIR"
echo "INFO: SCRIPT_PATH = $SCRIPT_PATH"
echo "INFO: SCRIPT_WORK_DIR = $SCRIPT_WORK_DIR"
echo "INFO: PARENT_SCRIPT_NAME = $PARENT_SCRIPT_NAME"
echo "INFO: PARENT_SCRIPT_PATH  = $PARENT_SCRIPT_PATH"
echo "INFO: PARENT_SCRIPT_DIR = $PARENT_SCRIPT_DIR"
echo "INFO: DOCKER_CONTAINER_NAME = $DOCKER_CONTAINER_NAME"
echo "INFO: DOCKER_IMAGE_NAME = $DOCKER_IMAGE_NAME"
echo "INFO: DOCKER_IMAGE_NAME_POSTGRES = $DOCKER_IMAGE_NAME_POSTGRES"
echo "INFO: DOCKER_CLEAR_CACHE_AFTER_DELETE_CONTAIMER = $DOCKER_CLEAR_CACHE_AFTER_DELETE_CONTAIMER"
echo "INFO: DOCKER_CLEAR_CACHE_AFTER_CHECK_CONTAIMER = $DOCKER_CLEAR_CACHE_AFTER_CHECK_CONTAIMER"
echo "INFO: DOCKER_VOLUME_NAME = $DOCKER_VOLUME_NAME"
echo "INFO: COMPOSE_VOLUME_NAME = $DOCKER_COMPOSE_VOLUME_NAME"
echo "INFO: POSTGRES_DB = $POSTGRES_DB"
echo "INFO: POSTGRES_PORT = $POSTGRES_PORT"
echo "INFO: POSTGRES_USER = $POSTGRES_USER"
echo "INFO: POSTGRES_PASSWORD = $POSTGRES_PASSWORD"
echo "INFO: POSTGRES_PGDATA = $POSTGRES_PGDATA"
echo "INFO: POSTGRES_DATA = $POSTGRES_DATA"
echo "INFO: POSTGRES_RUN_MAX_ATTEMPTS = $POSTGRES_RUN_MAX_ATTEMPTS"
echo "INFO: POSTGRES_RUN_SLEEP_INTERVAL = $POSTGRES_RUN_SLEEP_INTERVAL"

echo "INFO: APP_CONTAINER_NAME = $APP_CONTAINER_NAME"
echo "INFO: APP_IMAGE_NAME = $APP_IMAGE_NAME"
echo "INFO: APP_DOCKERFILE_PATH = $APP_DOCKERFILE_PATH"
echo "INFO: APP_IMAGE_NAME_PYTHON = $APP_IMAGE_NAME_PYTHON"


#Меняем текущий путь
echo "---------------------------"
echo "INFO: cd ${SCRIPT_DIR}"
echo "INFO: old pwd = $PWD"
cd "${SCRIPT_DIR}"
echo "INFO: new pwd = $PWD"


#Выводим стастус контейнера
echo "---------------------------"
echo "DOCKER: Show container $DOCKER_CONTAINER_NAME"
docker ps -a --filter "name=^${DOCKER_CONTAINER_NAME}$"

#Выводим логи
echo "---------------------------"
echo "Docker: Show log"
echo "Docker: docker logs $DOCKER_CONTAINER_NAME"
docker logs "${DOCKER_CONTAINER_NAME}"


if [ "$DOCKER_CLEAR_CACHE_AFTER_CHECK_CONTAINER" = "1" ]; then
    #Чистим кэш в Docker
    echo "---------------------------"
    echo "DOCKER: Clear all cache (after docker run)..."
    echo "DOCKER: docker builder prune -a -f"
    docker builder prune -a -f
    echo "DOCKER: Clear all cache (after docker run)...Ok"
fi

#Показываем память, которую занял Docker
echo "---------------------------"
echo "DOCKER: docker system df (Show memory):"
docker system df


#Фиксируем память перед стартом. Ы конце можем проверить сколько место занял процесс
echo "---------------------------"
echo "DOCKER: Running PostgreSQL"
echo "DOCKER: Wait $((POSTGRES_RUN_MAX_ATTEMPTS * POSTGRES_RUN_SLEEP_INTERVAL)) second'..."
set -euo pipefail

attempt=0
until docker exec "$DOCKER_CONTAINER_NAME" pg_isready -U "$POSTGRES_USER" >/dev/null 2>&1; do
    sleep "$POSTGRES_RUN_SLEEP_INTERVAL"
    attempt=$((attempt + 1))
    if [ "$attempt" -ge "$POSTGRES_RUN_MAX_ATTEMPTS" ]; then
        echo "DOCKER: ❌ PPostgreSQL did not become available within $((POSTGRES_RUN_MAX_ATTEMPTS * POSTGRES_RUN_SLEEP_INTERVAL)) seconds" >&2
        echo "---------------------------"
        echo "INFO: Script end = $(date)"
        echo "INFO: Script path  = $(SCRIPT_NAME)"
        echo "---------------------------"
        echo ""
echo ""
echo ""
echo ""
echo ""
        exit 1
    fi
    echo "  попытка $attempt/$POSTGRES_RUN_MAX_ATTEMPTS — ещё не готов, ждём ${POSTGRES_RUN_SLEEP_INTERVAL}s..."
    sleep "$POSTGRES_RUN_SLEEP_INTERVAL"
done

echo "DOCKER: ✅ PostgreSQL ready "
#docker exec "$DOCKER_CONTAINER_NAME" psql -U "$POSTGRES_USER" -c "\l"

echo "---------------------------"
echo "INFO: Script end = $(date)"
echo "INFO: Script path  = $SCRIPT_NAME"
echo "---------------------------"


# # Настройки
# CONTAINER_NAME=$DOCKER_CONTAINER_NAME
# NEW_IMAGE_NAME="romanlesovykh/prod_rg_postgress_image:v1"
# COMPOSE_FILE="docker-compose.yml" # Укажите путь к вашему compose-файлу, если он в другой папке

# echo "=== 1. Остановка контейнера ${CONTAINER_NAME} ==="
# # Используем docker compose stop, так как это правильный способ остановки для контейнеров,
# # запущенных через compose (учитывает зависимости и сети).
# # Если у вас старая версия docker, используйте: docker-compose stop postgres
# docker compose -f "$COMPOSE_FILE" stop postgres

# # Проверяем, что контейнер действительно остановлен (на всякий случай)
# if [ "$(docker ps -q -f name=^/${CONTAINER_NAME}$)" ]; then
#     echo "Контейнер все еще работает. Принудительная остановка..."
#     docker stop "$CONTAINER_NAME"
# fi

# echo "=== 2. Создание нового образа из контейнера ==="
# # Коммитим изменения контейнера в новый образ
# echo "docker commit ${CONTAINER_NAME} ${NEW_IMAGE_NAME} "
# docker commit "$CONTAINER_NAME" "$NEW_IMAGE_NAME"

# if [ $? -eq 0 ]; then
#     echo "✅ Успех! Образ ${NEW_IMAGE_NAME} создан."
# else
#     echo "❌ Ошибка при создании образа."
#     exit 1
# fi

# echo "=== 3. (Опционально) Запуск контейнера обратно ==="
# # Раскомментируйте строки ниже, если хотите, чтобы контейнер продолжил работу после создания образа
# echo "Запуск контейнера обратно..."
# docker compose -f "$COMPOSE_FILE" start postgres
# echo "Контейнер запущен."

# echo "=== Готово ==="
