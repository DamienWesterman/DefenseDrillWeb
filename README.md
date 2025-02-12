# DefenseDrillWeb
Central Hub for the web backend of the [DefenseDrillApp](https://github.com/DamienWesterman/DefenseDrill)

# Introduction

# Related Repositories
- [Android DefenseDrill App](https://github.com/DamienWesterman/DefenseDrill)
- [DefenseDrill Manifests Repo](https://github.com/DamienWesterman/DefenseDrillManifests)
- [Configuration Server Spring Microservice](https://github.com/DamienWesterman/DefenseDrillConfigServer)
- [Server Registry Spring Microservice](https://github.com/DamienWesterman/DefenseDrillServerRegistry)
- [RESTful API Spring Microservice](https://github.com/DamienWesterman/DefenseDrillRestAPI)
- [Security Spring Microservice](https://github.com/DamienWesterman/DefenseDrillSecurity)
- [MVC Front End Spring Microservice](https://github.com/DamienWesterman/DefenseDrillMVC)
- [API Gateway Spring Microservice](https://github.com/DamienWesterman/DefenseDrillGateway)

# Technologies Used
- Spring / Spring Boot
- Java
- JUnit/Mockito for testing
- Jakarta Persistence API
- PostgreSQL / SQL
- Microservice Architecture
- MVC Architecture
- RESTful API
- Repo
- Git
- Docker / Docker Compose
- Make

# Design Considerations

# Limitations

# System Requirements
- [ ] Linux based OS (tested and built on Ubuntu)
- [ ] Have [git](https://git-scm.com/downloads/linux) installed
- [ ] Have [repo](https://android.googlesource.com/tools/repo) installed
- [ ] Have [make](https://ioflood.com/blog/install-make-command-linux/) installed
- [ ] Have [docker](https://docs.docker.com/engine/install/) installed
- [ ] Have [docker compose](https://docs.docker.com/compose/install/linux/#install-using-the-repository) installed
- [ ] JRE 17 or above

# Setup and Installation
As long as all the system requirements are met, installing and starting the server is simple:
1. Clone the repository:
```
git clone https://github.com/DamienWesterman/DefenseDrillWeb.git
```
2. Run the repo command to import the other microservices:
```
make init
```
3. Depending on your desired environment, continue with one of the following make commands:
   1. You can always run the help command to see all options.
      ```
      make help
      ```
   2. Run the production server. This will start an interactive session for configuring and launching the production environment.
      ```
      make launch
      ```
   3. Run a development server with all microservices running in docker. You will have to create the docker images for the spring microservices first.
      ```
      make build-images
      make run-dev-docker
      ```
   4. Run the supporting docker containers (such as the PostgreSQL databases) for active development. This will require you to manually start each spring microservice, make sure to run config-server first.
      ```
      make run-dev-local
      ```

# Usage

# Future Improvements

# License
This project is licensed under the Apache License 2.0. For details, see the LICENSE file.
