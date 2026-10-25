#!/bin/bash

echo $SEPARATOR
echo "$(get_timestamp)Script start - $(realpath "${BASH_SOURCE[0]}")"


#Выводим стастус контейнера
echo $SEPARATOR
echo "$(get_timestamp)Show container $DOCKER_CONTAINER_NAME"
echo "$(get_timestamp)Run: docker ps -a --filter name=^${DOCKER_CONTAINER_NAME}$"
docker ps -a --filter "name=^${DOCKER_CONTAINER_NAME}$"


if [ "$DOCKER_CLEAR_CACHE_AFTER_CHECK_CONTAINER" = "1" ]; then
    #Чистим кэш в Docker
    echo $SEPARATOR
    echo "$(get_timestamp)Clear all cache (after docker run)..."
    echo "$(get_timestamp)Run: docker builder prune -a -f"
    docker builder prune -a -f
    echo "$(get_timestamp)Clear all cache (after docker run)...Ok"
fi


#Фиксируем память перед стартом. Ы конце можем проверить сколько место занял процесс
echo $SEPARATOR
echo "$(get_timestamp)Test PostgreSQL..."
echo "$(get_timestamp)Wait $((POSTGRES_RUN_MAX_ATTEMPTS * POSTGRES_RUN_SLEEP_INTERVAL)) second'..."
set -euo pipefail


attempt=0
until docker exec "$DOCKER_CONTAINER_NAME" pg_isready -U "$POSTGRES_USER" >/dev/null 2>&1; do
    sleep "$POSTGRES_RUN_SLEEP_INTERVAL"
    attempt=$((attempt + 1))
    if [ "$attempt" -ge "$POSTGRES_RUN_MAX_ATTEMPTS" ]; then
        echo "$(get_timestamp) ❌ PostgreSQL did not become available within $((POSTGRES_RUN_MAX_ATTEMPTS * POSTGRES_RUN_SLEEP_INTERVAL)) seconds" >&2
        echo $SEPARATOR
        echo "$(get_timestamp)Script end - $(realpath "${BASH_SOURCE[0]}")"
        echo $SEPARATOR
        exit 1
    fi
    echo "$(get_timestamp)Try $attempt/$POSTGRES_RUN_MAX_ATTEMPTS, wait ${POSTGRES_RUN_SLEEP_INTERVAL}s..."
    sleep "$POSTGRES_RUN_SLEEP_INTERVAL"
done


echo "$(get_timestamp)Test PostgreSQL...Ok ✅"
#docker exec "$DOCKER_CONTAINER_NAME" psql -U "$POSTGRES_USER" -c "\l"


echo $SEPARATOR
echo "$(get_timestamp)Script end - $(realpath "${BASH_SOURCE[0]}")"