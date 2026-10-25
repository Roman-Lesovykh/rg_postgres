#!/bin/bash

echo $SEPARATOR
echo "$(get_timestamp)Script start - $(realpath "${BASH_SOURCE[0]}")"


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
echo "$(get_timestamp)Run container..."

#Запуск Postgres
docker run -d \
  --name "${DOCKER_CONTAINER_NAME}" \
  --restart unless-stopped \
  -e POSTGRES_USER="${POSTGRES_USER}" \
  -e POSTGRES_PASSWORD_FILE=/run/secrets/postgres_password \
  -p "127.0.0.1:${POSTGRES_PORT}":5432 \
  -v "${DOCKER_VOLUME_NAME}:/var/lib/postgresql/data" \
  -v "${SCRIPT_APP_DIR}/src/rg_postgres/.env.postgres_password:/run/secrets/postgres_password:ro" \
  "${DOCKER_IMAGE_NAME}"

echo "$(get_timestamp)Run container...Ok"


#Выводим логи
echo $SEPARATOR
echo "$(get_timestamp)Docker: Show log"
echo "$(get_timestamp)Run: docker logs $DOCKER_CONTAINER_NAME"
docker logs "${DOCKER_CONTAINER_NAME}"


if [ "$DOCKER_CLEAR_CACHE_AFTER_CREATE_CONTAINER" = "1" ]; then

    #Показываем память, которую занял Docker
    echo $SEPARATOR
    echo "$(get_timestamp)Run: docker system df (Show memory):"
    docker system df

    #Чистим кэш в Docker
    echo $SEPARATOR
    echo "$(get_timestamp)Clear all cache (after docker run)..."
    echo "$(get_timestamp)Run: docker builder prune -a -f"
    docker builder prune -a -f
    echo "$(get_timestamp)Clear all cache (after docker run)...Ok"

    #Показываем память, которую занял Docker
    echo $SEPARATOR
    echo "$(get_timestamp)Run: docker system df (Show memory):"
    docker system df
fi


echo $SEPARATOR
echo "$(get_timestamp)Script end - $(realpath "${BASH_SOURCE[0]}")"
