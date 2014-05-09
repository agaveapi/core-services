#! /bin/bash -x

echo "Starting up for integration testing" ; date +"%H-%M"

echo "***** Auth api"
 mvn -Dforce.check.update=false -Dforce.check.version=false -Dmaven.test.skip=true clean install -pl :auth-api

echo;echo;echo;
echo "***** Postits api"
 mvn -Dforce.check.update=false -Dforce.check.version=false -Dmaven.test.skip=true clean install -pl :postits-api

echo;echo;echo;
echo "***** Logging api"
 mvn -Dforce.check.update=false -Dforce.check.version=false -Dmaven.test.skip=true clean install -pl :logging-api

echo;echo;echo;
echo "***** Apidocs api"
  mvn -Dforce.check.update=false -Dforce.check.version=false -Dmaven.test.skip=true clean install -pl :apidocs-api

echo;echo;echo;
echo "***** Common api"
  mvn -Dforce.check.update=false -Dforce.check.version=false -Dmaven.test.skip=true clean install -pl :common-core,:auth-core,:common-api,:common-legacy-api

echo;echo;echo;
echo "***** Notifications api"
  mvn -Dforce.check.update=false -Dforce.check.version=false -Dmaven.test.skip=true clean install -pl :notifications-core,:notifications-api,:notifications-wso2-api

echo;echo;echo;
echo "***** Profiles api"
 mvn -Dforce.check.update=false -Dforce.check.version=false -Dmaven.test.skip=true clean install  -pl :profiles-core,:profiles-api

echo;echo;echo;
echo "***** Metadata api"
 mvn -Dforce.check.update=false -Dforce.check.version=false -Dmaven.test.skip=true clean install -pl :metadata-core,:metadata-api

echo;echo;echo;
echo "***** Systems api"
 mvn -Dforce.check.update=false -Dforce.check.version=false -Dmaven.test.skip=true clean install -pl :systems-core,:systems-api

echo;echo;echo;
echo "***** Monitors api"
 mvn -Dforce.check.update=false -Dforce.check.version=false -Dmaven.test.skip=true clean install -pl :monitors-core,:monitors-api 

echo;echo;echo;
echo "***** Files api"
 mvn -Dforce.check.update=false -Dforce.check.version=false -Dmaven.test.skip=true clean install -pl :files-core,:files-api

echo;echo;echo;
echo "***** Transforms api"
 mvn -Dforce.check.update=false -Dforce.check.version=false -Dmaven.test.skip=true clean install -pl :transforms-core,:transforms-api

echo;echo;echo;
echo "***** Apps api"
 mvn -Dforce.check.update=false -Dforce.check.version=false -Dmaven.test.skip=true clean install -pl :apps-core,:apps-api

echo;echo;echo;
echo "***** Jobs api"
  mvn -Dforce.check.update=false -Dforce.check.version=false -Dmaven.test.skip=true clean install -pl :jobs-core,:jobs-api

echo;echo;echo;
echo "***** Done ....";  date +"%H-%M"
