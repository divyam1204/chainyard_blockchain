package main

import (
	"log"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
	"github.com/upov/appChaincode"
)

//Main function where the smart contract is initialized.
func main() {
	upovChaincode, err := contractapi.NewChaincode(&chaincode.ChainCode{})
	if err != nil {
		log.Panicf("Error creating UPOV_Chaincode: %v", err)
	}

	if err := upovChaincode.Start(); err != nil {
		log.Panicf("Error starting UPOV_Chaincode: %v", err)
	}
}