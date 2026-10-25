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



# ==========================================
# СЕРВИС 1: POSTGRES
# ==========================================

#Создание volume для данных
echo "---------------------------"
echo "DOCKER: Create volume $DOCKER_VOLUME_NAME..."
docker volume create "${DOCKER_VOLUME_NAME}"
echo "DOCKER: Create volume $DOCKER_VOLUME_NAME...Ok"

#Сборка Image
echo "---------------------------"
echo "DOCKER: Create image $DOCKER_IMAGE_NAME..."
docker build -t "${DOCKER_IMAGE_NAME}" .
echo "DOCKER: Create image $DOCKER_IMAGE_NAME...Ok"

echo "---------------------------"
echo "DOCKER: Run Postgres..."

#Запуск Postgres
docker run -d \
  --name "${DOCKER_CONTAINER_NAME}" \
  --restart unless-stopped \
  -e POSTGRES_USER="${POSTGRES_USER}" \
  -e POSTGRES_PASSWORD_FILE=/run/secrets/postgres_password \
  -p "127.0.0.1:${POSTGRES_PORT}":5432 \
  -v "${DOCKER_VOLUME_NAME}:/var/lib/postgresql/data" \
  -v "$(pwd)/secrets/postgres_password.txt:/run/secrets/postgres_password:ro" \
  "${DOCKER_IMAGE_NAME}"

# docker run -d \
#   --name "${DOCKER_CONTAINER_NAME}" \
#   --restart unless-stopped \
#   -e POSTGRES_USER="${POSTGRES_USER}" \
#   -e POSTGRES_PASSWORD_FILE=/run/secrets/postgres_password \
#   -e POSTGRES_DB="${POSTGRES_DB}" \
#   -p "127.0.0.1:${POSTGRES_PORT}":5432 \
#   -v "${DOCKER_VOLUME_NAME}:/var/lib/postgresql/data" \
#   -v "$(pwd)/secrets/postgres_password.txt:/run/secrets/postgres_password:ro" \
#   "${DOCKER_IMAGE_NAME}"

#-e POSTGRES_PASSWORD="${POSTGRES_PASSWORD}" \

echo "DOCKER: Run Postgres...Ok"





# ==========================================
# СЕРВИС 2: PYTHON APP
# ==========================================

# Сборка Image Python App
echo "---------------------------"
echo "DOCKER: Create image $APP_IMAGE_NAME..."
# Флаг -f указывает на конкретный Dockerfile, а путь в конце (.) — это контекст сборки.
# Если в Dockerfile используются COPY requirements.txt, то контекстом должна быть папка rg_app_init
echo "build -t ${APP_IMAGE_NAME} -f ${APP_DOCKERFILE_PATH} ./rg_app_init"
docker build -t "${APP_IMAGE_NAME}" -f "${APP_DOCKERFILE_PATH}" ./rg_app_init
echo "DOCKER: Create image $APP_IMAGE_NAME...Ok"


# Запуск Python App
echo "---------------------------"
echo "DOCKER: Run Python App..."
# Важно: приложению нужно знать, как подключиться к базе.
# Если приложение в той же сети docker, хостом будет имя контейнера Postgres (${DOCKER_CONTAINER_NAME})
docker run -d \
  --name "${APP_CONTAINER_NAME}" \
  --restart no \
  --link "${DOCKER_CONTAINER_NAME}":postgres \
  -e POSTGRES_HOST="${DOCKER_CONTAINER_NAME}" \
  -e POSTGRES_PORT=5432 \
  -e POSTGRES_USER="${POSTGRES_USER}" \
  -e POSTGRES_DB="${POSTGRES_DB}" \
  -v "$(pwd)/secrets/postgres_password.txt:/run/secrets/postgres_password:ro" \
  -v "$(pwd)/rg_app_init:/app" \
     "${APP_IMAGE_NAME}"


#- ./log/rg__app_init:/app/log/rg__app_init # Монтируем папку логов проекта, чтобы файлы сохранялись на хосте
# Примечание: Мы используем --link, чтобы приложение могло видеть базу по имени.
# В современных версиях Docker лучше использовать пользовательские сети (docker network create),
# но --link проще для быстрого старта в скрипте.

echo "DOCKER: Run Python App...Ok"






echo "---------------------------"
echo "INFO: Script end = $(date)"
echo "INFO: Script path  = $SCRIPT_NAME"
echo "---------------------------"