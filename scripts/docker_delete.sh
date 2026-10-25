#!/bin/bash

echo $SEPARATOR
echo "$(get_timestamp)Script start - $(realpath "${BASH_SOURCE[0]}")"


# Сервис rg_postgres - Сначала останавливаем container, затем его удаляем
echo $SEPARATOR
echo "$(get_timestamp)Find, stop and delete container ${DOCKER_CONTAINER_NAME}..."
# Проверяем, существует ли контейнер и запущен ли он
if [ "$(docker ps -q -f name="^${DOCKER_CONTAINER_NAME}$")" ]; then
    #Контейнер найден и работает

    echo "$(get_timestamp)Stop container ${DOCKER_CONTAINER_NAME}..."
    echo "$(get_timestamp)Run: docker stop ${DOCKER_CONTAINER_NAME}"
    docker stop "${DOCKER_CONTAINER_NAME}"
    echo "$(get_timestamp)Stop container ${DOCKER_CONTAINER_NAME}...Ok"
    echo $SEPARATOR
    echo "$(get_timestamp)Delete container ${DOCKER_CONTAINER_NAME}..."
    echo "$(get_timestamp)Run: docker rm -f -v ${DOCKER_CONTAINER_NAME}"
    docker rm -f -v "${DOCKER_CONTAINER_NAME}"
    echo "$(get_timestamp)Delete container ${DOCKER_CONTAINER_NAME}...Ok"
else
    # Проверяем, существует ли контейнер вообще (но остановлен)
    if [ "$(docker ps -aq -f name="^${DOCKER_CONTAINER_NAME}$")" ]; then
        #Контейнер найден
        echo "$(get_timestamp)Delete container ${DOCKER_CONTAINER_NAME}..."
        echo "$(get_timestamp)Run: docker rm -f -v ${DOCKER_CONTAINER_NAME}"
        docker rm -f -v "${DOCKER_CONTAINER_NAME}"
        echo "$(get_timestamp)Delete container ${DOCKER_CONTAINER_NAME}...Ok"
    else
        #Контейнер не найден
        echo "$(get_timestamp)Container ${DOCKER_CONTAINER_NAME} not found"
    fi
fi
echo "$(get_timestamp)Find, stop and delete container ${DOCKER_CONTAINER_NAME}...Ok"


# Сервис rg_postgres - Удаляем Image
echo $SEPARATOR
echo "$(get_timestamp)Find and delete image ${DOCKER_IMAGE_NAME}..."
# Проверяем наличие образа
if docker image inspect "$DOCKER_IMAGE_NAME" > /dev/null 2>&1; then
    echo "$(get_timestamp)Delete Image ${DOCKER_IMAGE_NAME}..."
    echo "$(get_timestamp)Run: docker rmi ${DOCKER_IMAGE_NAME}"
    docker rmi "${DOCKER_IMAGE_NAME}"
    echo "$(get_timestamp)Delete Image ${DOCKER_IMAGE_NAME}...Ok"
else
    echo "$(get_timestamp)Image ${DOCKER_IMAGE_NAME} not found"
fi
echo "$(get_timestamp)Find and delete image ${DOCKER_IMAGE_NAME}...Ok"


echo $SEPARATOR
echo "$(get_timestamp)Find and delete image ${DOCKER_IMAGE_NAME_POSTGRES}..."
# Проверяем наличие образа
if docker image inspect "$DOCKER_IMAGE_NAME_POSTGRES" > /dev/null 2>&1; then
    echo "$(get_timestamp)Delete Image ${DOCKER_IMAGE_NAME_POSTGRES}..."
    echo "$(get_timestamp)Run: docker rmi ${DOCKER_IMAGE_NAME_POSTGRES}"
    docker rmi "${DOCKER_IMAGE_NAME_POSTGRES}"
    echo "$(get_timestamp)Delete Image ${DOCKER_IMAGE_NAME_POSTGRES}...Ok"
else
    echo "$(get_timestamp)Image ${DOCKER_IMAGE_NAME_POSTGRES} not found"
fi
echo "$(get_timestamp)Find and delete image ${DOCKER_IMAGE_NAME_POSTGRES}...Ok"


# Сервис rg_postgres - Удаляем Volume
echo $SEPARATOR
echo "$(get_timestamp)Find and delete volume ${DOCKER_VOLUME_NAME}..."
if docker volume inspect "${DOCKER_VOLUME_NAME}" > /dev/null 2>&1; then
    echo "$(get_timestamp)Delete volume ${DOCKER_VOLUME_NAME}..."
    echo "$(get_timestamp)Run: docker volume rm ${DOCKER_VOLUME_NAME}"
    docker volume rm "${DOCKER_VOLUME_NAME}"
    echo "$(get_timestamp)Delete volume ${DOCKER_VOLUME_NAME}...Ok"
else
    echo "$(get_timestamp)Volume ${DOCKER_VOLUME_NAME} not found"
fi
echo "$(get_timestamp)Find and delete volume ${DOCKER_VOLUME_NAME}...Ok"


if [ "$DOCKER_CLEAR_CACHE_AFTER_DELETE_CONTAINER" = "1" ]; then
    #Чистим кэш в Docker
    echo $SEPARATOR
    echo "$(get_timestamp)Clear all cache (after docker delete)..."
    echo "$(get_timestamp)Run: docker builder prune -a -f"
    docker builder prune -a -f
    echo "$(get_timestamp)Clear all cache (after docker delete)...Ok"
fi


#Показываем память, которую занял Docker
echo $SEPARATOR
echo "$(get_timestamp)Run: docker system df (Show memory):"
docker system df


echo $SEPARATOR
echo "$(get_timestamp)Script end - $(realpath "${BASH_SOURCE[0]}")"





