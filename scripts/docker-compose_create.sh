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
echo "INFO: APP_IMAGE_NAME_PYTHON = $APP_IMAGE_NAME_PYTHON"


#Меняем текущий путь
echo "---------------------------"
echo "INFO: cd ${SCRIPT_DIR}"
echo "INFO: old pwd = $PWD"
cd "${SCRIPT_DIR}"
echo "INFO: new pwd = $PWD"

#Создание volume для данных
echo "---------------------------"
echo "DOCKER: Create volume ${DOCKER_VOLUME_NAME}..."
docker volume create "${DOCKER_VOLUME_NAME}"
echo "DOCKER: Create volume ${DOCKER_VOLUME_NAME}...Ok"

#Сборка Image
echo "---------------------------"
echo "DOCKER: Create image $DOCKER_IMAGE_NAME..."
docker build -t "${DOCKER_IMAGE_NAME}" .
echo "DOCKER: Create image $DOCKER_IMAGE_NAME...Ok"

echo "---------------------------"
echo "DOCKER-COMPOSE: Run..."
#docker compose up -d --build
docker compose up -d
echo "DOCKER-COMPOSE: Run...Ok"

# 3. Проверить статус
#docker compose ps

# 4. Посмотреть логи
#docker compose logs -f postgres

# 5. Подключиться к БД
#docker exec -it postgres_container psql -U postgres -d mydb

# 6. Остановить контейнер (данные сохранятся в volume)
#docker compose down

# 7. Остановить с удалением данных
#docker compose down -v





echo "---------------------------"
echo "INFO: Script end = $(date)"
echo "INFO: Script path  = $SCRIPT_NAME"
echo "---------------------------"