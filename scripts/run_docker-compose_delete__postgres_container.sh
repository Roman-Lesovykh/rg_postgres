#!/bin/bash

#Устанавливаем переменные
SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
SCRIPT_PATH="$(realpath "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(dirname "$0")"

# Получаем имя рабочей директории и переводим в нижний регистр
SCRIPT_WORK_DIR="$(basename "$SCRIPT_DIR")"
SCRIPT_WORK_DIR="$(basename "$SCRIPT_DIR" | tr '[:upper:]' '[:lower:]')"

echo "INFO: SCRIPT_NAME = $SCRIPT_NAME"
echo "INFO: SCRIPT_DIR  = $SCRIPT_DIR"
echo "INFO: SCRIPT_PATH = $SCRIPT_PATH"
echo "INFO: SCRIPT_WORK_DIR = $SCRIPT_WORK_DIR"

# Формируем имя лог-файла с датой и временем
TIMESTAMP="$(date +'%Y-%m-%d_%H-%M-%S')"
LOG_FILE="${TIMESTAMP}__run_docker-compose_delete__postgres_container.log"

cd "${SCRIPT_DIR}"

# Сохраняем весь вывод (stdout и stderr) в файл dcocker_log.txt
# И одновременно показываем на экране через tee
exec > >(tee -a "$SCRIPT_DIR/log/$LOG_FILE") 2>&1


#Устанавливаем права на файлы. Если файлы были новые, то они могут не иметь нужных прав
#echo "---------------------------"
#echo "INFO: chmod -R u+rwx ${SCRIPT_DIR}"
#chmod -R u+rwx "${SCRIPT_DIR}"
#chmod -R u+rwx /Users/roman/Dev/Python/rg_postgres
#chmod 600 /Users/roman/Dev/Python/rg_postgres/secrets/postgres_password.txt

clear

. ./docker-compose_delete__postgres_container.sh