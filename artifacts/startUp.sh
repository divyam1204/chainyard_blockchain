
export PATH=/home/dmalik/test/eapvp/artifacts/automated_script/bin:$PATH
export GOROOT=/usr/local/go
export GOPATH=$HOME/work
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
export PATH=$GOPATH/bin:$PATH

sudo chmod -R 777 ./organizations

docker rm -f $(docker ps -a -q)
yes | docker volume prune

docker images | grep "dev-peer" | awk '{print $1 ":" $2}' | xargs docker rmi

docker ps -a 

rm -rf organizations/ordererOrganizations
rm -rf organizations/peerOrganizations
rm -rf organizations/fabric-ca/japan/msp organizations/fabric-ca/japan/tls-cert.pem organizations/fabric-ca/japan/ca-cert.pem organizations/fabric-ca/japan/IssuerPublicKey organizations/fabric-ca/japan/IssuerRevocationPublicKey organizations/fabric-ca/japan/fabric-ca-server.db

rm -rf organizations/fabric-ca/pvpp/msp organizations/fabric-ca/pvpp/tls-cert.pem organizations/fabric-ca/pvpp/ca-cert.pem organizations/fabric-ca/pvpp/IssuerPublicKey organizations/fabric-ca/pvpp/IssuerRevocationPublicKey organizations/fabric-ca/pvpp/fabric-ca-server.db


rm -rf organizations/fabric-ca/ordererOrg/msp organizations/fabric-ca/ordererOrg/tls-cert.pem organizations/fabric-ca/ordererOrg/ca-cert.pem organizations/fabric-ca/ordererOrg/IssuerPublicKey organizations/fabric-ca/ordererOrg/IssuerRevocationPublicKey organizations/fabric-ca/ordererOrg/fabric-ca-server.db
rm -rf automated_script/JpPvppchannel

docker-compose -f ./docker/docker-compose-ca.yaml up -d

./registerEnroll.sh
./automated_script/create-artifacts.sh

docker-compose -f ./docker/docker-compose-test-net.yaml up -d



docker ps -a

./automated_script/scripts/createChannel.sh
./automated_script/scripts/deployPvppChaincode.sh