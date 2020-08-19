#!/bin/bash
##
## This software is Copyright ©️ 2020 The University of Southern California. All Rights Reserved.
## Permission to use, copy, modify, and distribute this software and its documentation for educational, research and non-profit purposes, without fee, and without a written agreement is hereby granted, provided that the above copyright notice and subject to the full license file found in the root of this software deliverable. Permission to make commercial use of this software may be obtained by contacting:  USC Stevens Center for Innovation University of Southern California 1150 S. Olive Street, Suite 2300, Los Angeles, CA 90115, USA Email: accounting@stevens.usc.edu
##
## The full terms of this copyright and license should always be found in the root directory of this software deliverable as "license.txt" and if these terms are not found with this software, please contact the USC Stevens Center for the full license.
##

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
