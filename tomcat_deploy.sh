#!/bin/bash

# cd $HOME/agave
# 
# git pull
# 
# git submodule update
# 
 mvn -Dskip.integration.tests=true -Dmaven.test.skip=true -Dforce.check.update=false -Dforce.check.version=false -s config/maven/settings.xml clean install
#mvn -Dskip.integration.tests=true -Dmaven.test.skip=true -Dforce.check.update=false -Dforce.check.version=false clean install

# deploy swagger docs to apach web root
mkdir /var/www/html/v2
chmod -R 755 /var/www/html/v2

rm -rf /var/www/html/v2/docs
ln -s /home/iplant/agave/agave-apidocs/apidocs-api/target/classes /var/www/html/v2/docs
chmod -R 755 /var/www/html/v2/docs

# deploy php apps to apache web root
for i in auth postits logging; do
	rm -rf /var/www/html/v2/$i
	ln -s /home/iplant/agave/agave-$i/$i-api/target/classes /var/www/html/v2/$i
	chmod -R 755 /var/www/html/v2/$i
done

# deploy java webapps to tomcat
for i in apps jobs files metadata monitors notifications profiles systems transforms; do
	rm -rf $CATALINA_HOME/webapps/$i* $CATALINA_HOME/webapps/work/Catalina/localhost/$i
	cp agave-$i/$i-api/target/*.war $CATALINA_HOME/webapps/;
done

# bounce tomcat
$CATALINA_HOME/bin/kill.sh
# $CATALINA_HOME/bin/startup.sh

#service tomcat restart

tail -f $CATALINA_HOME/logs/catalina.out
