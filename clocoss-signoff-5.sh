#!/bin/bash
N=$1;
if [ -z "$N" ]
        then
                echo "Please provide a number as a parameter."
                exit;
        fi

if ! [[ "$N" =~ ^[0-9]+$ ]]
        then
                echo "Please provide an integer!";
                exit;
        fi

secretKey=`openssl rand -base64 32`;

worker="up723294-worker";

echo "Installing dependencies...";
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash - > /dev/null 2>&1;
sudo apt-get -qq install nodejs > /dev/null 2>&1;
sudo apt-get -qq install git > /dev/null 2>&1;
echo "Dependencies installed!";

echo "Cloning master worker...";
git clone https://github.com/portsoc/clocoss-master-worker > /dev/null 2>&1;
cd clocoss-master-worker;
echo "Installing master worker...";
npm install --silent > /dev/null 2>&1;

gcloud config set compute/zone europe-west1-d;

echo "Creating $N instance(s) in the background...";

for i in `seq 1 $N`;
do
        gcloud compute instances create "$worker"-"$i" \
        --machine-type n1-standard-1 \
        --preemptible \
        --tags http-server,https-server \
        --metadata secret=$secretKey,serverip=`curl -s -H "Metadata-Flavor: Google" \
                                               "http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip"` \
        --metadata-from-file \
          startup-script=../worker-script.sh \
        --quiet > /dev/null 2>&1 &
done;

echo "Running server, please allow a few minutes!";
npm run server $secretKey;

echo "Preparing to remove server";
cd ..;
sudo rm clocoss-master-worker -r;
echo "The server has been turned off";

echo "Removing the workers";
for i in `seq 1 $N`;
do
        gcloud compute instances delete "$worker"-"$i" --quiet;
done;

echo "All workers have been terminated..!";
echo "Completed by UP723294.";
