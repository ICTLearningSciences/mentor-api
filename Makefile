BLACK_EXCLUDES="/(\.venv|build)/"
DOCKER_CONTAINER?=mentor-api
PWD=$(shell pwd)
PROJECT_ROOT?=$(shell git rev-parse --show-toplevel 2> /dev/null)
PROJECT_NAME?=mentorpal
RESOURCE_ROOT?=$(PROJECT_ROOT)/tests/resources
DOCKER_BASE_IMAGE?=uscictdocker/mentor-classifier:1.0.0
DOCKER_IMAGE?=mentor-api
DOCKER_IMAGE_ID=$(shell docker images -q ${DOCKER_IMAGE} 2> /dev/null)
TEST_IMAGE?=mentor-api-test

VENV=.venv
VENV_PIP=$(VENV)/bin/pip
$(VENV):
	$(MAKE) test-env-create

virtualenv-installed:
	$(PROJECT_ROOT)/bin/virtualenv_ensure_installed.sh

.PHONY: docker-build
docker-build:
	docker build \
		-t $(DOCKER_IMAGE) \
		--build-arg MENTORPAL_CLASSIFIER_IMAGE=$(DOCKER_BASE_IMAGE) \
	.

.PHONY: docker-image-exists
docker-image-exists:
ifeq ("$(DOCKER_IMAGE_ID)", "")
	@echo "image not found for tag $(DOCKER_IMAGE), building..."
	$(MAKE) docker-build
endif
	

.PHONY: docker-run
docker-run: docker-image-exists
	docker run \
			-it \
			--rm \
			--name $(DOCKER_CONTAINER) \
			--shm-size 8G \
			-v $(RESOURCE_ROOT)/checkpoint:/app/checkpoint \
			-v $(RESOURCE_ROOT)/mentors:/app/mentors \
			-p 5000:5000 \
		$(DOCKER_IMAGE)


.PHONY: docker-run-checkpoint/%
docker-run-checkpoint/%: docker-image-exists
	docker run \
			-it \
			--rm \
			--name $(DOCKER_CONTAINER) \
			-v $(RESOURCE_ROOT)/checkpoint:/app/checkpoint \
			-v $(RESOURCE_ROOT)/mentors:/app/mentors \
			-v $(PWD)/src/mentor_api:/app/mentor_api \
			-e CLASSIFIER_CHECKPOINT=$* \
			--shm-size 8G \
			-p 5000:5000 \
		$(DOCKER_IMAGE)


.PHONY: docker-run-dev
docker-run-dev: docker-image-exists
	docker run \
			-it \
			--rm \
			--name $(DOCKER_CONTAINER) \
			--shm-size 8G \
			-p 5000:5000 \
			-v $(RESOURCE_ROOT)/checkpoint:/app/checkpoint \
			-v $(RESOURCE_ROOT)/mentors:/app/mentors \
			-v $(PWD)/src/mentor_api:/app/mentor_api \
		$(DOCKER_IMAGE) 


.PHONY: docker-run-dev-shell
docker-run-dev-shell: docker-image-exists
	docker run \
			-it \
			--rm \
			--name $(DOCKER_CONTAINER) \
			--shm-size 8G \
			-p 5000:5000 \
			-v $(RESOURCE_ROOT)/checkpoint:/app/checkpoint \
			-v $(RESOURCE_ROOT)/mentors:/app/mentors \
			-v $(PWD)/src/mentor_api:/app/mentor_api \
			--entrypoint /bin/bash \
		$(DOCKER_IMAGE) 


.PHONY: exec-shell
exec-shell:
	docker exec \
			-it \
		$(DOCKER_CONTAINER) \
			bash

.PHONY: format
format: $(VENV)
	$(VENV)/bin/black --exclude $(BLACK_EXCLUDES) .

.PHONY: test-env-create
test-env-create: virtualenv-installed
	[ -d $(VENV) ] || virtualenv -p python3 $(VENV)
	$(VENV_PIP) install --upgrade pip
	$(VENV_PIP) install -r requirements.txt
	$(VENV_PIP) install -r requirements.test.txt
	$(VENV_PIP) install -r requirements.test.p2.txt

.PHONY: test-format-python
test-format: $(VENV)
	$(VENV)/bin/black --check --exclude $(BLACK_EXCLUDES) .

.PHONY: test-lint
test-lint: $(VENV)
	$(VENV)/bin/flake8 .

.PHONY: test-units
test-units: $(VENV)
	. $(VENV)/bin/activate \
		&& export PYTHONPATH=$${PYTHONPATH}:$(PROJECT_ROOT)/src \
		&& export CLASSIFIER_CHECKPOINT_ROOT=$(RESOURCE_ROOT)/checkpoint \
		&& $(VENV)/bin/py.test -vv


.PHONY: test-integrations
test-integrations: $(VENV) docker-image-exists
	. $(VENV)/bin/activate \
		&& cd tests \
		&& export DOCKER_IMAGE=$(DOCKER_IMAGE) \
		&& export USE_MOUNTED_DATA=1 \
		&& ./bin/flask_start.sh \
		&& ./bin/wait_for_server_then_run_tests.sh \
		&& ./bin/flask_stop.sh

.PHONY: test
test:
	$(MAKE) test-units
	$(MAKE) test-integrations

.PHONY: test-image-build
test-image-build:
	cd test-image && \
		MENTOR_API_IMAGE=$(DOCKER_IMAGE) \
		TEST_IMAGE=$(TEST_IMAGE) \
		$(MAKE) docker-build

.PHONY: test-image
test-image:
	cd test-image && \
		MENTOR_API_IMAGE=$(DOCKER_IMAGE) \
		TEST_IMAGE=$(TEST_IMAGE) \
		$(MAKE) test
