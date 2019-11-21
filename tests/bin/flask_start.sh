#!/bin/bash

TESTS=$(pwd)
MENTOR_API=$(dirname ${TESTS})
if [ -z ${PROJECT_ROOT} ]; then
	PROJECT_ROOT=$(git rev-parse --show-toplevel 2> /dev/null)
fi

DOCKER_IMAGE=${DOCKER_IMAGE:-mentorpal-mentor-api}
CONTAINER_NAME=mentorpal-mentor-api-testing

# The flask docker image/api we're running
# should be the same one used in production envs,
# so any overrides should be pushed via config file
DOCKER_MOUNT_SRC=${TESTS}/docker_mount
DOCKER_MOUNT_TGT=/app/docker_mount
FLASK_CONFIG_TGT=${DOCKER_MOUNT_TGT}/flask_config.py

echo "testing mentor-api image ${DOCKER_IMAGE}..."

if [[ -z "$USE_MOUNTED_DATA" ]]; then
	docker run \
		-d \
		--rm \
		--name ${CONTAINER_NAME} \
		-p 5000:5000 \
		-e MENTORPAL_CLASSIFIER_API_SETTINGS=${FLASK_CONFIG_TGT} \
	${DOCKER_IMAGE}
else
	echo "running in docker with mounted mentors and checkpoints..."
	docker run \
		-d \
		--rm \
		--name ${CONTAINER_NAME} \
		-p 5000:5000 \
		-v ${PROJECT_ROOT}/tests/resources/checkpoint:/app/checkpoint \
		-v ${PROJECT_ROOT}/tests/resources/mentors:/app/mentors \
		-e MENTORPAL_CLASSIFIER_API_SETTINGS=${FLASK_CONFIG_TGT} \
	${DOCKER_IMAGE}
fi
