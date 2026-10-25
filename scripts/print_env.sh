# Устанаовка Volume для Compose
DOCKER_COMPOSE_VOLUME_NAME="${SCRIPT_APP_FOLDER}_${DOCKER_VOLUME_NAME}"


# Установка директории приложения
echo $SEPARATOR
echo "$(get_timestamp)Set path..."
echo "$(get_timestamp)Run: cd $SCRIPT_APP_DIR"
echo "$(get_timestamp)Old pwd = $PWD"
cd "${SCRIPT_APP_DIR}"
echo "$(get_timestamp)New pwd = $PWD"
echo "$(get_timestamp)Set path...Ok"


echo $SEPARATOR
echo "SCRIPT_ENV = $SCRIPT_ENV"
echo "SCRIPT_NAME = $SCRIPT_NAME"
echo "SCRIPT_DIR  = $SCRIPT_DIR"
echo "SCRIPT_PATH = $SCRIPT_PATH"
echo "SCRIPT_FOLDER = $SCRIPT_FOLDER"
echo "SCRIPT_APP_DIR = $SCRIPT_APP_DIR"
echo "SCRIPT_APP_FOLDER = $SCRIPT_APP_FOLDER"
echo "LOG_NAME = $LOG_NAME"
echo "LOG_DIR = $LOG_DIR"
echo "LOG_PATH = $LOG_PATH"
echo "LOG_FOLDER = $LOG_FOLDER"
echo "DOCKER_CONTAINER_NAME = $DOCKER_CONTAINER_NAME"
echo "DOCKER_IMAGE_NAME = $DOCKER_IMAGE_NAME"
echo "DOCKER_IMAGE_NAME_POSTGRES = $DOCKER_IMAGE_NAME_POSTGRES"
echo "DOCKER_CLEAR_CACHE_AFTER_DELETE_CONTAINER = $DOCKER_CLEAR_CACHE_AFTER_DELETE_CONTAINER"
echo "DOCKER_CLEAR_CACHE_AFTER_CHECK_CONTAINER = $DOCKER_CLEAR_CACHE_AFTER_CHECK_CONTAINER"
echo "DOCKER_VOLUME_NAME = $DOCKER_VOLUME_NAME"
echo "COMPOSE_VOLUME_NAME = $DOCKER_COMPOSE_VOLUME_NAME"
echo "POSTGRES_DB = $POSTGRES_DB"
echo "POSTGRES_PORT = $POSTGRES_PORT"
echo "POSTGRES_USER = $POSTGRES_USER"
echo "POSTGRES_PASSWORD = $POSTGRES_PASSWORD"
echo "POSTGRES_PGDATA = $POSTGRES_PGDATA"
echo "POSTGRES_DATA = $POSTGRES_DATA"
echo "POSTGRES_RUN_MAX_ATTEMPTS = $POSTGRES_RUN_MAX_ATTEMPTS"
echo "POSTGRES_RUN_SLEEP_INTERVAL = $POSTGRES_RUN_SLEEP_INTERVAL"


#Показываем список файлов
echo $SEPARATOR
echo "$(get_timestamp)Show files..."
echo "$(get_timestamp)Run: ls -la ${SCRIPT_APP_DIR} :"
echo "$(ls -la ${SCRIPT_APP_DIR})"

echo $SEPARATOR
echo "$(get_timestamp)Run: ls -la ${SCRIPT_APP_DIR}/src :"
echo "$(ls -la ${SCRIPT_APP_DIR}/src/)"

echo $SEPARATOR
echo "$(get_timestamp)Run: ls -la ${SCRIPT_APP_DIR}/src/$SCRIPT_APP_FOLDER :"
echo "$(ls -la ${SCRIPT_APP_DIR}/src/$SCRIPT_APP_FOLDER)"

echo $SEPARATOR
echo "$(get_timestamp)Run: ls -la ${SCRIPT_DIR} :"
echo "$(ls -la ${SCRIPT_DIR})"

#echo "INFO: ls -la ${SCRIPT_APP_DIR}/init_sql :"
#echo "$(ls -la ${SCRIPT_APP_DIR}/init_sql)"


#Показываем память, которую занял Docker
echo $SEPARATOR
echo "$(get_timestamp)Run: docker system df (Show memory):"
docker system df


#Устанавливаем права на файлы. Если файлы были новые, то они могут не иметь нужных прав
#echo "---------------------------"
#echo "INFO: chmod -R u+rwx ${SCRIPT_DIR}"
#chmod -R u+rwx "${SCRIPT_DIR}"
#chmod -R u+rwx /Users/roman/Dev/Python/rg_postgres/
#chmod 600 /Users/roman/Dev/Python/rg_postgres/src/rg_postgres/.env.postgres_password