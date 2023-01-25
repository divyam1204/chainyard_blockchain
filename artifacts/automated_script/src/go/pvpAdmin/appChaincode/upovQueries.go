package chaincode

import (
	"encoding/json"
	"fmt"
	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)


//Function to get an application object from the blockchain.
func (t *ChainCode) ReadCarDetails(ctx contractapi.TransactionContextInterface, carId string) (*QueryResponse, error) {

	queryString := fmt.Sprintf("{\"selector\" : {\"$and\" : [{\"objectType\" :  \"Car\" }, {\"carID\" : \"" + carId + "\"} ]} }")

	queryResults, err := t.GetQueryResultForQueryStringCar(ctx, queryString)
	if err != nil {
		return t.FmtQueryResponse(false, "BLOCKCHAIN_RUNTIME_ERROR", nil), err
	}	
    if len(queryResults) == 0 {
        return t.FmtQueryResponse(false, "CAR_DO_NOT_EXIST", nil), nil
    }
 
    val, err := json.Marshal(queryResults)
    if err != nil {
        return t.FmtQueryResponse(false, "BLOCKCHAIN_RUNTIME_ERROR", nil), err
    }
    
    return t.FmtQueryResponse(true, "CAR_FOUND", val), nil
}
