
#chmod -R 0755 ${FABRIC_CFG_PATH}/crypto-config
# Delete existing artifacts
#rm -rf ${FABRIC_CFG_PATH}/crypto-config
#rm ${PWD}/automated_script/genesis.block ${PWD}/automated_script/channel.tx
#rm -rf .${FABRIC_CFG_PATH}/.${FABRIC_CFG_PATH}/channel-artifacts/*
export FABRIC_CFG_PATH=${PWD}/automated_script
export PATH=$HOME/eapvp/artifacts/artifacts/automated_script/bin:$PATH
#Generate Crypto artifactes for organizations
#cryptogen generate --config=${FABRIC_CFG_PATH}/crypto-config.yaml --output=${FABRIC_CFG_PATH}/crypto-config/



# System channel
SYS_CHANNEL="sys-channel"


   echo "##########################################################"
   echo "############ Create Japan Pvpp Channel ######################"
   echo "##########################################################"

# channel name defaults to "mychannel"


CHANNEL_NAME="jppvppchannel"

echo $CHANNEL_NAME

# Generate System Genesis block
configtxgen -profile UpovOrdererGenesis  -channelID $SYS_CHANNEL  -outputBlock ${FABRIC_CFG_PATH}/UpovGenesis.block


# Generate channel configuration block
configtxgen -profile   JpPvppChannel -outputCreateChannelTx ${FABRIC_CFG_PATH}/${CHANNEL_NAME}/${CHANNEL_NAME}.tx -channelID $CHANNEL_NAME


echo "#######    Generating anchor peer update for Org1MSP  ##########"
configtxgen -profile JpPvppChannel  -outputAnchorPeersUpdate ${FABRIC_CFG_PATH}/${CHANNEL_NAME}/JapanMSP.tx -channelID $CHANNEL_NAME -asOrg JapanMSP

echo "#######    Generating anchor peer update for Org2MSP  ##########"
configtxgen -profile JpPvppChannel  -outputAnchorPeersUpdate ${FABRIC_CFG_PATH}/${CHANNEL_NAME}/PvppMSP.tx -channelID $CHANNEL_NAME -asOrg PvppMSP

