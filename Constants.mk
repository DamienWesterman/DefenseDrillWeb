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
# Copyright 202 Damien Westerman
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

# Hard code this in the proper startup order #TODO: MAKE SURE ALL THESE AR UNCOMMENTED
MICROSERVICES := config-server server-registry #rest-api security mvc gateway

#########################################################################################
# SPRING VARIABLES #
#########################################################################################

#########################################################################################
# DOCKER VARIABLES #
#########################################################################################
DOCKER_COMPOSE_CMD := docker compose
DOCKER_CONFIG_DIR := ./docker-configs
DOCKER_ENVIRONMENT_FILE := defense_drill.env
DOCKER_ENVIRONMENT_FILE_PATH := ${DOCKER_CONFIG_DIR}/${DOCKER_ENVIRONMENT_FILE}
DOCKER_ENVIRONMENT_TEMPLATE_PATH := ${DOCKER_CONFIG_DIR}/.${DOCKER_ENVIRONMENT_FILE}.template

DOCKER_DEV_DEPENDENCIES =

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
