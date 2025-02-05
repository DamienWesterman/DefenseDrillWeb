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

### TODO LIST ###
# TODO: Get create-docker-images
# TODO: Do what it takes to get run-dev-docker working
# TODO: have doc comments for each make target


# Other todos
# TODO: Maybe have an interactive docker configs session? Or something, prompt the user
# TODO: Have all the configuration files as templates then copy them over and .gitignore them
# TODO: make a diagram somewhere of the make system and what interacts with what configurations and build rules and docker-compose files and profiles

include Constants.mk

# TODO: add all .PHONY
.PHONY: init help run-dev-local run-dev-docker run-prod test-dev-local test-dev-docker test-prod clean docker-build docker-upload
.DEFAULT: help
.DELETE_ON_ERROR: help

# Launch always uses a production/docker environment
launch:
# Make sure the docker compose environment configuration exists before launching
	@test -f ${DOCKER_ENVIRONMENT_FILE_PATH} || { \
			cp ${DOCKER_ENVIRONMENT_TEMPLATE_PATH} ${DOCKER_ENVIRONMENT_FILE_PATH}; \
			echo "Please fill out fields in ${DOCKER_ENVIRONMENT_FILE_PATH} before continuing!"; \
			exit 1; \
		}
#TODO: finish me

init:
	repo init -u https://github.com/DamienWesterman/DefenseDrillManifests.git -m DefaultManifest.xml -b main
	repo sync
# TODO: Change the file names to variables. Also figure out a way to encrypt the file with a password so it is secure?
	cp ${DOCKER_ENVIRONMENT_TEMPLATE_PATH} ${DOCKER_ENVIRONMENT_FILE_PATH}
	@echo
	@echo All repos have been imported. Please fill out fields in ${DOCKER_ENVIRONMENT_FILE_PATH}!

run-dev-local:
	${DOCKER_DEV_DEFINITIONS} ${DOCKER_COMPOSE_CMD} up -d ${DOCKER_DEV_DEPENDENCIES}

run-dev-docker:
	${DOCKER_DEV_DEFINITIONS} ${DOCKER_COMPOSE_CMD} up -d ${DOCKER_DEV_DEPENDENCIES} ${MICROSERVICES}
# Specify SPRING_PROFILES_ACTIVE=dev-docker
#TODO: finish me

stop-dev-local:
	${DOCKER_DEV_DEFINITIONS} ${DOCKER_COMPOSE_CMD} stop

stop-dev-docker: stop-dev-local

remove-dev-local:
	${DOCKER_DEV_DEFINITIONS} ${DOCKER_COMPOSE_CMD} down -v

remove-dev-docker: stop-dev-docker remove-dev-local

run-prod:
#TODO: finish me

#########################################################################################
# TEST #
#########################################################################################
# Run the test suite for each microservice
SPRING_MICROSERVICES_DIRECTORY := ${shell pwd}/spring_microservices
CMD_KILL_RUNNING_SPRING_SERVERS := kill $$(pgrep -f "spring-boot:run")
TEST_RESULTS_FILE := ${SPRING_MICROSERVICES_DIRECTORY}/test_results.txt
test: remove-dev-local run-dev-local
	@echo "Testing DefenseDrillWeb"
	-@rm ${TEST_RESULTS_FILE}
	@touch ${TEST_RESULTS_FILE}
	@echo "Starting tests at:" >> ${TEST_RESULTS_FILE}
	@date >> ${TEST_RESULTS_FILE}
	-@${CMD_KILL_RUNNING_SPRING_SERVERS}
#	We test and start each service in order. We assume ${MICROSERVICES} is in startup order
	@for service in ${MICROSERVICES} ; do								\
		cd ${SPRING_MICROSERVICES_DIRECTORY}/$$service/ ;				\
		set -e;															\
		./mvnw test ;													\
		./mvnw spring-boot:run > /dev/null & 							\
		echo WAITING FOR SERVICE TO START : $$service ; 				\
		echo Tests succeeded for $$service >> ${TEST_RESULTS_FILE} ;	\
		sleep 30 ; 														\
	done
	-@${CMD_KILL_RUNNING_SPRING_SERVERS}
	$(MAKE) remove-dev-local
	@echo "Finished tests at:" >> ${TEST_RESULTS_FILE}
	@date >> ${TEST_RESULTS_FILE}
	@echo All Tests Succeeded !


#########################################################################################
# CLEAN #
#########################################################################################
# Run clean for each microservice
clean:
	@for service in ${MICROSERVICES} ; do					\
		cd ${SPRING_MICROSERVICES_DIRECTORY}/$$service/ ;	\
		set -e;												\
		./mvnw clean;										\
	done

#########################################################################################
# BUILD IMAGES #
#########################################################################################
# Create a local docker image of each spring microservice
build-images: test
	@for service in ${MICROSERVICES} ; do											\
		cd ${SPRING_MICROSERVICES_DIRECTORY}/$$service/ ;							\
		set -e;																		\
		./mvnw spring-boot:build-image -DskipTests -Dspring-boot.build-image.imageName=defensedrillweb/$$service:latest;	\
	done

docker-upload:
#TODO: finish me, check for credentials?
# TODO: Make the images as the regular ones and upload with version number AND latest

# TODO: update the below
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
	@echo "   make test           : Runs test suites for each microservice. Results saved in"
	@echo "                         ${TEST_RESULTS_FILE}"
	@echo "   make clean          : Clean each microservice."
	@echo "   make docker-build   : Build and save docker images for each microservice."
	@echo "   make docker-upload  : Build and upload docker images of each microservice to a remote repo."
	@echo
