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


#Показываем список файлов
echo "---------------------------"
echo "INFO: ls -la ${SCRIPT_DIR} :"
echo "$(ls -la ${SCRIPT_DIR})"
echo "---------------------------"
echo "INFO: ls -la ${SCRIPT_DIR}/init_sql :"
echo "$(ls -la ${SCRIPT_DIR}/init_sql)"


#Показываем память, которую занял Docker
echo "---------------------------"
echo "DOCKER: docker system df (Show memory):"
docker system df


# Сервис rg_postgres - Сначала останавливаем container, затем его удаляем
echo "---------------------------"
# Проверяем, существует ли контейнер и запущен ли он
if [ "$(docker ps -q -f name="^${DOCKER_CONTAINER_NAME}$")" ]; then
    #Контейнер найден и работает

    echo "DOCKER: Stop container ${DOCKER_CONTAINER_NAME}..."
    docker stop "${DOCKER_CONTAINER_NAME}"
    echo "DOCKER: Stop container ${DOCKER_CONTAINER_NAME}...Ok"
    echo "---------------------------"
    echo "Docker: Delete container ${DOCKER_CONTAINER_NAME}..."
    docker rm -f -v "${DOCKER_CONTAINER_NAME}"
    echo "DOCKER: Delete container ${DOCKER_CONTAINER_NAME}...Ok"
else
    # Проверяем, существует ли контейнер вообще (но остановлен)
    if [ "$(docker ps -aq -f name="^${DOCKER_CONTAINER_NAME}$")" ]; then
        #Контейнер найден
        echo "DOCKER: Delete container ${DOCKER_CONTAINER_NAME}..."
        docker rm -f "${DOCKER_CONTAINER_NAME}"
        echo "DOCKER: Delete container ${DOCKER_CONTAINER_NAME}...Ok"
    else
        #Контейнер не найден
       echo "DOCKER: Container ${DOCKER_CONTAINER_NAME} not found...Ok"
    fi
fi

# Сервис rg_app_init - Сначала останавливаем container, затем его удаляем
echo "---------------------------"
# Проверяем, существует ли контейнер и запущен ли он
if [ "$(docker ps -q -f name="^${APP_CONTAINER_NAME}$")" ]; then
    #Контейнер найден и работает

    echo "DOCKER: Stop container ${APP_CONTAINER_NAME}..."
    docker stop "${APP_CONTAINER_NAME}"
    echo "DOCKER: Stop container ${APP_CONTAINER_NAME}...Ok"
    echo "---------------------------"
    echo "Docker: Delete container ${APP_CONTAINER_NAME}..."
    docker rm -f -v "${APP_CONTAINER_NAME}"
    echo "DOCKER: Delete container ${APP_CONTAINER_NAME}...Ok"
else
    # Проверяем, существует ли контейнер вообще (но остановлен)
    if [ "$(docker ps -aq -f name="^${APP_CONTAINER_NAME}$")" ]; then
        #Контейнер найден
        echo "DOCKER: Delete container ${APP_CONTAINER_NAME}..."
        docker rm -f "${APP_CONTAINER_NAME}"
        echo "DOCKER: Delete container ${APP_CONTAINER_NAME}...Ok"
    else
        #Контейнер не найден
       echo "DOCKER: Container ${APP_CONTAINER_NAME} not found...Ok"
    fi
fi



# Сервис rg_postgres - Удаляем Image
echo "---------------------------"
# Проверяем наличие образа
if docker image inspect "$DOCKER_IMAGE_NAME" > /dev/null 2>&1; then
    echo "DOCKER: Delete Image ${DOCKER_IMAGE_NAME}..."
    docker rmi "${DOCKER_IMAGE_NAME}"
    echo "DOCKER: Delete Image ${DOCKER_IMAGE_NAME}...Ok"
else
    echo "DOCKER: Image ${DOCKER_IMAGE_NAME} not found...Ok"
fi

# Сервис rg_postgres - Удаляем Image Postgres
echo "---------------------------"
# Проверяем наличие образа
if docker image inspect "$DOCKER_IMAGE_NAME_POSTGRES" > /dev/null 2>&1; then
    echo "DOCKER: Delete Image ${DOCKER_IMAGE_NAME_POSTGRES}..."
    docker rmi "${DOCKER_IMAGE_NAME_POSTGRES}"
    echo "DOCKER: Delete Image ${DOCKER_IMAGE_NAME_POSTGRES}...Ok"
else
    echo "DOCKER: Image ${DOCKER_IMAGE_NAME_POSTGRES} not found...Ok"
fi


# Сервис rg_app_init - Удаляем Image Postgres
echo "---------------------------"
# Проверяем наличие образа
if docker image inspect "$APP_IMAGE_NAME" > /dev/null 2>&1; then
    echo "DOCKER: Delete Image ${APP_IMAGE_NAME}..."
    docker rmi "${APP_IMAGE_NAME}"
    echo "DOCKER: Delete Image ${APP_IMAGE_NAME}...Ok"
else
    echo "DOCKER: Image ${APP_IMAGE_NAME} not found...Ok"
fi

# Сервис rg_app_init - Удаляем Image python:3.15-slim
echo "---------------------------"
# Проверяем наличие образа
if docker image inspect "$APP_IMAGE_NAME_PYTHON" > /dev/null 2>&1; then
    echo "DOCKER: Delete Image ${APP_IMAGE_NAME_PYTHON}..."
    docker rmi "${APP_IMAGE_NAME_PYTHON}"
    echo "DOCKER: Delete Image ${APP_IMAGE_NAME_PYTHON}...Ok"
else
    echo "DOCKER: Image ${APP_IMAGE_NAME_PYTHON} not found...Ok"
fi


# Сервис rg_postgres - Удаляем Volume
echo "---------------------------"
if docker volume inspect "${DOCKER_VOLUME_NAME}" > /dev/null 2>&1; then
    echo "DOCKER: Delete volume ${DOCKER_VOLUME_NAME}..."
    docker volume rm "${DOCKER_VOLUME_NAME}"
    echo "DOCKER: Delete volume ${DOCKER_VOLUME_NAME}...Ok"
else
    echo "DOCKER: Volume ${DOCKER_VOLUME_NAME} not found...Ok"
fi

if [ "$DOCKER_CLEAR_CACHE_AFTER_DELETE_CONTAINER" = "1" ]; then
    #Чистим кэш в Docker
    echo "---------------------------"
    echo "DOCKER: Clear all cache (after docker run)..."
    echo "DOCKER: docker builder prune -a -f"
    docker builder prune -a -f
    echo "DOCKER: Clear all cache (after docker run)...Ok"
fi


echo "---------------------------"
echo "INFO: Script end = $(date)"
echo "INFO: Script path  = $SCRIPT_NAME"
echo "---------------------------"