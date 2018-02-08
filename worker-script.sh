#!/bin/bash

echo "Installing dependencies...";

curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -;
sudo apt-get install -y nodejs;
sudo apt-get install -y git;

echo "All dependencies have been successfully installed!";

echo "fetching the client code";

git clone https://github.com/portsoc/clocoss-master-worker;
cd clocoss-master-worker;

npm install;

echo "client code has now been added";
echo "Getting server params...";

secretKey=`curl -s -H "Metadata-Flavor: Google"  \
           "http://metadata.google.internal/computeMetadata/v1/instance/attributes/secret"`;
serverip=`curl -s -H "Metadata-Flavor: Google"  \
   "http://metadata.google.internal/computeMetadata/v1/instance/attributes/serverip"`;

echo "Secret key: $secretKey";
echo "Server IP: $serverip";

echo "Starting worker...";
echo "Pless ctrl+C to terminate the service!";
npm run client $secretKey $serverip:8080;
