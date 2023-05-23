.ONESHELL:
SHELL := /bin/bash
# Variables
PROJECT_NAME:=terraform

help: ; @ \
    clear; \
    echo ''; \
    echo 'Usage instructions:'; \
    echo ''; \
    echo 'make start:  \tStart the test environment'; \
	echo 'make stop:   \tStop the test environment'; \
	echo 'make status: \tShow the status of the test environment'; \
	echo 'make logs:   \tShow logs from the test environment'; \

start: ; @\
    clear; \
    echo "[Starting the environment...]"; \
    echo ""; \
    docker-compose -f ./test/docker-compose.yml -p ${PROJECT_NAME} up -d; \
    echo ""; \

stop: ; @\
    clear; \
    echo "[Stopping the environment...]"; \
    echo ""; \
    docker-compose -f ./test/docker-compose.yml -p ${PROJECT_NAME} down; \
    echo ""; \

status: ; @\
    clear; \
    echo "[Showing the status of the environment...]"; \
    echo ""; \
    docker-compose -f ./test/docker-compose.yml -p ${PROJECT_NAME} ps; \
    echo ""; \

logs: ; @\
    clear; \
    echo "[Showing the status of the environment...]"; \
    echo ""; \
    docker-compose -f ./test/docker-compose.yml -p ${PROJECT_NAME} logs -f; \
    echo ""; \

test_init: ; @\
    clear; \
    echo "[Testing the environment...]"; \
    echo ""; \
    docker run --rm \
		--network ${PROJECT_NAME}_default \
		--workdir /app \
		--volume $(shell pwd)/test/kubeconfig:/root/.kube \
		--volume $(shell pwd)/test/main.tf:/app/main.tf \
		--volume $(shell pwd)/modules:/terraform/modules \
		--volume $(shell pwd)/main.tf:/terraform/main.tf \
		--volume $(shell pwd)/variables.tf:/terraform/variables.tf \
<<<<<<< HEAD
		-it --entrypoint /bin/sh hashicorp/terraform:0.13.7 ; \
=======
		-it --entrypoint /bin/sh hashicorp/terraform:0.14.11 ; \
>>>>>>> 6fad68d914a3e3a8452294728cbccec2c6982237
    echo ""; \