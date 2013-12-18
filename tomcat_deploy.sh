#!/bin/bash   

cd $HOME/agave

#git pull

#git submodule update

#mvn -DskipTests clean deploy

# deploy swagger docs to apach web root
mkdir /var/www/html/v2
chmod -R 755 /var/www/html/v2

rm -rf /var/www/html/v2/docs
ln -s /home/iplant/agave/agave-apidocs/apidocs-api/target/classes /var/www/html/v2/docs
chmod -R 755 /var/www/html/v2/docs

# deploy php apps to apache web root
for i in auth postits; do
	rm -rf /var/www/html/v2/$i
	ln -s /home/iplant/agave/agave-$i/$i-api/target/classes /var/www/html/v2/$i
	chmod -R 755 /var/www/html/v2/$i
done

# deploy java webapps to tomcat
for i in apps jobs files metadata notifications profiles systems transforms; do 
	cp agave-$i/$i-api/target/*.war $CATALINA_HOME/webapps/; 
done

# bounce tomcat
#service tomcat restart

cd $CATALINA_HOME

#bin/kill.sh

#bin/startup.sh

tail -n 500 -f $CATALINA_HOME/logs/catalina.out 
