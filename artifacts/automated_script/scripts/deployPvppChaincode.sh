. automated_script/scripts/setConfig.sh

presetup() {

    echo "==============${CC_SRC_PATH[0]} Anchor Peer Created=================="
    echo Vendoring Go dependencies ...
    pushd ${CC_SRC_PATH[0]}

    echo "==============${CC_SRC_PATH[0]} Anchor Peer Created=================="
    GO111MODULE=on go mod vendor
    popd
    echo Finished vendoring Go dependencies
}

# packageChaincode

packageChaincode() {
    for i in "${!CC_NAME[@]}"
    do
        if [ ${CC_NAME[$i]} != 'dspvppchain' ]
        then
            rm -rf ${CC_NAME[$i]}.tar.gz
            setGlobals ${PEER[0]}
            peer lifecycle chaincode package ${CC_NAME[$i]}.tar.gz \
            --path ${CC_SRC_PATH[0]} --lang ${CC_RUNTIME_LANGUAGE} \
            --label ${CC_NAME[$i]}_${VERSION}
            echo "===================== Chaincode '${CC_NAME[$i]}' is packaged with path '${CC_SRC_PATH[0]}' on peer0.org1 ===================== "
        fi
    done
}

# installChaincode


installChaincodeJPPVPP() {
    for i in "${JPPVPPCHANNEL[@]}"
    do
        setGlobals ${i}
       
            peer lifecycle chaincode install ${CC_NAME[0]}.tar.gz
            echo "===================== Chaincode '$j' is installed on $i ===================== "
       
    done
}

# queryInstalled

queryInstalledJPPVPP() {
    for j in "${JPPVPPCHANNEL[@]}"
    do
        setGlobals ${j}
        peer lifecycle chaincode queryinstalled >&log.txt
        cat log.txt
        PACKAGE_ID=$(sed -n "/${CC_NAME[0]}_${VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}" log.txt)
        echo PackageID is ${PACKAGE_ID}
        echo "===================== Query installed successful on $j on channel ===================== "
    done
}



# approveForMyOrg

approveChaincodeJPPVPP() {
    for j in "${JPPVPPCHANNEL[@]}"
    do
        setGlobals ${j}
        peer lifecycle chaincode approveformyorg -o ${ORDERER_URL} \
        --ordererTLSHostnameOverride ${ORDERER_NAME} --tls $CORE_PEER_TLS_ENABLED \
        --cafile $ORDERER_CA --channelID ${CHANNEL_NAME[0]} --name ${CC_NAME[0]} \
        --version ${VERSION}  --package-id ${PACKAGE_ID} \
        --sequence ${VERSION}

        echo "===================== chaincode approved from org  $j ===================== "
       checkCommitReadynessJPPVPP
    done
     
}


# checkCommitReadyness



checkCommitReadynessJPPVPP() {


  setGlobals ${JPPVPPCHANNEL[0]}  
    peer lifecycle chaincode checkcommitreadiness --channelID ${CHANNEL_NAME[0]} \
        --peerAddresses $CORE_PEER_ADDRESS --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE \
        --name ${CC_NAME[0]} --version ${VERSION} --sequence ${VERSION} --output json 
    echo "===================== checking commit readyness from ${j} ${JPPVPPCHANNEL[1]} ===================== "

}



# commitChaincodeDefination

commitChaincodeDefinationJPPVPP() {
    setPeersForCommitJPPVPP
    setGlobals ${JPPVPPCHANNEL[0]}
  
    peer lifecycle chaincode commit -o ${ORDERER_URL} --ordererTLSHostnameOverride ${ORDERER_NAME} \
        --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
        --channelID ${CHANNEL_NAME[0]} --name ${CC_NAME[0]} \
        $peersForCommit \
        --version ${VERSION} --sequence ${VERSION} 
 
    echo "===================== chaincode definition committed succesfully ===================== "

}


# queryCommitted

queryCommitted() {
    setGlobals ${PEER[0]}
    peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name ${CC_NAME}

}

presetup

packageChaincode
installChaincodeJPPVPP
queryInstalledJPPVPP
approveChaincodeJPPVPP
commitChaincodeDefinationJPPVPP
