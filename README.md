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

The Agave Developer APIs are distributed as Docker images. For development purposes and local testing, a Docker image is available with all the APIs and Live Docs bundled together into a single Docker image. For production and distributed deployments, we recommend the production build, which splits each API and worker process into its own image with a load balanced SSL reverse proxy. 

### Requirements

You will need to have Docker installed to do anything else in this README. Additionally, to automate, manage, and scale the API, you will need to have Fig installed.

* [Docker](https://docs.docker.com/installation/#installation): an open platform for developers and sysadmins to build, ship, and run distributed applications.
* [Fig](http://www.fig.sh/install.html): Fast, isolated development environments using Docker.

You should also add the hostname `agave.example.com` to your /etc/hosts file for convenience later on:

**Mac**

	> sudo echo "$(boot2docker ip 2>/dev/null) docker.example.com" >> /etc/hosts
	
	If you are running the 1.3.0 version of boot2docker, you should disable TLS for the build to work. Note, this should ONLY be done on the build server. 
	
	> boot2docker up
	> boot2docker ssh “sudo echo "DOCKER_TLS=no" >> /var/lib/boot2docker/profile”
	> boot2docker down
	> unset DOCKER_TLS_VERIFY
	> unset DOCKER_CERT_PATH
	> boot2docker up
	
	If you find yourself running low on disk in your boot2docker VM, you can resize it. Note, you will have to delete the current ISO to do this. The following commands will double the memory and disk space on your VM.
	
	> boot2docker delete
	> boot2docker init --memory=4096 --disksize=40000 
	> boot2docker up

**Liux**

	> sudo echo "$(netstat -nr | grep '^0\.0\.0\.0' | awk '{print $2}') agave.example.com" >> /etc/hosts

### External dependencies

The Agave Developer APIs require three external services in order to function:

* [MySQL](http://dev.mysql.com/): the world's most popular open-source relational database.
* [MongoDB](http://www.mongodb.org/): an open-source document database, and the leading NoSQL database.
* [Beanstalkd](http://kr.github.io/beanstalkd/): a simple, fast work queue

Each of these services is available as a Docker image. You can create containers for them manually and link them to the Agave container(s) or you can orchestrate the process with [Fig](http://fig.sh) and the included file. We leave the decision up to you.

### Starting the API containers

	> fig up -d

Once the containers start (this may take a minute or two), the APIs will be available at:

	> https://agave.example.com/v2/docs

You may need to import the SSL cert from the container depending on your client library.

### Stopping the API containers

To stop the containers, you would make the following command

	> fig stop

		Fig is a simple orchestration tool for running multiple linked containers on a single host. You can replicate the behavior by hand...but that's insane and error prone. Use Fig.

## Getting started

From here you can interact with containers at 

		https://agave.example.com/docs
		
Several options are available to you to explore the Agave Developer APIs:

* [Agave CLI](https://bitbucket.org/taccaci/foundation-cli/src/master/docker/?at=master): a command line interface to the Agave Platform.

	> docker run -i -t --rm -v `$HOME`/.agave:/root/.agave --name agave-cli agaveapi/agave-cli bash

* [Agave ToGo](https://bitbucket.org/taccaci/agave-togo): a lightweight client-side, web application for interacting with Agave.

	> docker run -d -t -p 9000:9000 --name agave-togo agaveapi/agave-togo

* [Agave Live Docs](https://agave.example.com/v2/docs/): a interactive web application allowing you to exercise the APIs without writing any code.

* [Agave Developer Portal](https://agaveapi.co/documentation): the official developer portal for the Agave Platform.
