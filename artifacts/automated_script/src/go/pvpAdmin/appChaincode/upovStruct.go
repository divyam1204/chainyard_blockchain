package chaincode

import (
	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

type ChainCode struct {
	contractapi.Contract
}


//====================================================================================================
type UserDetails struct{
	ObjectType					string				`json:"objectType,omitempty"`
	UserID 						string 				`json:"userID"`
	Email						string				`json:"email"`
	Role						string				`json:"role,omitempty"`
}

type CarDetails struct{
	ObjectType					string				`json:"objectType"`
	CarID 						string 				`json:"carID"`
	Status						string				`json:"status"`
	Manufacturer				UserDetails			`json:"manufacturer"`
	Seller						UserDetails			`json:"seller"`
	Owner						UserDetails			`json:"owner"`
}
//====================================================================================================

//Response structure for Invoke functions.
type TransactionResponse struct {
	Status bool   `json:"status"`
	Message string `json:"message"`
}

//Response structure for Query functions.
type QueryResponse struct {
	Status bool   `json:"status"`
	Message string `json:"message"`
	Payload string `json:"payload"`
}


