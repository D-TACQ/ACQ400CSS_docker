#!/usr/bin/env bash

IMAGE="cs-studio"
UUT=$1

#Erase all existing images
#sudo docker rmi -f $(sudo docker images -aq)

#Build image if no existing image
sudo docker image inspect "$IMAGE" &> /dev/null
if [ $? -eq 1 ]; then
    sudo docker build \
    --build-arg USER_NAME=$(id --user --name) \
    --build-arg USER_ID=$(id --user) \
    --build-arg GROUP_NAME=$(id --group --name) \
    --build-arg GROUP_ID=$(id --group) \
    --tag $IMAGE \
    .
fi

#Get ip from hostname
IP=$2
if [ -z "$2" ]; then
    IP=$(ping -q -c 1 -t 1 $UUT 2>/dev/null | grep PING | sed -e "s/).*//" | sed -e "s/.*(//")
fi

echo "UUT=${UUT} IP=${IP}"

#Run Image
sudo docker run -it \
    --rm \
    -h $(hostname) \
    --network host \
    --env="DISPLAY=unix$DISPLAY" \
    --volume="/tmp/.X11-unix:/tmp/.X11-unix" \
    --volume="./workspaces:$HOME/workspaces" \
    $IMAGE \
    /bin/bash -c "./scripts/workspace_init.sh ${UUT} ${IP} && cs-studio > /dev/null 2>&1"