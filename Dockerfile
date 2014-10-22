######################################################
#
# Agave API Base Image
# Tag: agaveapi/agave-base
#
# This is a vanilla iRODS server used for testing iRODS
# support in the Agave API. It is the base container for
# the API and worker containers that actually run the API.
# You can run the entire API out of this single image or
# use the child images to scale out individual components.
# It is possible to mix and match approaches. In order to
# run the API, you will need several additional services.
# The easiest way to deploy them is using Fig.
#
# fig up
#
# You can also
# use the following commands to start up Agave and its
# dependencies manually.
#
# Start MySQL:
# docker run --name some-mysql -d 										\ # Run detached in background
#						 -e MYSQL_ROOT_PASSWORD=mysecretpassword 	\ # Default mysql root user password.
#						 -e MYSQL_DATABASE=agave-api 							\ # Database name. This should be left constant
#						 -e MYSQL_USER=agaveuser 									\ # User username. This can be random as it will be injected at runtime, but should be constant when persisting data
#						 -e MYSQL_PASSWORD=password 							\ # User password. This can be random as it will be injected at runtime, but should be constant when persisting data
#						 -v `pwd`/mysql:/var/lib/mysql 						\ # MySQL data directory for persisting db between container invocations
#						 mysql:5.6
#
# Start MongoDB:
# docker run --name some-mongo -d 		\ # Run detached in background
#						 -v `pwd`/mongo:/data/db 	\ # Mongo data directory for persisting db between invocations
#						 mongo:2.6
#
# Start Beanstalkd:
# docker run --name some-beanstalkd -d -t 				\ # Run detached in background
#            -p 10022:22             							\ # SSHD, SFTP
#            -p 11300:11300												\ # beanstalkd
#            -v `pwd`/beanstalkd:/data 						\ # Beanstalkd data directory for persisting messages between container invocations
#            agaveapi/beanstalkd
#
# Start Agave APIs
# docker run -h docker.example.com -i --rm    	\
#            -p 10022:22                  			\ # SSHD, SFTP
#            -p 10443:443                  			\ # Apache SSL
#            -p 10080:80                  			\ # Apache
#            -p 8080:8080                  			\ # Tomcat
#            -p 8443:8443                  			\ # Tomcat SSL
#            --link some-mysql:mysql						\ # MySQL server
#            --link some-mongo:mongo						\ # MongoDB server
#            --link some-beanstalkd:beanstalkd	\ # Beanstalkd server
#            --name agave												\ # MySQL server
#            agaveapi/agave-base
#
# https://bitbucket.org/taccaci/agave-environment
#
######################################################

FROM centos:centos6

MAINTAINER Rion Dooley <dooley@tacc.utexas.edu>

RUN rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm

RUN yum -y install bind-utils sendmail sendmail-cf httpd unzip tar mod_ssl openssl git vi-minimal php php-mysql php-ldap php-mysql php-pear php-xml php-curl php-xmlrpc php-mcrypt supervisor openssh-server openssh-clients

# Generate ssl certs
RUN openssl genrsa -out ca.key 2048 && \
		openssl req -new -key ca.key -out ca.csr -subj '/C=US/ST=TX/L=Austin/O=University of Texas/OU=TACC/CN=Agave' && \
		openssl x509 -req -days 365 -in ca.csr -signkey ca.key -out ca.crt && \
		cp ca.crt /etc/pki/tls/certs && \
		cp ca.key /etc/pki/tls/private/ca.key && \
		cp ca.csr /etc/pki/tls/private/ca.csr && \
		chown -R apache:apache /var/www/html/

# Install Java 7
RUN curl -LO 'http://download.oracle.com/otn-pub/java/jdk/7u51-b13/jdk-7u51-linux-x64.rpm' -H 'Cookie: oraclelicense=accept-securebackup-cookie' && \
		rpm -i jdk-7u51-linux-x64.rpm && \
		rm jdk-7u51-linux-x64.rpm
ENV JAVA_HOME /usr/java/default

WORKDIR /usr/share

# Install Tomcat6 && Maven

RUN curl -skO http://apache.cs.utah.edu/tomcat/tomcat-6/v6.0.41/bin/apache-tomcat-6.0.41.tar.gz && \
		tar xzf apache-tomcat-6.0.41.tar.gz && \
		rm apache-tomcat-6.0.41.tar.gz && \
		mv apache-tomcat-6.0.41 tomcat6 && \
		curl -O ftp://mirror.reverse.net/pub/apache/maven/maven-3/3.0.5/binaries/apache-maven-3.0.5-bin.tar.gz && \
		tar xzf apache-maven-3.0.5-bin.tar.gz && \
		ln -s /usr/share/apache-maven-3.0.5/bin/mvn /usr/bin/mvn && \
		rm apache-maven-3.0.5-bin.tar.gz && \
		mkdir /root/.m2

# Setup login for SSHD
RUN mkdir -p /var/run/sshd && \
    echo "root:root" | chpasswd && \
		service sshd start && \
		sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config && \
		sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config

# Add project source
WORKDIR /agave

ADD agave-apidocs /agave/agave-apidocs
ADD agave-apps /agave/agave-apps
ADD agave-auth /agave/agave-auth
ADD agave-common /agave/agave-common
ADD agave-files /agave/agave-files
ADD agave-jobs /agave/agave-jobs
ADD agave-logging /agave/agave-logging
ADD agave-metadata /agave/agave-metadata
ADD agave-monitors /agave/agave-monitors
ADD agave-notifications /agave/agave-notifications
ADD agave-postits /agave/agave-postits
ADD agave-profiles /agave/agave-profiles
ADD agave-systems /agave/agave-systems
#ADD agave-tenants /agave/agave-tenants
ADD agave-transforms /agave/agave-transforms
#ADD agave-usage /agave/agave-usage
ADD agave-wso2-mediator /agave/agave-wso2-mediator
ADD pom.xml /agave/pom.xml
ADD config/maven/settings.xml /root/.m2/

# Build Agave APIs
RUN	mvn -Dskip.integration.tests=true -Dmaven.test.skip=true -Dforce.check.update=false -Dforce.check.version=false clean install

# Deploy Agave documentation
RUN mkdir -p /var/www/html/v2 && \
		chmod -R 755 /var/www/html/v2 && \
		rm -rf /var/www/html/v2/docs && \
		ln -s /agave/agave-apidocs/apidocs-api/target/classes /var/www/html/v2/docs && \
		chmod -R 755 /var/www/html/v2/docs

# Deploy PHP APIs to web root
RUN for i in auth postits logging; do rm -rf /var/www/html/v2/$i ; ln -s /agave/agave-$i/$i-api/target/classes /var/www/html/v2/$i ; chmod -R 755 /var/www/html/v2/$i ; done

# Deploy Java APIs to Tomcat
RUN	for i in apps jobs files metadata monitors notifications profiles systems transforms; do rm -rf $CATALINA_HOME/webapps/$i* $CATALINA_HOME/webapps/work/Catalina/localhost/$i ; cp agave-$i/$i-api/target/*.war /usr/share/tomcat6/webapps ; done

# Copy apache ssl and proxy configs forcing HTTPS
ADD config/apache/htaccess /var/www/html/.htaccess
ADD config/apache/ssl.conf /etc/httpd/conf.d/ssl.conf
ADD config/apache/httpd.conf /etc/httpd/conf/vhost.conf
RUN cat /etc/httpd/conf/vhost.conf >> /etc/httpd/conf/httpd.conf && rm /etc/httpd/conf/vhost.conf

# Add tomcat config and settings
ADD config/tomcat/context.xml config/tomcat/server.xml /usr/share/tomcat6/conf/
ENV X509_CERT_DIR /root/.globus/certificates
ENV JAVA_OPTS -Djava.awt.headless=true -Dfile.encoding=UTF-8 -server -Xms1024m -Xmx4096m -XX:NewSize=256m -XX:MaxNewSize=256m -XX:PermSize=256m -XX:MaxPermSize=512m -XX:+DisableExplicitGC

# Configure Supervisor
RUN	mkdir -p /var/log/supervisor
ADD config/supervisord.conf /etc/supervisord.conf
ADD config/docker_entrypoint.sh /docker_entrypoint.sh

VOLUME /agave

ENTRYPOINT ["/docker_entrypoint.sh"]
EXPOSE 10389 22 443 8080 80
CMD ["/usr/bin/supervisord"]
