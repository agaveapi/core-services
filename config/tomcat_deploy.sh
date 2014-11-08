#!/bin/bash

mvn -Dskip.docker.build=true -Dskip.integration.tests=true -Dmaven.test.skip=true -Dforce.check.update=false -Dforce.check.version=false clean install
find . -name "*.war"

# deploy swagger docs to apach web root
mkdir -p /var/www/html/v2
chmod -R 755 /var/www/html/v2

if [[ ! -e /agave/agave-apidocs/apidocs-api/target/classes ]]; then
	cd /agave/agave-apidocs/
	mvn -Dskip.docker.build=true -Dskip.integration.tests=true -Dmaven.test.skip=true -Dforce.check.update=false -Dforce.check.version=false clean install
	cd /agave
fi

ln -s /agave/agave-apidocs/apidocs-api/target/classes /var/www/html/v2/docs
chmod -R 755 /var/www/html/v2/docs

# deploy php apps to apache web root
for i in auth postits logging; do

	if [[ ! -e /agave/agave-$i/$i-api/target/classes ]]; then
		cd /agave/agave-$i/
		mvn -Dskip.docker.build=true -Dskip.integration.tests=true -Dmaven.test.skip=true -Dforce.check.update=false -Dforce.check.version=false clean install
		cd /agave
	fi

	rm -rf /var/www/html/v2/$i
	ln -s /agave/agave-$i/$i-api/target/classes /var/www/html/v2/$i
	chmod -R 755 /var/www/html/v2/$i
done

# deploy java webapps to tomcat
for i in apps jobs files metadata monitors notifications profiles systems transforms; do

	if [[ ! -e /agave/agave-$i/$i-api/target/*.war ]]; then
		cd /agave/agave-$i/
		mvn -Dskip.docker.build=true -Dskip.integration.tests=true -Dmaven.test.skip=true -Dforce.check.update=false -Dforce.check.version=false clean install
		cd /agave
	fi

	rm -rf /usr/share/tomcat6/webapps/$i* /usr/share/tomcat6/webapps/work/Catalina/localhost/$i
	cp agave-$i/$i-api/target/*.war /usr/share/tomcat6/webapps/;
done
