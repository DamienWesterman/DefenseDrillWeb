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
# Copyright 2024 Damien Westerman
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


DOCKER_SPRING_DEPENDENCIES += api-database
DOCKER_DEV_DEFINITIONS += API_POSTGRES_USER=root
DOCKER_DEV_DEFINITIONS += API_POSTGRES_PASSWORD=root

DOCKER_SPRING_DEPENDENCIES += zipkin

DOCKER_SPRING_DEPENDENCIES += security-database
DOCKER_DEV_DEFINITIONS += SECURITY_POSTGRES_USER=root
DOCKER_DEV_DEFINITIONS += SECURITY_POSTGRES_PASSWORD=root

DOCKER_SPRING_DEPENDENCIES += vault
DOCKER_DEV_DEFINITIONS += VAULT_TOKEN=myroot

# TODO: FIXME: Add video server to dependencies - also find a video server

.PHONY: init help run-dev-local run-dev-docker run-prod test-dev-local test-dev-docker test-prod clean docker-build docker-upload
.DEFAULT: help
.DELETE_ON_ERROR: help

# Launch always uses a production/docker environment
launch:
# Make sure the docker-compose environment configuration exists before launching
	@test -f defense_drill.env || { \
			cp .defense_drill.env.template defense_drill.env; \
			echo "Please fill out fields in defense_drill.env before continuing!"; \
			exit 1; \
		}
	@echo MAKING $@
#TODO: finish me

init:
	repo init -u https://github.com/DamienWesterman/DefenseDrillManifests.git -m DefaultManifest.xml -b main
	repo sync
# TODO: Change the file names to variables. Also figure out a way to encrypt the file with a password so it is secure?
	cp .defense_drill.env.template defense_drill.env
	@echo
	@echo All repos have been imported. Please fill out fields in defense_drill.env!

run-dev-local:
	@echo MAKING $@
	${DOCKER_DEV_DEFINITIONS} docker-compose up -d ${DOCKER_SPRING_DEPENDENCIES}
#TODO: finish me

stop-dev-local:
	@echo MAKING $@
	docker-compose stop
#TODO: finish me

run-dev-docker: docker-build
# Run stop-dev-docker first
	@echo MAKING $@
# Specify SPRING_PROFILES_ACTIVE=dev-docker
#TODO: finish me

run-prod:
	@echo MAKING $@
#TODO: finish me

test-dev-local:
	@echo MAKING $@
#TODO: finish me

test-dev-docker:
	@echo MAKING $@
#TODO: finish me

test-prod:
	@echo MAKING $@
#TODO: finish me

clean:
	@echo MAKING $@
#TODO: finish me

docker-build:
	@echo MAKING $@
#TODO: finish me

docker-upload:
	@echo MAKING $@
#TODO: finish me, check for credentials?

help:
	@echo
	@echo "****************************************************************************************************"
	@echo "                                   Make System for DefenseDrillWeb"
	@echo "****************************************************************************************************"
	@echo
	@echo "Targets:"
	@echo "   make help           : Show this help menu."
	@echo "   make launch         : Download and launch docker containers in a production environment."
	@echo "                         May require some configuration the first run."
	@echo
	@echo "   make init           : Initialize the project by pulling in all microservices."
	@echo "                         Needs to be run before anything below."
	@echo "   make run-dev-local  : Run the application in a local development environment. This will"
	@echo "                         launch the necessary docker containers to support the microservices,"
	@echo "                         and the user is expected to launch the spring microservices individually."
	@echo "   make run-dev-docker : Run the application in a docker development environment. Configures and"
	@echo "                       : launches the docker-compose.yaml."
	@echo "   make run-prod       : Run the application in a docker production environment. Configures and"
	@echo "                       : launches the docker-compose.yaml."
# TODO: add stop-dev-local, and any others too
# TODO: figure out how I want to do the test stuff? Unit vs integration? All in docker? Just launch docker base images then run the spring one by one and keep up config server/etc?
	@echo "   make clean          : Clean each microservice."
	@echo "   make docker-build   : Build and save docker images for each microservice."
	@echo "   make docker-upload  : Build and upload docker images of each microservice to a remote repo."
	@echo
