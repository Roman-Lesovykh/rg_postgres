#!/bin/bash

SEPARATOR="----------------------------------------------------------"

# --- Кэш для TIMESTAMP -------------------------------------------------------
# Используем глобальную переменную-кэш и флаг инициализации.
_TIMESTAMP_CACHE=""
_TIMESTAMP_INITIALIZED=0

# Функция возвращает (через echo) TIMESTAMP.
# При первом вызове вычисляет и кэширует, далее — отдаёт из кэша.
get_timestamp() {
    if (( _TIMESTAMP_INITIALIZED == 0 )); then
        _TIMESTAMP_CACHE="$(date +'%Y-%m-%d_%H-%M-%S')"
        _TIMESTAMP_INITIALIZED=1
    fi
    printf '%s\n' "[$_TIMESTAMP_CACHE] "
}


# Установка путей для запущенного скрипта
SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(dirname "$0")"
SCRIPT_PATH="$(realpath "${BASH_SOURCE[0]}")"
SCRIPT_FOLDER="$(basename "$SCRIPT_DIR")"

# Установка путей для директории приложения
SCRIPT_APP_DIR="$(dirname "$SCRIPT_DIR")"
SCRIPT_APP_FOLDER="$(basename "$SCRIPT_APP_DIR" | tr '[:upper:]' '[:lower:]')"

# Формируем имя лог-файла с датой и временем
TIMESTAMP="$(date +'%Y-%m-%d_%H-%M-%S')"
LOG_NAME="${TIMESTAMP}__run_docker_delete.log"
LOG_FOLDER="logs"
LOG_DIR="$(dirname "$SCRIPT_APP_DIR")/$LOG_FOLDER/$SCRIPT_APP_FOLDER"
LOG_PATH="$LOG_DIR/$LOG_NAME"

# Название файла настроек
SCRIPT_ENV="$SCRIPT_APP_DIR/src/$SCRIPT_APP_FOLDER/.env"


# Включаем pipefail
set -o pipefail

# Сохраняем весь вывод (stdout и stderr)
# И одновременно показываем на экране через tee
exec > >(tee -a "$LOG_PATH") 2>&1

echo $SEPARATOR
echo "$(get_timestamp)Run script = $SCRIPT_PATH"

# Проверка: если файл не найден — выходим
if [ ! -f "$LOG_PATH" ]; then
    echo $SEPARATOR
    echo "SCRIPT_ENV = $SCRIPT_ENV"
    echo ""
    echo "SCRIPT_NAME = $SCRIPT_NAME"
    echo "SCRIPT_DIR  = $SCRIPT_DIR"
    echo "SCRIPT_PATH = $SCRIPT_PATH"
    echo "SCRIPT_FOLDER = $SCRIPT_FOLDER"
    echo ""
    echo "SCRIPT_APP_DIR = $SCRIPT_APP_DIR"
    echo "SCRIPT_APP_FOLDER = $SCRIPT_APP_FOLDER"
    echo ""
    echo "LOG_NAME = $LOG_NAME"
    echo "LOG_DIR = $LOG_DIR"
    echo "LOG_PATH = $LOG_PATH"
    echo "LOG_FOLDER = $LOG_FOLDER"
    echo $SEPARATOR
    echo "ERROR: Log file not found: $LOG_PATH" >&2
    echo $SEPARATOR
    exit 1
fi


# Загружаем переменные из файла .env
# Проверяем, существует ли файл .env именно рядом со скриптом
echo $SEPARATOR
echo "$(get_timestamp)Load env file..."
#echo "$(get_timestamp)File $SCRIPT_ENV"
if [ -f "$SCRIPT_ENV" ]; then
    echo "$(get_timestamp)Run: source $SCRIPT_ENV"
    # Файл найден
    set -a
    source "$SCRIPT_ENV"
    set +a

    echo "$(get_timestamp)Load env file...Ok"
else
    # Файл не найден
    echo "$(get_timestamp)Load env file...Error"
    echo $SEPARATOR
    echo "ERROR: Laod file: $SCRIPT_ENV" >&2
    echo $SEPARATOR
    exit 1
fi


. "$SCRIPT_DIR"/print_env.sh
. "$SCRIPT_DIR"/docker_delete.sh


echo $SEPARATOR
echo $SEPARATOR
echo $SEPARATOR
echo $SEPARATOR
echo $SEPARATOR


#Создание volume для данных
echo $SEPARATOR
echo "$(get_timestamp)Create volume $DOCKER_VOLUME_NAME..."
echo "$(get_timestamp)Run% docker volume create ${DOCKER_VOLUME_NAME}"
docker volume create "${DOCKER_VOLUME_NAME}"
echo "$(get_timestamp)Create volume $DOCKER_VOLUME_NAME...Ok"


#Сборка Image
echo $SEPARATOR
echo "$(get_timestamp)Create image $DOCKER_IMAGE_NAME..."
echo "$(get_timestamp)Run: docker build -t ${DOCKER_IMAGE_NAME}" .
docker build -t "${DOCKER_IMAGE_NAME}" .
echo "$(get_timestamp)Create image $DOCKER_IMAGE_NAME...Ok"


echo $SEPARATOR
echo "$(get_timestamp)Run docker compose..."
echo "$(get_timestamp)Run: docker compose up -d --build"
docker compose -f docker-compose_use_dockerfile.yml up -d --build
#docker compose up -d
echo "$(get_timestamp)Run docker compose...Ok"


echo $SEPARATOR
echo $SEPARATOR
echo $SEPARATOR
echo $SEPARATOR
echo $SEPARATOR


. "$SCRIPT_DIR"/docker_check.sh


echo $SEPARATOR
echo "$(get_timestamp)Script end - $SCRIPT_PATH"
echo $SEPARATOR