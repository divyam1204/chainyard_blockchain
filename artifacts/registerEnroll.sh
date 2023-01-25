
#!/bin/bash


function createJapan {

  sleep 10
   fabric-ca-client version > /dev/null 2>&1
  echo
	echo "Enroll the CA admin"
  echo
	mkdir -p organizations/peerOrganizations/japan.eapvp.com/

	export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/japan.eapvp.com/
#  rm -rf $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml
#  rm -rf $FABRIC_CA_CLIENT_HOME/msp

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname ca-japan --tls.certfiles ${PWD}/organizations/fabric-ca/japan/tls-cert.pem
  set +x

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-japan.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-japan.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-japan.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-japan.pem
    OrganizationalUnitIdentifier: orderer' > ${PWD}/organizations/peerOrganizations/japan.eapvp.com/msp/config.yaml

  echo
	echo "Register peer0"
  echo
  set -x
	fabric-ca-client register --caname ca-japan --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/japan/tls-cert.pem
  set +x

  echo
  echo "Register user"
  echo
  set -x
  fabric-ca-client register --caname ca-japan --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/japan/tls-cert.pem
  set +x

  echo
  echo "Register the org admin"
  echo
  set -x
  fabric-ca-client register --caname ca-japan --id.name japanadmin --id.secret japanadminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/japan/tls-cert.pem
  set +x

	mkdir -p organizations/peerOrganizations/japan.eapvp.com/peers
  mkdir -p organizations/peerOrganizations/japan.eapvp.com/peers/peer0.japan.eapvp.com

  echo
  echo "## Generate the peer0 msp"
  echo
  set -x
	fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-japan -M ${PWD}/organizations/peerOrganizations/japan.eapvp.com/peers/peer0.japan.eapvp.com/msp --csr.hosts peer0.japan.eapvp.com --tls.certfiles ${PWD}/organizations/fabric-ca/japan/tls-cert.pem
  set +x

  cp ${PWD}/organizations/peerOrganizations/japan.eapvp.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/japan.eapvp.com/peers/peer0.japan.eapvp.com/msp/config.yaml

  echo
  echo "## Generate the peer0-tls certificates"
  echo
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-japan -M ${PWD}/organizations/peerOrganizations/japan.eapvp.com/peers/peer0.japan.eapvp.com/tls --enrollment.profile tls --csr.hosts peer0.japan.eapvp.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/japan/tls-cert.pem
  set +x


  cp ${PWD}/organizations/peerOrganizations/japan.eapvp.com/peers/peer0.japan.eapvp.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/japan.eapvp.com/peers/peer0.japan.eapvp.com/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/japan.eapvp.com/peers/peer0.japan.eapvp.com/tls/signcerts/* ${PWD}/organizations/peerOrganizations/japan.eapvp.com/peers/peer0.japan.eapvp.com/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/japan.eapvp.com/peers/peer0.japan.eapvp.com/tls/keystore/* ${PWD}/organizations/peerOrganizations/japan.eapvp.com/peers/peer0.japan.eapvp.com/tls/server.key

  mkdir ${PWD}/organizations/peerOrganizations/japan.eapvp.com/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/japan.eapvp.com/peers/peer0.japan.eapvp.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/japan.eapvp.com/msp/tlscacerts/ca.crt

  mkdir ${PWD}/organizations/peerOrganizations/japan.eapvp.com/tlsca
  cp ${PWD}/organizations/peerOrganizations/japan.eapvp.com/peers/peer0.japan.eapvp.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/japan.eapvp.com/tlsca/tlsca.japan.eapvp.com-cert.pem

  mkdir ${PWD}/organizations/peerOrganizations/japan.eapvp.com/ca
  cp ${PWD}/organizations/peerOrganizations/japan.eapvp.com/peers/peer0.japan.eapvp.com/msp/cacerts/* ${PWD}/organizations/peerOrganizations/japan.eapvp.com/ca/ca.japan.eapvp.com-cert.pem

  mkdir -p organizations/peerOrganizations/japan.eapvp.com/users
  mkdir -p organizations/peerOrganizations/japan.eapvp.com/users/User1@japan.eapvp.com

  echo
  echo "## Generate the user msp"
  echo
  set -x
	fabric-ca-client enroll -u https://user1:user1pw@localhost:7054 --caname ca-japan -M ${PWD}/organizations/peerOrganizations/japan.eapvp.com/users/User1@japan.eapvp.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/japan/tls-cert.pem
  set +x

  mkdir -p organizations/peerOrganizations/japan.eapvp.com/users/Admin@japan.eapvp.com

  echo
  echo "## Generate the org admin msp"
  echo
  set -x
	fabric-ca-client enroll -u https://japanadmin:japanadminpw@localhost:7054 --caname ca-japan -M ${PWD}/organizations/peerOrganizations/japan.eapvp.com/users/Admin@japan.eapvp.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/japan/tls-cert.pem
  set +x

  cp ${PWD}/organizations/peerOrganizations/japan.eapvp.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/japan.eapvp.com/users/Admin@japan.eapvp.com/msp/config.yaml

}


function createPvpp {

  sleep 10
   fabric-ca-client version > /dev/null 2>&1
  echo
	echo "Enroll the CA admin"
  echo
	mkdir -p organizations/peerOrganizations/pvpp.eapvp.com/

	export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/pvpp.eapvp.com/
#  rm -rf $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml
#  rm -rf $FABRIC_CA_CLIENT_HOME/msp

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:13054 --caname ca-pvpp --tls.certfiles ${PWD}/organizations/fabric-ca/pvpp/tls-cert.pem
  set +x

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-13054-ca-pvpp.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-13054-ca-pvpp.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-13054-ca-pvpp.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-13054-ca-pvpp.pem
    OrganizationalUnitIdentifier: orderer' > ${PWD}/organizations/peerOrganizations/pvpp.eapvp.com/msp/config.yaml

  echo
	echo "Register peer0"
  echo
  set -x
	fabric-ca-client register --caname ca-pvpp --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/pvpp/tls-cert.pem
  set +x

  echo
  echo "Register user"
  echo
  set -x
  fabric-ca-client register --caname ca-pvpp --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/pvpp/tls-cert.pem
  set +x

  echo
  echo "Register the org admin"
  echo
  set -x
  fabric-ca-client register --caname ca-pvpp --id.name pvppadmin --id.secret pvppadminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/pvpp/tls-cert.pem
  set +x

	mkdir -p organizations/peerOrganizations/pvpp.eapvp.com/peers
  mkdir -p organizations/peerOrganizations/pvpp.eapvp.com/peers/peer0.pvpp.eapvp.com

  echo
  echo "## Generate the peer0 msp"
  echo
  set -x
	fabric-ca-client enroll -u https://peer0:peer0pw@localhost:13054 --caname ca-pvpp -M ${PWD}/organizations/peerOrganizations/pvpp.eapvp.com/peers/peer0.pvpp.eapvp.com/msp --csr.hosts peer0.pvpp.eapvp.com --tls.certfiles ${PWD}/organizations/fabric-ca/pvpp/tls-cert.pem
  set +x

  cp ${PWD}/organizations/peerOrganizations/pvpp.eapvp.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/pvpp.eapvp.com/peers/peer0.pvpp.eapvp.com/msp/config.yaml

  echo
  echo "## Generate the peer0-tls certificates"
  echo
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:13054 --caname ca-pvpp -M ${PWD}/organizations/peerOrganizations/pvpp.eapvp.com/peers/peer0.pvpp.eapvp.com/tls --enrollment.profile tls --csr.hosts peer0.pvpp.eapvp.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/pvpp/tls-cert.pem
  set +x


  cp ${PWD}/organizations/peerOrganizations/pvpp.eapvp.com/peers/peer0.pvpp.eapvp.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/pvpp.eapvp.com/peers/peer0.pvpp.eapvp.com/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/pvpp.eapvp.com/peers/peer0.pvpp.eapvp.com/tls/signcerts/* ${PWD}/organizations/peerOrganizations/pvpp.eapvp.com/peers/peer0.pvpp.eapvp.com/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/pvpp.eapvp.com/peers/peer0.pvpp.eapvp.com/tls/keystore/* ${PWD}/organizations/peerOrganizations/pvpp.eapvp.com/peers/peer0.pvpp.eapvp.com/tls/server.key

  mkdir ${PWD}/organizations/peerOrganizations/pvpp.eapvp.com/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/pvpp.eapvp.com/peers/peer0.pvpp.eapvp.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/pvpp.eapvp.com/msp/tlscacerts/ca.crt

  mkdir ${PWD}/organizations/peerOrganizations/pvpp.eapvp.com/tlsca
  cp ${PWD}/organizations/peerOrganizations/pvpp.eapvp.com/peers/peer0.pvpp.eapvp.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/pvpp.eapvp.com/tlsca/tlsca.pvpp.eapvp.com-cert.pem

  mkdir ${PWD}/organizations/peerOrganizations/pvpp.eapvp.com/ca
  cp ${PWD}/organizations/peerOrganizations/pvpp.eapvp.com/peers/peer0.pvpp.eapvp.com/msp/cacerts/* ${PWD}/organizations/peerOrganizations/pvpp.eapvp.com/ca/ca.pvpp.eapvp.com-cert.pem

  mkdir -p organizations/peerOrganizations/pvpp.eapvp.com/users
  mkdir -p organizations/peerOrganizations/pvpp.eapvp.com/users/User1@pvpp.eapvp.com

  echo
  echo "## Generate the user msp"
  echo
  set -x
	fabric-ca-client enroll -u https://user1:user1pw@localhost:13054 --caname ca-pvpp -M ${PWD}/organizations/peerOrganizations/pvpp.eapvp.com/users/User1@pvpp.eapvp.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/pvpp/tls-cert.pem
  set +x

  mkdir -p organizations/peerOrganizations/pvpp.eapvp.com/users/Admin@pvpp.eapvp.com

  echo
  echo "## Generate the org admin msp"
  echo
  set -x
	fabric-ca-client enroll -u https://pvppadmin:pvppadminpw@localhost:13054 --caname ca-pvpp -M ${PWD}/organizations/peerOrganizations/pvpp.eapvp.com/users/Admin@pvpp.eapvp.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/pvpp/tls-cert.pem
  set +x

  cp ${PWD}/organizations/peerOrganizations/pvpp.eapvp.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/pvpp.eapvp.com/users/Admin@pvpp.eapvp.com/msp/config.yaml

}


function createOrderer {

  echo
	echo "Enroll the CA admin"
  echo
	mkdir -p organizations/ordererOrganizations/eapvp.com

	export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrganizations/eapvp.com
#  rm -rf $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml
#  rm -rf $FABRIC_CA_CLIENT_HOME/msp

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:9054 --caname ca-orderer --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  set +x

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: orderer' > ${PWD}/organizations/ordererOrganizations/eapvp.com/msp/config.yaml


  echo
	echo "Register orderer"
  echo
  set -x
	fabric-ca-client register --caname ca-orderer --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
    set +x

  echo
  echo "Register the orderer admin"
  echo
  set -x
  fabric-ca-client register --caname ca-orderer --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  set +x

	mkdir -p organizations/ordererOrganizations/eapvp.com/orderers
  mkdir -p organizations/ordererOrganizations/eapvp.com/orderers/eapvp.com

  mkdir -p organizations/ordererOrganizations/eapvp.com/orderers/orderer.eapvp.com

  echo
  echo "## Generate the orderer msp"
  echo
  set -x
	fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/eapvp.com/orderers/orderer.eapvp.com/msp --csr.hosts orderer.eapvp.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  set +x

  cp ${PWD}/organizations/ordererOrganizations/eapvp.com/msp/config.yaml ${PWD}/organizations/ordererOrganizations/eapvp.com/orderers/orderer.eapvp.com/msp/config.yaml

  echo
  echo "## Generate the orderer-tls certificates"
  echo
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/eapvp.com/orderers/orderer.eapvp.com/tls --enrollment.profile tls --csr.hosts orderer.eapvp.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  set +x

  cp ${PWD}/organizations/ordererOrganizations/eapvp.com/orderers/orderer.eapvp.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/eapvp.com/orderers/orderer.eapvp.com/tls/ca.crt
  cp ${PWD}/organizations/ordererOrganizations/eapvp.com/orderers/orderer.eapvp.com/tls/signcerts/* ${PWD}/organizations/ordererOrganizations/eapvp.com/orderers/orderer.eapvp.com/tls/server.crt
  cp ${PWD}/organizations/ordererOrganizations/eapvp.com/orderers/orderer.eapvp.com/tls/keystore/* ${PWD}/organizations/ordererOrganizations/eapvp.com/orderers/orderer.eapvp.com/tls/server.key

  mkdir ${PWD}/organizations/ordererOrganizations/eapvp.com/orderers/orderer.eapvp.com/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/eapvp.com/orderers/orderer.eapvp.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/eapvp.com/orderers/orderer.eapvp.com/msp/tlscacerts/tlsca.eapvp.com-cert.pem

  mkdir ${PWD}/organizations/ordererOrganizations/eapvp.com/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/eapvp.com/orderers/orderer.eapvp.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/eapvp.com/msp/tlscacerts/tlsca.eapvp.com-cert.pem

  mkdir -p organizations/ordererOrganizations/eapvp.com/users
  mkdir -p organizations/ordererOrganizations/eapvp.com/users/Admin@eapvp.com

  echo
  echo "## Generate the admin msp"
  echo
  set -x
	fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:9054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/eapvp.com/users/Admin@eapvp.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  set +x

  cp ${PWD}/organizations/ordererOrganizations/eapvp.com/msp/config.yaml ${PWD}/organizations/ordererOrganizations/eapvp.com/users/Admin@eapvp.com/msp/config.yaml


}

function generateCCP {
organizations/ccp-generate.sh

}

    echo "##########################################################"
    echo "############ Create Japan Identities ######################"
    echo "##########################################################"

    createJapan


    echo "##########################################################"
    echo "############ Create Pvpp Identities ######################"
    echo "##########################################################"

     createPvpp

    echo "##########################################################"
    echo "############ Create Orderer Org Identities ###############"
    echo "##########################################################"

    createOrderer


    echo "##########################################################"
    echo "############ generateCCP###############"
    echo "##########################################################"
    
    generateCCP