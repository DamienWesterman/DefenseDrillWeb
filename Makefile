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

# Other todos
# TODO: Make sure that swagger goes through the gateway, otherwise vulnerability
# TODO: Maybe have an interactive docker configs session? Or something, prompt the user
# TODO: Have all the configuration files as templates then copy them over and .gitignore them
# TODO: make a diagram somewhere of the make system and what interacts with what configurations and build rules and docker-compose files and profiles

include Constants.mk

# TODO: add all .PHONY
.PHONY: init configure-prod launch shutdown run-dev-local run-dev-docker stop-dev-local stop-dev-docker remove-dev-local remove-dev-docker test clean build-images help
.DELETE_ON_ERROR: help


#########################################################################################
# LAUNCH COMMANDS #
#########################################################################################
# Initialize and import the spring repositories
init:
	repo init -u https://github.com/DamienWesterman/DefenseDrillManifests.git -m DefaultManifest.xml -b main
	repo sync
	@echo All repos have been imported!

# Set up the production environment
configure-prod: ${PROD_CONFIGURATION_CONFIRMATION_FILE}

${PROD_CONFIGURATION_CONFIRMATION_FILE}:
# TODO: Clear the environment file first
# TODO LIST:
#	1. Start vault
#	2. Enter into the vault - docker compose exec -it vault sh
#	3. vault operator init
#	4. SAVE THE INITIAL ROOT TOKEN AND THE UNSEAL KEYS
#	5. navigate to localhost:8200 (or whatever the endpoint is) and unlock using the unseal keys
#	6. export VAULT_TOKEN=your_vault_token
#	7. vault secrets enable -path=secret -version=1 kv
#	8. Save the root token in the docker environment file

	${DOCKER_COMPOSE_CMD_PROD} up -d vault
# -@ rm ${DOCKER_ENVIRONMENT_FILE_PATH}
# @${DOCKER_COMPOSE_CMD} stop
# @$(MAKE) build-images
# @touch ${PROD_CONFIGURATION_CONFIRMATION_FILE}
# @echo Production Environment Configuration Complete!

# Launch the docker microservices in a production environment
launch: ${PROD_CONFIGURATION_CONFIRMATION_FILE}
# Make sure the docker compose environment configuration exists before launching
	@test -f ${DOCKER_ENVIRONMENT_FILE_PATH} || { \
			cp ${DOCKER_ENVIRONMENT_TEMPLATE_PATH} ${DOCKER_ENVIRONMENT_FILE_PATH}; \
			echo "Please fill out fields in ${DOCKER_ENVIRONMENT_FILE_PATH} before continuing!"; \
			exit 1; \
		}
#TODO: finish me

shutdown:
#TODO: finish me

#########################################################################################
# RUN COMMANDS #
#########################################################################################
# Run the support microservices in docker. NO spring services
run-dev-local:
	${DOCKER_DEV_DEFINITIONS} ${DOCKER_COMPOSE_CMD_DEV} up -d ${DOCKER_DEV_DEPENDENCIES}

# Run all microservices and spring microservices in docker. Expects existing spring images, see 'make build-images'
run-dev-docker:
	${DOCKER_DEV_DEFINITIONS} ${DOCKER_COMPOSE_CMD_DEV} up -d ${DOCKER_DEV_DEPENDENCIES} ${MICROSERVICES}

# Shut down the support microservices without destroying their storage
stop-dev-local:
	${DOCKER_DEV_DEFINITIONS} ${DOCKER_COMPOSE_CMD_DEV} stop

# Shut down all microservices without destroying their storage
stop-dev-docker: stop-dev-local

# Shut down the support microservice and remove their storage
remove-dev-local:
	${DOCKER_DEV_DEFINITIONS} ${DOCKER_COMPOSE_CMD_DEV} down -v

# Shut down all microservice and remove their storage
remove-dev-docker: stop-dev-docker remove-dev-local

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

#########################################################################################
# HELP MESSAGE #
#########################################################################################
# Display the help message
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
