#!/bin/sh
# This Script aims to setup a docker environment for OSX (Maybe Linux) with docker client, docker-machine and docker-compose
# All binaries are installed in /usr/local/bin/ directory.

DOCKER_VERSION="1.8.3"
DOCKER_MACHINE_VERSION="0.5.0-rc2"
#DOCKER_COMPOSE_VERSION="1.5.0rc1"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

os=$(uname -s)
arch=$(uname -m)

# Install Docker client
docker_bin_url="https://test.docker.com/builds/$os/$arch/docker-$DOCKER_VERSION"
echo "${GREEN}>> Download docker client binary ($DOCKER_VERSION)${NC}"
echo $docker_bin_url
curl --progress-bar -o /usr/local/bin/docker $docker_bin_url
chmod +x /usr/local/bin/docker


# Install Docker machine
docker_machine_bin_url="https://github.com/docker/machine/releases/download/v$DOCKER_MACHINE_VERSION/docker-machine_$(echo $os| tr '[:upper:]' '[:lower:]')-amd64.zip"
echo "\n${GREEN}>> Download Docker machine ($DOCKER_MACHINE_VERSION)${NC}"
echo $docker_machine_bin_url
curl -L $docker_machine_bin_url > machine.zip && \
  unzip machine.zip && \
  rm machine.zip && \
  mv docker-machine* /usr/local/bin


# Install Docker Compose
docker_compose_bin_url="https://dl.bintray.com/docker-compose/master/docker-compose-$os-$arch"
echo "\n${GREEN}>> Download Docker compose (Master)${NC}"
echo $docker_compose_bin_url
curl --progress-bar -L $docker_compose_bin_url > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose


read -e -p "Do you want to create a new machine? (y/n) : " create_docker_machine
if [ $create_docker_machine = "y" ];then
  # Create a Docker machine on virtualbox
  echo "\n${GREEN}>> Create a dev machine on virtualbox${NC}"
  docker-machine create --driver virtualbox dev
  eval "$(docker-machine env dev)"

  # Find a better way to retrieve the curent ip
  ip=$(ifconfig | grep en2 -A1 | grep "inet " | awk '{print $2}')


  grep -q DOCKER-LOCAL-BEGIN /etc/exports
  if [ $? -eq 1 ]; then

    echo "\n${GREEN}>> Config NFS server on your local machine${NC}"
    nfsexports=$(cat <<EOF
# DOCKER-LOCAL-BEGIN
/Users {{IP}} -alldirs -mapall=0:80
# DOCKER-LOCAL-END
EOF)
    nfsexports=$(echo "$nfsexports" | sed -e "s/{{IP}}/$ip/g")
    echo "$nfsexports" | sudo tee -a /etc/exports
    sudo nfsd restart
  fi

  echo "\n${GREEN}>> Config NFS client on the dev machine${NC}"
  bootsync=$(cat <<EOF
#!/bin/sh
sudo umount /Users
sudo /usr/local/etc/init.d/nfs-client start
sleep 1
sudo mount.nfs {{IP}}:/Users /Users -v -o rw,async,noatime,rsize=32768,wsize=32768,proto=udp,udp,nfsvers=3
EOF)

  bootsync=$(echo "$bootsync" | sed -e "s/{{IP}}/$ip/g")

  docker-machine ssh dev "echo \"$bootsync\" > /tmp/bootsync.sh"
  docker-machine ssh dev "sudo mv /tmp/bootsync.sh /var/lib/boot2docker/bootsync.sh"
  docker-machine restart dev
  eval "$(docker-machine env dev)"
fi

echo "\n\n${GREEN}Done! You should see infos about docker below :${NC}"
docker info
