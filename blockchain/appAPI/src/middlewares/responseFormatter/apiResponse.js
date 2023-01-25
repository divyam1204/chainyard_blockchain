
function errorMessage(message) {
  return {
    apiResponseStatus: false,
    apiResponseData: {
      apiResponseMessage: message,
    },
  };
}

/**
 *
 * Response Formatter for validation errors, used to define responses for validation errors
 * while validating request parameters
 *
 * @param  {} message
 * @returns {} object
 */
function validationErrorResponse(message) { 
return errorMessage(message);
}

/**
 *
 * Response Formatter for API failure response, used to define responses for failed API calls
 *
 * @param  {} message
 * @returns {} object
 */
 function apiFailureResponse(message) {
  return errorMessage(message);
}

/**
 *
 * Response Formatter for API server error response, used to define responses for
 * server failures
 *
 * @param  {} message
 * @returns {} object
 */
 function serverErrorResponse(message) {
  return errorMessage(message);
}

/**
 *
 * Response Formatter for API success response, used to define responses for successful API calls
 *
 * @param  {} message
 * @param  {} payload
 * @returns {} object
 */
function apiSuccessResponse(message, payload) {
  const response = {
    apiResponseStatus: true,
    apiResponseData: payload,
  };
  response.apiResponseData.apiResponseMessage = message;
  return response;
}

module.exports.serverErrorResponse = serverErrorResponse;
module.exports.apiFailureResponse = apiFailureResponse;
module.exports.apiSuccessResponse = apiSuccessResponse;
module.exports.validationErrorResponse = validationErrorResponse;
module.exports.apiSuccessStatus = 200;
module.exports.apiServerErrorStatus = 500;
module.exports.apiBadRequestStatus = 400;
module.exports.apiUserUnauthorizedStatus = 401;
module.exports.apiNotFoundStatus = 404;