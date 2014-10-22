Agave Developer APIs

The Agave Developer APIs are a set of REST APIs that provide the core functionality to the Agave Platform. These services run as OAuth2 protected resources and this require an OAuth2 server in order to interact with them. For ease of deployment, and easier scaling from demo to heavy utilization scenarios, we build and deploy the entire Agave Platform as a series of [Docker](http://docker.com) images. This README will walk you through the trivial process of running a private copy of Agave for yourself. For more information on using the Agave Platform, please see the [Agave Developer Portal](http://agaveapi.co). To get started right away, pull down the Agave CLI as [source](https://bitbucket.org/taccaci/foundation-cli/) or a [Docker image](https://bitbucket.org/taccaci/foundation-cli/src/master/docker/?at=master) and take it for a spin.

## What is the Agave Platform?

The Agave Platform ([http://agaveapi.co](http://agaveapi.co)) is an open source, science-as-a-service API platform for powering your digital lab. Agave allows you to bring together your public, private, and shared high performance computing (HPC), high throughput computing (HTC), Cloud, and Big Data resources under a single, web-friendly REST API.

* Run scientific codes

  *your own or community provided codes*

* ...on HPC, HTC, or cloud resources

  *your own, shared, or commercial systems*

* ...and manage your data

  *reliable, multi-protocol, async data movement*

* ...from the web

  *webhooks, rest, json, cors, OAuth2*

* ...and remember how you did it

  *deep provenance, history, and reproducibility built in*

For more information, visit the [Agave Developer’s Portal](http://agaveapi.co) at [http://agaveapi.co](http://agaveapi.co).


## Using this image

The Agave Developer APIs are distributed in two forms. For development purposes and local testing, a Docker image is available with all the APIs and Live Docs bundled together into a single deployment. For production settings, the services may be run and scaled independently. In this readme, we focus on the development distribution. For information on scaling individual services, see the README files of the individual services.

### Requirements

You will need to have Docker installed to do anything else in this README. Additionally, to automate, manage, and scale the API, you will need to have Fig installed.

* [Docker](https://docs.docker.com/installation/#installation): an open platform for developers and sysadmins to build, ship, and run distributed applications.
* [Fig](http://www.fig.sh/install.html): Fast, isolated development environments using Docker.

You should also add the hostname `agave.example.com` to your /etc/hosts file for convenience later on:

**Mac**

	> sudo echo "$(boot2docker ip 2>/dev/null) agave.example.com" >> /etc/hosts

**Liux**

	> sudo echo "127.0.0.1 agave.example.com" >> /etc/hosts

### External dependencies

The Agave Developer APIs require three external services in order to function:

* [MySQL](http://dev.mysql.com/): the world's most popular open-source relational database.
* [MongoDB](http://www.mongodb.org/): an open-source document database, and the leading NoSQL database.
* [Beanstalkd](http://kr.github.io/beanstalkd/): a simple, fast work queue

Each of these services is available as a Docker image. You can create containers for them manually and link them to the Agave container or you can orchestrate the process with included [Fig](http://fig.sh) file. We leave the decision up to you.

### Running with Fig

	> fig up -d

This is, obviously, the easiest way to run the API. To stop the containers, you would make the following command

	> fig stop


### Running containers manually

Fig is a simple orchestration tool for running multiple linked containers on a single host. You can replicate the behavior by hand with the following commands.

**Start MySQL:**

		> docker run --name some-mysql -d 										\ # Run detached in background
								 -e MYSQL_ROOT_PASSWORD=mysecretpassword 	\ # Default mysql root user password.
								 -e MYSQL_DATABASE=agave-api 							\ # Database name. This should be left constant
								 -e MYSQL_USER=agaveuser 									\ # User username. This can be random as it will be injected at runtime, but should be constant when persisting data
								 -e MYSQL_PASSWORD=password 							\ # User password. This can be random as it will be injected at runtime, but should be constant when persisting data
								 mysql:5.6

**Start MongoDB:**

 		> docker run --name some-mongo -d 		\ # Run detached in background
								 -v `pwd`/mongo:/data/db 	\ # Mongo data directory for persisting db between invocations
								 mongo:2.6

**Start Beanstalkd:**

		> docker run --name some-beanstalkd -d -t 			\ # Run detached in background
		           -p 11300:11300												\ # beanstalkd
		           -v `pwd`/beanstalkd:/data 						\ # Beanstalkd data directory for persisting messages between container invocations
		           agaveapi/beanstalkd

**Start The Agave APIs**

		> docker run -h agave.example.com -i --rm   	\
		           -p 20022:22                  			\ # SSHD, SFTP
		           -p 20443:443                  			\ # Apache SSL
		           --link some-mysql:mysql						\ # MySQL server
		           --link some-mongo:mongo						\ # MongoDB server
		           --link some-beanstalkd:beanstalkd	\ # Beanstalkd server
		           --name some-agave
		           agaveapi/agave-base

**Start The OAuth Server**

		> docker run -h agave.example.com -i --rm   	\
							-p 10022:22                  				\ # SSHD, SFTP
							-p 10443:443                  			\ # Apache SSL
							-p 10080:80                  				\ # Apache
							-p 8080:8080                  			\ # Tomcat
							-p 9443:9443                  			\ # Tomcat SSL
							--link some-agave:agave
							--name oauth
							-v `pwd`/repository:/usr/share/apim/repository \ # persist apim data between sessions
							agaveapi/wso2-apim


## Getting started

From here you can interact with containers at https://agave.example.com. Several options are available to you to explore the Agave Developer APIs:

* [Agave CLI](https://bitbucket.org/taccaci/foundation-cli/src/master/docker/?at=master): a command line interface to the Agave Platform.

	> docker run -i -t --rm -v `$HOME`/.agave:/root/.agave --name agave-cli agaveapi/agave-cli bash

* [Agave ToGo](https://bitbucket.org/taccaci/agave-togo): a lightweight client-side, web application for interacting with Agave.

	> docker run -d -t -p 9000:9000 --name agave-togo agaveapi/agave-togo

* [Agave Live Docs](https://agave.example.com/v2/docs/): a interactive web application allowing you to exercise the APIs without writing any code.

* [Agave Developer Portal](https://agaveapi.co/documentation): the official developer portal for the Agave Platform.
