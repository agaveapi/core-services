#!/bin/bash

$(which git) --version
echo "user running git : $(whoami)"
echo "GIT_HOME set to $GIT_HOME"

# assumes working directory is the root directory for cloning the repository
if [ ! -d "agave-common" ]; then
    git clone https://git@bitbucket.org/taccaci/agave.git --recursive -b steve-2.1.0 .
fi

echo "On branch $(git branch)"
git checkout steve-2.1.0
git submodule foreach git checkout steve-2.1.0
git submodule foreach git pull origin steve-2.1.0
