# /****************************\
# *      ________________      *
# *     /  _             \     *
# *     \   \ |\   _  \  /     *
# *      \  / | \ / \  \/      *
# *      /  \ | / | /  /\      *
# *     /  _/ |/  \__ /  \     *
# *     \________________/     *
# *                            *
# \****************************/
#
# Copyright 2025 Damien Westerman
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Hard code this in the proper startup order
MICROSERVICES := config-server server-registry rest-api security mvc gateway
PRIVATE_IP_ADDRESS := ${shell hostname -I | awk '{print $$1;}'}

WAIT_FOR_USER_PROMPT := read -p "Press enter to continue..." ignore_var < /dev/tty

GATEWAY_HTTPS_CERT_DIRECTORY := ./docker-configs/gateway-https.p12

DOCKER_FILE_COMMON := ./docker-compose.yaml
DOCKER_FILE_DEV := ./docker-compose.dev.yaml
DOCKER_FILE_PROD := ./docker-compose.prod.yaml
DOCKER_COMPOSE_CMD := docker compose
DOCKER_COMPOSE_CMD_DEV := ${DOCKER_COMPOSE_CMD} -f ${DOCKER_FILE_COMMON} -f ${DOCKER_FILE_DEV}
DOCKER_COMPOSE_CMD_PROD := ${DOCKER_COMPOSE_CMD} -f ${DOCKER_FILE_COMMON} -f ${DOCKER_FILE_PROD}
DOCKER_CONFIG_DIR := ./docker-configs
PROD_CONFIGURATION_CONFIRMATION_FILE := ${DOCKER_CONFIG_DIR}/.production_configured.txt
DOCKER_ENVIRONMENT_FILE := ./.env

DOCKER_DEV_DEPENDENCIES =
DOCKER_DEV_DEFINITIONS =

DOCKER_DEV_DEFINITIONS += SPRING_PROFILES=dev
DOCKER_DEV_DEFINITIONS += PRIVATE_IP_ADDRESS=${PRIVATE_IP_ADDRESS}

DOCKER_DEV_DEPENDENCIES += api-database
DOCKER_DEV_DEFINITIONS += API_POSTGRES_USER=root
DOCKER_DEV_DEFINITIONS += API_POSTGRES_PASSWORD=root

DOCKER_DEV_DEPENDENCIES += zipkin

DOCKER_DEV_DEPENDENCIES += security-database
DOCKER_DEV_DEFINITIONS += SECURITY_POSTGRES_USER=root
DOCKER_DEV_DEFINITIONS += SECURITY_POSTGRES_PASSWORD=root

DOCKER_DEV_DEPENDENCIES += vault
DOCKER_DEV_DEFINITIONS += VAULT_TOKEN=myroot

DOCKER_DEV_DEPENDENCIES += video-server
UID := $(shell id -u)
GID := $(shell id -g)
DOCKER_DEV_DEFINITIONS += UID=${UID}
DOCKER_DEV_DEFINITIONS += GID=${GID}

DOCKER_DEV_DEPENDENCIES += file-server

DOCKER_PROD_DEFINITIONS =
DOCKER_PROD_DEFINITIONS += SPRING_PROFILES=prod
DOCKER_PROD_DEFINITIONS += PRIVATE_IP_ADDRESS=${PRIVATE_IP_ADDRESS}
DOCKER_PROD_DEFINITIONS += UID=${UID}
DOCKER_PROD_DEFINITIONS += GID=${GID}
