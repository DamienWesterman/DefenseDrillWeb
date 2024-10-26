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

OPTIONS_BUILD_PROFILE := dev-local dev-docker prod

# Command line variables
BUILD_PROFILE     := ${P}

# Functions
check_build_profile = \
	$(if $(filter $(BUILD_PROFILE),$(OPTIONS_BUILD_PROFILE)),,\
	$(error Please define the build profile P= using one of the following: $(OPTIONS_BUILD_PROFILE)))

.PHONY: init help run
.DEFAULT: help
.DELETE_ON_ERROR: help

# Launch always uses a production/docker environment
launch:
	@echo MAKING $@
#TODO: finish me

init:
	repo init -u https://github.com/DamienWesterman/DefenseDrillManifests.git -m DefaultManifest.xml -b main
	repo sync

run:
	$(call check_build_profile)
	@echo MAKING $@
#TODO: finish me

test:
	$(call check_build_profile)
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
	@echo "   make help          : Show this help menu."
	@echo "   make launch        : Download and launch docker containers in a production environemnt."
	@echo "                        May require some configuration the first run."
	@echo
	@echo "   make init          : Initialize the project by pulling in all microservices."
	@echo "                        Needs to be run before anything below."
	@echo "   make run P=        : Run the project, launching any necessary docker containers. Must"
	@echo "                        specify P=build_profile."
	@echo "   make test P=       : Run the test suite for the project. What tests are run depends on P=."
	@echo "   make clean         : Clean each microservice."
	@echo "   make docker-build  : Build and save docker images for each microservice."
	@echo "   make docker-upload : Build and upload docker images of each microservice to a remote repo."
	@echo
	@echo "Variables:"
	@echo "   P=build_profile    : The build profile and environemnt to run in. Options are:"
	@echo "                        ${OPTIONS_BUILD_PROFILE}"
