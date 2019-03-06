#!/bin/bash

echoStatement() {
  echo ""
  echo -e "${1} ========== ${2} =========== \033[0m"
}

source .env

installNode() {
  echoStatement "\033[0;35m" "Setting up node environment"
  curl -sL https://deb.nodesource.com/setup_10.x -o nodesource_setup.sh
  sudo bash nodesource_setup.sh 
  sudo apt-get install -y nodejs
}

setUpProjectFiles() {
  echoStatement "\033[0;35m" "Setting up project files"
  if [[ -d balder-ah-frontend ]]; then
    sudo rm -r balder-ah-frontend
    sudo rm -rf node_modules
    sudo rm -rf package-lock.json
    git clone https://github.com/andela/balder-ah-frontend.git
  else
    git clone https://github.com/andela/balder-ah-frontend.git
  fi
}

installDependencies() {
  echoStatement "\033[0;35m" "Installing project dependencies"
  cd balder-ah-frontend
  sudo npm install node-pre-gyp -ES --unsafe-perm=true
  sudo npm i -ES --unsafe-perm=true
}

buildWebpack() {
  echoStatement "\033[0;35m" "Building Webpack"
  sudo npm run build
}

configServer="
  server  {
    listen 80;
    location / {
      proxy_pass http://127.0.0.1:3000;
    }
  }
"

configureNGINX() {
  echoStatement "\033[0;35m" "Configuring NGINX reverse proxy server"
  sudo apt-get install nginx -y
  sudo rm -r /etc/nginx/sites-enabled/default
  sudo echo ${configServer} > /etc/nginx/sites-available/balder-ah
  sudo ln -s /etc/nginx/sites-available/balder-ah /etc/nginx/sites-enabled/balder-ah
  sudo service nginx restart
}

startScript='
  {
    "apps": [
      {
        "name": "authors-haven",
        "script": "npm",
        "args": "run start:dev"
      }
    ]
  }
'

keepAppAlive() {
  echoStatement "\033[0;35m" "Install PM2 to run app in background"
  sudo npm install pm2 -g
  sudo echo ${startScript} > ./startScript.config.json
  pm2 start startScript.config.json
}

triggerAll() {
  installNode
  setUpProjectFiles
  installDependencies
  buildWebpack
  configureNGINX
  keepAppAlive
}

triggerAll
