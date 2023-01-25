. automated_script/scripts/setConfig.sh



createChannel(){

     echo "##########################################################"
   echo "############ Create Channel ######################"
   echo "##########################################################"
   #rm -rf automated_script/*
  setGlobals ${JPPVPP[0]}
    for j in "${CHANNEL_NAME[@]}"         
    do
  peer channel create -o ${ORDERER_URL} -c ${j} \
  --ordererTLSHostnameOverride ${ORDERER_NAME} \
  -f ${PWD}/automated_script/${j}/${j}.tx --outputBlock ${PWD}/automated_script/${j}/${j}.block \
  --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA 
    done
}



joinChannel(){

  echo "##########################################################"
   echo "############ Join Channel ######################"
   echo "##########################################################"

    for j in "${JPPVPP[@]}"
    do
        setGlobals ${j}
        peer channel join -b ${PWD}/automated_script/${CHANNEL_NAME[0]}/${CHANNEL_NAME[0]}.block     
          echo "############ Join Channel ${j} ${CHANNEL_NAME[0]} ######################"
       
    done
}

updateAnchorPeers(){
  
   
    for j in "${JPPVPPCHANNEL[@]}"
    do
        setGlobals ${j}
        peer channel update -o $ORDERER_URL --ordererTLSHostnameOverride $ORDERER_NAME -c ${CHANNEL_NAME[0]} -f ${PWD}/automated_script/${CHANNEL_NAME[0]}/${CORE_PEER_LOCALMSPID}.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
        echo "==============${j} Anchor Peer Created=================="
    done
}
sleep 10
createChannel
sleep 5
joinChannel
updateAnchorPeers