package chaincode

import (
	"encoding/json"
	"fmt"
	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

func (t *ChainCode) SubmitUser(ctx contractapi.TransactionContextInterface, data string) (*TransactionResponse, error) {
	var User UserDetails

	err := json.Unmarshal([]byte(data), &User)
	if err != nil {
		return t.FmtTransactionResponse(false, "BLOCKCHAIN_RUNTIME_ERROR"), err
	}

	User.ObjectType = "User"

	queryString := fmt.Sprintf("{\"selector\" : {\"$and\" : [{\"objectType\" :  \"User\" }, {\"userID\" : \"" + User.UserID + "\"}, {\"email\" : \"" + User.Email + "\"} ]} }")

	queryResults, err := t.GetQueryResultForQueryStringUser(ctx, queryString)
	if err != nil {
		return t.FmtTransactionResponse(false, "BLOCKCHAIN_RUNTIME_ERROR"), err
	}	
    if len(queryResults) != 0 {
        return t.FmtTransactionResponse(false, "USER_ALREADY_EXISTS"), nil
    }

	val, err := json.Marshal(User)
	if err != nil {
		return t.FmtTransactionResponse(false, "BLOCKCHAIN_RUNTIME_ERROR"), err
	}

	err = ctx.GetStub().PutState(User.UserID, val)
	if err != nil {
		return t.FmtTransactionResponse(false, "BLOCKCHAIN_RUNTIME_ERROR"), err
	}
	return t.FmtTransactionResponse(true, "USER_SUBMITTED"), nil
}

func (t *ChainCode) SubmitCar(ctx contractapi.TransactionContextInterface, data string) (*TransactionResponse, error) {
	var Car CarDetails

	err := json.Unmarshal([]byte(data), &Car)
	if err != nil {
		return t.FmtTransactionResponse(false, "BLOCKCHAIN_RUNTIME_ERROR"), err
	}

	Car.ObjectType = "Car"

	queryString := fmt.Sprintf("{\"selector\" : {\"$and\" : [{\"objectType\" :  \"Car\" }, {\"carID\" : \"" + Car.CarID + "\"} ]} }")

	queryResults, err := t.GetQueryResultForQueryStringCar(ctx, queryString)
	if err != nil {
		return t.FmtTransactionResponse(false, "BLOCKCHAIN_RUNTIME_ERROR"), err
	}	
    if len(queryResults) != 0 {
        return t.FmtTransactionResponse(false, "CAR_ALREADY_EXISTS"), nil
    }

	userQueryString := fmt.Sprintf("{\"selector\" : {\"$and\" : [{\"objectType\" :  \"User\" }, {\"userID\" : \"" + Car.Manufacturer.UserID + "\"}, {\"email\" : \"" + Car.Manufacturer.Email + "\"} ]} }")

	userQueryResults, err := t.GetQueryResultForQueryStringUser(ctx, userQueryString)
	if err != nil {
		return t.FmtTransactionResponse(false, "BLOCKCHAIN_RUNTIME_ERROR"), err
	}
	if len(userQueryResults) == 0 {
        return t.FmtTransactionResponse(false, "USER_NOT_AUTHORIZED"), nil
    }	
    if len(userQueryResults) != 0 {

		if( userQueryResults[0].Role == "manufacturer"){
			Car.Status = "CREATED"
			val, err := json.Marshal(Car)
			if err != nil {
				return t.FmtTransactionResponse(false, "BLOCKCHAIN_RUNTIME_ERROR"), err
			}

			err = ctx.GetStub().PutState(Car.CarID, val)
			if err != nil {
				return t.FmtTransactionResponse(false, "BLOCKCHAIN_RUNTIME_ERROR"), err
			}
			return t.FmtTransactionResponse(true, "CAR_SUBMITTED"), nil
		} else{
			return t.FmtTransactionResponse(false, "USER_NOT_AUTHORIZED"), nil
		}
    }
	return t.FmtTransactionResponse(true, "CAR_SUBMITTED"), nil
	
}

func (t *ChainCode) ReadyToDeliver(ctx contractapi.TransactionContextInterface, data string) (*TransactionResponse, error) {
	var Car CarDetails

	err := json.Unmarshal([]byte(data), &Car)
	if err != nil {
		return t.FmtTransactionResponse(false, "BLOCKCHAIN_RUNTIME_ERROR"), err
	}

	Car.ObjectType = "Car"

	queryString := fmt.Sprintf("{\"selector\" : {\"$and\" : [{\"objectType\" :  \"Car\" }, {\"carID\" : \"" + Car.CarID + "\"} ]} }")

	queryResults, err := t.GetQueryResultForQueryStringCar(ctx, queryString)
	if err != nil {
		return t.FmtTransactionResponse(false, "BLOCKCHAIN_RUNTIME_ERROR"), err
	}	
    if len(queryResults) == 0 {
        return t.FmtTransactionResponse(false, "CAR_DO_NOT_EXIST"), nil
    }

	
	userQueryString := fmt.Sprintf("{\"selector\" : {\"$and\" : [{\"objectType\" :  \"User\" }, {\"userID\" : \"" + Car.Manufacturer.UserID + "\"}, {\"email\" : \"" + Car.Manufacturer.Email + "\"} ]} }")

	userQueryResults, err := t.GetQueryResultForQueryStringUser(ctx, userQueryString)
	if err != nil {
		return t.FmtTransactionResponse(false, "BLOCKCHAIN_RUNTIME_ERROR"), err
	}
	if len(userQueryResults) == 0 {
        return t.FmtTransactionResponse(false, "USER_NOT_AUTHORIZED"), nil
    }	
    if len(userQueryResults) != 0 {
		if(queryResults[0].Manufacturer.UserID == Car.Manufacturer.UserID){
			if( userQueryResults[0].Role == "manufacturer"){
				queryResults[0].Status = "READY_FOR_SALE"
				queryResults[0].Seller = Car.Seller
				val, err := json.Marshal(queryResults[0])
				if err != nil {
					return t.FmtTransactionResponse(false, "BLOCKCHAIN_RUNTIME_ERROR"), err
				}
	
				err = ctx.GetStub().PutState(queryResults[0].CarID, val)
				if err != nil {
					return t.FmtTransactionResponse(false, "BLOCKCHAIN_RUNTIME_ERROR"), err
				}
				return t.FmtTransactionResponse(true, "CAR_SOLD"), nil
			} else{
				return t.FmtTransactionResponse(false, "USER_NOT_AUTHORIZED"), nil
			}
		} else {
			return t.FmtTransactionResponse(false, "USER_NOT_AUTHORIZED"), nil
		}
		
    }
	return t.FmtTransactionResponse(true, "CAR_SOLD"), nil
	
}

func (t *ChainCode) SellCar(ctx contractapi.TransactionContextInterface, data string) (*TransactionResponse, error) {
	var Car CarDetails

	err := json.Unmarshal([]byte(data), &Car)
	if err != nil {
		return t.FmtTransactionResponse(false, "BLOCKCHAIN_RUNTIME_ERROR"), err
	}

	Car.ObjectType = "Car"

	queryString := fmt.Sprintf("{\"selector\" : {\"$and\" : [{\"objectType\" :  \"Car\" }, {\"carID\" : \"" + Car.CarID + "\"} ]} }")

	queryResults, err := t.GetQueryResultForQueryStringCar(ctx, queryString)
	if err != nil {
		return t.FmtTransactionResponse(false, "BLOCKCHAIN_RUNTIME_ERROR"), err
	}	
    if len(queryResults) == 0 {
        return t.FmtTransactionResponse(false, "CAR_DO_NOT_EXIST"), nil
    }

	
	userQueryString := fmt.Sprintf("{\"selector\" : {\"$and\" : [{\"objectType\" :  \"User\" }, {\"userID\" : \"" + Car.Seller.UserID + "\"}, {\"email\" : \"" + Car.Seller.Email + "\"} ]} }")

	userQueryResults, err := t.GetQueryResultForQueryStringUser(ctx, userQueryString)
	if err != nil {
		return t.FmtTransactionResponse(false, "BLOCKCHAIN_RUNTIME_ERROR"), err
	}
	if len(userQueryResults) == 0 {
        return t.FmtTransactionResponse(false, "USER_NOT_AUTHORIZED"), nil
    }	
    if len(userQueryResults) != 0 {
		if(queryResults[0].Seller.UserID == Car.Seller.UserID){
			if( userQueryResults[0].Role == "seller"){
				queryResults[0].Status = "SOLD"
				queryResults[0].Seller = Car.Seller
				queryResults[0].Owner = Car.Owner
				val, err := json.Marshal(queryResults[0])
				if err != nil {
					return t.FmtTransactionResponse(false, "BLOCKCHAIN_RUNTIME_ERROR"), err
				}
	
				err = ctx.GetStub().PutState(queryResults[0].CarID, val)
				if err != nil {
					return t.FmtTransactionResponse(false, "BLOCKCHAIN_RUNTIME_ERROR"), err
				}
				return t.FmtTransactionResponse(true, "CAR_SOLD"), nil
			} else{
				return t.FmtTransactionResponse(false, "USER_NOT_AUTHORIZED"), nil
			}
		} else{
			return t.FmtTransactionResponse(false, "USER_NOT_AUTHORIZED"), nil
		}
		
    }
	return t.FmtTransactionResponse(true, "CAR_SOLD"), nil
	
}
