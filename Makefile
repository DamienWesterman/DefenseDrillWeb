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
# TODO: make a diagram somewhere of the make system and what interacts with what configurations and build rules and docker-compose files and profiles

include Constants.mk

.PHONY: init configure-prod launch shutdown remove-prod run-dev-local run-dev-docker stop-dev-local stop-dev-docker remove-dev-local remove-dev-docker test clean build-images help
.DELETE_ON_ERROR: help

# Initialize and import the spring repositories
init:
	repo init -u https://github.com/DamienWesterman/DefenseDrillManifests.git -m DefaultManifest.xml -b main
	repo sync
	@echo All repos have been imported!

#########################################################################################
# PRODUCTION COMMANDS #
#########################################################################################
# Set up the production environment
configure-prod: ${PROD_CONFIGURATION_CONFIRMATION_FILE}

${PROD_CONFIGURATION_CONFIRMATION_FILE}:
#	Print a big flashing message to follow instructions
	@echo "\033[5;30;103m *** Please pay attention and follow the subsequent instructions carefully *** \033[0m"
	@echo "" > ${DOCKER_ENVIRONMENT_FILE}

#	Create the spring microservice docker images
	@echo "Creating microservice docker images\n------------------------------"
	@echo "We will now run units tests and build the docker images, this could take up to 10 minutes..."
	@${WAIT_FOR_USER_PROMPT}
	@${DOCKER_COMPOSE_CMD} stop
	@$(MAKE) build-images

# 	Configure Vault
	@echo "\n\n\n\nConfiguring vault\n------------------------------"
	${DOCKER_PROD_DEFINITIONS} ${DOCKER_COMPOSE_CMD_PROD} up -d vault
	@echo "Vault has started, open a new terminal and execute: (keep this terminal open)"
	@echo "\tdocker compose exec -it vault sh"
	@${WAIT_FOR_USER_PROMPT}
	@echo "Run the following command to initialize the vault:"
	@echo "\tvault operator init"
	@${WAIT_FOR_USER_PROMPT}
	@echo "\nMAKE SURE TO SAVE THE GENERATED UNSEAL KEYS AND GENERATED ROOT TOKEN\n"
	@echo "Navigate to the below URL and unlock the vault using 3 of the unseal keys: (keep this tab open)"
	@echo "\thttp://localhost:8200"
	@${WAIT_FOR_USER_PROMPT}
	@echo "Back in the other terminal, run the following commands, ensuring to replace <your_token> with the vault generated root token:"
	@echo "\texport VAULT_TOKEN=<your_token>"
	@echo "\tvault secrets enable -path=secret -version=1 kv"
	@${WAIT_FOR_USER_PROMPT}
	@echo "Go back to the webpage, sign in with your root token, click 'secret/', click 'Create secret', and create the following two secrets:"
	@echo "\tJWT Private key: path=security, key=jwtPrivateKey, value=<your_JWT_private_key>"
	@echo "\tJWT Public key: path=public, key=jwtPublicKey, value=<your_JWT_public_key>"
	@${WAIT_FOR_USER_PROMPT}
	@read -p "Please input the root token here to save to the docker environment: " MY_VAR < /dev/tty && \
		echo VAULT_TOKEN=$$MY_VAR >> ${DOCKER_ENVIRONMENT_FILE}
	@echo "Vault configuration complete, you may now close the webpage and other terminal"
	@${WAIT_FOR_USER_PROMPT}

#	Configure Databases
	@echo "\n\nConfiguring Databases\n------------------------------"
	@read -p "Create a username for the api database admin:  " MY_VAR < /dev/tty && \
		echo API_POSTGRES_USER=$$MY_VAR >> ${DOCKER_ENVIRONMENT_FILE}
	@read -p "Create a password for the api database admin:  " MY_VAR < /dev/tty && \
		echo API_POSTGRES_PASSWORD=$$MY_VAR >> ${DOCKER_ENVIRONMENT_FILE}
	@read -p "Create a username for the security database admin:  " MY_VAR < /dev/tty && \
		echo SECURITY_POSTGRES_USER=$$MY_VAR >> ${DOCKER_ENVIRONMENT_FILE}
	@read -p "Create a password for the security database admin:  " MY_VAR < /dev/tty && \
		echo SECURITY_POSTGRES_PASSWORD=$$MY_VAR >> ${DOCKER_ENVIRONMENT_FILE}
	@echo "Database configurations complete"
	@${WAIT_FOR_USER_PROMPT}

#	Configure file server
	@echo "\n\nConfiguring file server\n------------------------------"
	${DOCKER_PROD_DEFINITIONS} ${DOCKER_COMPOSE_CMD_PROD} up -d file-server
	@echo "File server has started, navigate to the following URL: (keep this tab open)"
	@echo "\thttp://localhost:8097"
	@${WAIT_FOR_USER_PROMPT}
	@echo "Not much has to be done here unless you want to change the login information."
	@echo "\tDefault username: admin"
	@echo "\tDefault password: admin"
	@${WAIT_FOR_USER_PROMPT}

#	Configure the video server (Jellyfin)
	@echo "\n\nConfiguring video server\n------------------------------"
	${DOCKER_PROD_DEFINITIONS} ${DOCKER_COMPOSE_CMD_PROD} up -d video-server
	@echo "Video server has started, navigate to the following URL: (keep this tab open)"
	@echo "\thttp://localhost:8096"
	@${WAIT_FOR_USER_PROMPT}
	@echo "Follow the startup prompts, and make sure you 'Add Media Library' using the following:"
	@echo "\tContent Type: Any"
	@echo "\tDisplay name: Anything"
	@echo "\tClick to add a Folder and select: '\media'"
	@echo "All other options are up to you"
	@${WAIT_FOR_USER_PROMPT}
	@echo "Press enter once you have finished setting up the video server..."
	@${WAIT_FOR_USER_PROMPT}

#	Configure gateway TLS cert
# TODO: FINISH THE ABOVE

#	Prompt user to save default login (adminadmin)
# TODO: FINISH THE ABOVE

	@${DOCKER_COMPOSE_CMD} stop
	@touch ${PROD_CONFIGURATION_CONFIRMATION_FILE}
	@echo Production Environment Configuration Complete!

# Launch the docker microservices in a production environment
launch: ${PROD_CONFIGURATION_CONFIRMATION_FILE}
	@echo "\033[5;30;103m *** Please read the following *** \033[0m"
	@echo "AFTER you hit enter, navigate to the following URL and unseal the vault so the server can fully start up."
	@echo "\thttp://localhost:8200"
	@${WAIT_FOR_USER_PROMPT}
	${DOCKER_PROD_DEFINITIONS} ${DOCKER_COMPOSE_CMD_PROD} up -d

shutdown:
	${DOCKER_COMPOSE_CMD_PROD} stop

remove-prod:
# TODO: FINISH ME make sure to have the user input that they are sure, then maybe again and again
# TODO: make sure this deletes the prod config file

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
