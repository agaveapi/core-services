#! /bin/bash 

echo "Starting up for integration testing" ; date +"%H-%M"

echo "***** Auth api"
 mvn -o -fn -Dforce.check.update=false -Dforce.check.version=false clean install -pl :auth-api

echo;echo;echo;
echo "***** Postits api"
 mvn -o -ff -Dforce.check.update=false -Dforce.check.version=false clean install -pl :postits-api

echo;echo;echo;
echo "***** Logging api"
 mvn -o -ff -Dforce.check.update=false -Dforce.check.version=false clean install -pl :logging-api

echo;echo;echo;
echo "***** Apidocs api"
  mvn -o -ff -Dforce.check.update=false -Dforce.check.version=false clean install -pl :apidocs-api

echo;echo;echo;
echo "***** Common api"
  mvn -o -ff -Dforce.check.update=false -Dforce.check.version=false clean install -pl :common-core,:auth-core,:common-api,:common-legacy-api

echo;echo;echo;
echo "***** Notifications api"
  mvn -o -ff -Dforce.check.update=false -Dforce.check.version=false clean install -pl :notifications-core,:notifications-api,:notifications-wso2-api

echo;echo;echo;
echo "***** Profiles api"
 mvn -o -ff -Dforce.check.update=false -Dforce.check.version=false clean install  -pl :profiles-core,:profiles-api

echo;echo;echo;
echo "***** Metadata api"
 mvn -o -ff -Dforce.check.update=false -Dforce.check.version=false clean install -pl :metadata-core,:metadata-api

echo;echo;echo;
echo "***** Systems api"
 mvn -o -ff -Dforce.check.update=false -Dforce.check.version=false clean install -pl :systems-core,:systems-api

echo;echo;echo;
echo "***** Files api"
 mvn -o -fn -Dforce.check.update=false -Dforce.check.version=false clean install -pl :files-core,:files-api

echo;echo;echo;
echo "***** Transforms api"
 mvn -o -fn -Dforce.check.update=false -Dforce.check.version=false clean install -pl :transforms-core,:transforms-api

echo;echo;echo;
echo "***** Apps api"
 mvn -o -fn -Dforce.check.update=false -Dforce.check.version=false clean install -pl :apps-core,:apps-api

echo;echo;echo;
echo "***** Jobs api"
  mvn -o -fn -Dforce.check.update=false -Dforce.check.version=false clean install -pl :jobs-core,:jobs-api

echo;echo;echo;
echo "***** Done ....";  date +"%H-%M"
