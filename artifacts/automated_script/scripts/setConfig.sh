export CORE_PEER_TLS_ENABLED=true
export ORDERER_ORG=$(jq -r '.ordererOrg' automated_script/scripts/config.json)
export ORDERER_NAME=$(jq -r '.ordererName' automated_script/scripts/config.json)
export ORDERER_URL=$(jq -r '.ordererUrl' automated_script/scripts/config.json)
export ORDERER_ARTIFACTS_PATH=${PWD}/$(jq -r '.ordererArtifactsPath' automated_script/scripts/config.json)
export ORDERER_CA=$ORDERER_ARTIFACTS_PATH/$ORDERER_ORG/orderers/$ORDERER_NAME/msp/tlscacerts/tlsca.$ORDERER_ORG-cert.pem

export FABRIC_CFG_PATH=${PWD}/automated_script

export ARTIFACTS_DIRECTORY=$(jq -r '.artifactsDirectory' automated_script/scripts/config.json)

export PEER_ARTIFACTS_PATH=${PWD}/$(jq -r '.peerArtifactsPath' automated_script/scripts/config.json)

export CHANNEL_NAME=($(jq -r '.name | .[]'  automated_script/scripts/config.json))

export JPPVPP=($(jq -r '.JpPvppChannelPeers | .[]' automated_script/scripts/config.json))

export PEER=($(jq -r '.peers | .[]' automated_script/scripts/config.json))



export JPPVPPCHANNEL=($(jq -r '.jppvppchannel | .[]' automated_script/scripts/config.json))

CC_RUNTIME_LANGUAGE="golang"
VERSION=$(jq -r .version automated_script/scripts/config.json)

export CC_SRC_PATH=($(jq -r '.chaincodePath | .[]' automated_script/scripts/config.json))
export CC_NAME=($(jq -r '.chaincodeName | .[]' automated_script/scripts/config.json))

setGlobals(){
    export orgName=${1:6}
    echo "############ setGlobals  ${orgName} ######################"
    export peer=$(echo $1 | cut -d'.' -f 1)
    for k in $(jq '.orgs | keys | .[]' automated_script/scripts/config.json); do
        name=$(jq -r ".orgs[$k].name" automated_script/scripts/config.json);
        if [ "$name" == "$orgName" ]; then
            export CORE_PEER_LOCALMSPID=$(jq -r ".orgs[$k].mspId" automated_script/scripts/config.json)
            export CORE_PEER_TLS_ROOTCERT_FILE=$PEER_ARTIFACTS_PATH/$orgName/peers/$peer.$orgName/tls/ca.crt
            export CORE_PEER_MSPCONFIGPATH=$PEER_ARTIFACTS_PATH/$orgName/users/Admin@$orgName/msp
            export CORE_PEER_ADDRESS=$(jq -r ".orgs[$k].corePeerAddress" automated_script/scripts/config.json)
        fi
    done
}

setPeersForCommitJPPVPP(){
    export peersForCommit=""
    for j in "${JPPVPPCHANNEL[@]}"
    do
        setGlobals ${j}
        peersForCommit="$peersForCommit --peerAddresses $CORE_PEER_ADDRESS --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE "
    done
}
