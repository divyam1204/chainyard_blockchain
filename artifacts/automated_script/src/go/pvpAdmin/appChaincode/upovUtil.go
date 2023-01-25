package chaincode

import (
	"encoding/json"
	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)


//Function to structure and return the response for Invoke functions.
func (t *ChainCode) FmtTransactionResponse(status bool, message string) *TransactionResponse {
	response := new(TransactionResponse)
	response.Status = status;
	response.Message = message
	return response;
}

//Function to structure and return the response for Query functions.
func (t *ChainCode) FmtQueryResponse(status bool, message string, payload []byte) *QueryResponse {
	response := new(QueryResponse)
	response.Status = status;
	response.Message = message;
	response.Payload = string(payload);
	return response;
}



//Function to get a list of application from the blockchain based on the query string provided.
func (t *ChainCode) GetQueryResultForQueryStringUser(ctx contractapi.TransactionContextInterface, queryString string) ([]UserDetails, error) {
	var User UserDetails 
	resultsIterator, err := ctx.GetStub().GetQueryResult(queryString)
	if err != nil {
		return nil, err
	}
	defer resultsIterator.Close()

	results := []UserDetails{}

	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()
		if err != nil {
			return nil, err
		}
		err = json.Unmarshal(queryResponse.Value, &User)
		if err != nil {
			return nil, err
		}
		results = append(results, User)

	}
	return results, nil
}


//Function to get a list of application from the blockchain based on the query string provided.
func (t *ChainCode) GetQueryResultForQueryStringCar(ctx contractapi.TransactionContextInterface, queryString string) ([]CarDetails, error) {
	var Car CarDetails 
	resultsIterator, err := ctx.GetStub().GetQueryResult(queryString)
	if err != nil {
		return nil, err
	}
	defer resultsIterator.Close()

	results := []CarDetails{}

	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()
		if err != nil {
			return nil, err
		}
		err = json.Unmarshal(queryResponse.Value, &Car)
		if err != nil {
			return nil, err
		}
		results = append(results, Car)

	}
	return results, nil
}
