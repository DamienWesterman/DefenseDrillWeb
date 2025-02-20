# DefenseDrillWeb
Central Hub for the web backend of the [DefenseDrillApp](https://github.com/DamienWesterman/DefenseDrill)

# Introduction
This serves as the backend and maintenance server for the related mobile application. It allows a mobile user to download all drills kept in the backend's database and access instructional how-to steps and videos. It offers an admin portal for database and user maintenance, as well as server metrics.

# Related Repositories
- [Android DefenseDrill App](https://github.com/DamienWesterman/DefenseDrill)
- [DefenseDrill Manifests Repo](https://github.com/DamienWesterman/DefenseDrillManifests)
- [Configuration Server Spring Microservice](https://github.com/DamienWesterman/DefenseDrillConfigServer)
- [Server Registry Spring Microservice](https://github.com/DamienWesterman/DefenseDrillServerRegistry)
- [RESTful API Spring Microservice](https://github.com/DamienWesterman/DefenseDrillRestAPI)
- [Security Spring Microservice](https://github.com/DamienWesterman/DefenseDrillSecurity)
- [MVC Front End Spring Microservice](https://github.com/DamienWesterman/DefenseDrillMVC)
- [API Gateway Spring Microservice](https://github.com/DamienWesterman/DefenseDrillGateway)

# System Requirements
- Linux based OS (tested and built on Ubuntu)
- Have [git](https://git-scm.com/downloads/linux) installed
- Have [repo](https://android.googlesource.com/tools/repo) installed
- Have [make](https://ioflood.com/blog/install-make-command-linux/) installed
- Have [docker](https://docs.docker.com/engine/install/) installed
- Have [docker compose](https://docs.docker.com/compose/install/linux/#install-using-the-repository) installed
- JRE 17 or above

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
## API
All API requests (except to `/authenticate`) need to include a JWT cookie - see below for authentication. Only `GET` methods are allowed through the gateway. For request parameters, endpoints, and returns please refer to the api documentation endpoint, which is located at the following endpoint:
- For development servers: `http://localhost:5433/swagger-ui/index.html`
- For production servers: `/docs/index.html`

To authenticate:
1. Send a `POST` request to `/authenticate` with the following JSON payload:
```
{
   "username":"YOUR_USERNAME",
   "password":"YOUR_PASSWORD"
}
```
2. Response: A JWT is returned in the response body as `YOUR_JWT`
3. Include the JWT in all API requests as a cookie in the format `jwt=YOUR_JWT`

User credentials can only be obtained through the admin web portal.
## Web Portal
The admin web portal uses a simple card based system to maintain the backend. The home screen offers links to the database maintenance as well as other microservice maintenance portals:

<img src="docs/screenshots/home_screen.png" alt="Home Screen" width="2000"/>

The modify options allow for maintenance of the databases, giving options to create, view, update, and delete entries. The tab options on the left offer SPA like functionalities and will update the view window on the right. Each option is simple and intuitive and offers simple forms for modification:

<img src="docs/screenshots/modify_screen.png" alt="Home Screen" width="2000"/>

This webpage is best viewed on a landscape PC monitor and is not optimized for mobile.

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
Many of the design choices in this project were based on learning industry standard technologies and architectures, as well as creating a simple and functional solution. However, note that UI is not the focus of this project nor a skill that I want to focus on, and thus is very simple. Some considerations were as follows:
### Microservices, docker, and Spring
Spring is a widely used Java web development and backend framework, with a lot of support and built in features and easily applied dependencies. Microservice architectures offers a modular solution with clear separation of concerns. With Spring's flexible configurations and different options of functionality, it lends well to the microservice architecture. And when it comes to coordinating multiple services, docker compose is a widely used solution that allows simple and reliable container orchestration.
### Servlet Configuration
Spring supports both traditional blocking-based request handling and event-driven reactive handling. While reactive programming offers more efficiency and better scaling possibilities, this project uses a servlet based blocking handling. This offers less overhead for request handling and lowers code complexity, as the efficiency and scalability is less important due to the size of the project.
### TDD
Because of its efficacy of creating robust code, applicable microservices (rest-api and security) were developed using Test Driven Development. Not only does this allow the developer to focus on simplifying solutions, it also offers proper regression testing for any subsequent code changes, creating a more stable solution. However, as mentioned UI was not a heavy focus and while testing solutions like Selenium exist there is no automated testing for the UI.

---
However, due to the simplicity and the low sensitivity nature of the project, there are a few limitations:
### Security
While there are access controls in place, there are less layers of security in this project than might be found in more sensitive applications. There are authentication and authorization methods in place to only allow proper users access to certain endpoints. And by using docker containers and docker compose in production, direct access to many of the microservices is inherently limited. Many of the security systems rely on proper networking and physical access, though. Some examples include:
- The gateway (port 8443) should be the only publicly exposed port, so that requests go through the gateway. However, since only the gateway handles JWT validation, bypassing it may grant unauthorized access.
- The microservices communicate inside the docker network via http (not https), and thus data in transit is unencrypted internally.
- In each docker container, passwords are stored as environment variables, and certificates are not in a vault, making them vulnerable if an attacker gains physical access.
### UI
As mentioned, UI was not the focus of this project and therefore the effort was simplicity. A simple card based solution was used for many of the screens. On the backend, Thymeleaf was used as a templating engine for the MVC rendering implementation. This gives more control to the backend logic. For the front end, to create SPA like webpages, HTMX was used to lower load time and increase usability. That said, there may be some accessibility issues, lack of engaging design, or lack of features. It is also not optimized for different sized screens, and therefore may have issues on something other than a landscape PC monitor. But given how the web page is only for administrative purposes, these drawbacks have been deemed acceptable.

# Future Improvements
For guided learning, there could be a mentor/mentee mode where as new drills are learned, the mentor can use the web portal to push new drills onto a mentee's app; or potentially curate workouts or force certain drills to come up more frequently.

# License
This project is licensed under the Apache License 2.0. For details, see the LICENSE file.
