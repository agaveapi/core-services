# Agave Developer API Server Setup

> Note: This is not the setup for the auth server. The auth server running the WSO2 API Manager has its own configuration tailored to the needs of that machine serving as both a gateway and an auth server. Consult the [agave-apim](https://bitbucket.org/taccaci/agave-apim) project for details on that setup.

This folder contains the primary configuration files needed to properly setup a server to run the Agave APIs. 


## Server installation

Starting out with a clean CentOS 6 image, run the command sin the *yum_installs.txt* file as root to install the necessary depedencies:

* Java 6 JDK,
* Apache 2 + SSL
* PHP 5.3.3
* MySQL 5.1
* Java 6 JDK 
* Tomcat 6.0.37
* Beanstald
* MongoDB
* Git
* Maven 3
* *Globus 5 (optional)*


## Environment setup

The Agave service should run as a service user, so create a user to run the service and deploy the services. **This user should not have login access or a password.**

	$ adduser -g agave,apache agave
	$ chown -R /var/www/html agave
	$ chown -R /usr/local/www/apache-tomcat-6.0.37 apache
	$ su - agave
	$ mkdir -p .globus/certificates
	$ echo "export CATALINA_HOME=/usr/local/www/apache-tomcat-6.0.37" >> .bashrc
	$ echo "export X509_CERT_DIR=~/.globus/certificates" >> .bashrc
	$ git clone ssh://git@bitbucket.org/taccaci/agave.git
	$ cd agave

> Skip the database setup if you are running a separate database server for MySQL and MongoDB

Now create a service account in MySQL for the API to access the database. This should only be accessible locally. You can run the db_setup.sql file to do this.

	$ mysql -uroot -p << ./config/db/mysql_setup.sh
	
Now copy over the service configs to the appropriate places

	$ sudo su -
	$ cp ~agave/agave/config/apache/ssl.conf /etc/httpd/conf.d/ssl.conf 
	$ cp ~agave/agave/config/apache/htaccess /var/www/html/.htaccess
	$ cp ~agave/agave/config/tomcat/tomcat /etc/init.d/tomcat
	$ cp ~agave/agave/config/tomcat/context.xml $CATALINA_HOME/conf/context.xml
	
## Agave API installation

The Agave services are in git...which you know from checking out the code. The project uses submodules to manage the various project dependencies. Intialize and update the git submodules before building.

	$ cd ~/agave
	$ git submodule init
	$ git submodule update

Next you need to update your Maven settings file. A sample file is given in *config/maven/settings.xml*. Update it with the appropriate settings on your server and kick off the Maven build.

	$ mvn -DskipTests clean install
	
This will take a minute...

After the build completes, you need to set up the soft links for the php services, and deploy the wars to Tomcat. The *tomcat_deploy.sh* script does this for you.

	$ ./tomcat_deploy.sh

This takes just a second to run, but you will need to bounce Tomcat after this completes. Generally you do this as root.

	$ sudo service tomcat restart
	
Now you can test the service to see if it's running using the CLI from another server

	$ systems-list -d -V -h "https://someserver.example.com/v2/systems"
	
Once you verify the server is up, enable the firewall to only allow incoming traffic from from the API Manager server and then only on ports 80 and 443. This can be handled by TI at the edge of TACC's network. Server access from inside TACC should be allowed on ports 80, 443, 22, 11300, 3306, 9000, 8080, and 8443.


updated 2014.03.04 15.04.51
	