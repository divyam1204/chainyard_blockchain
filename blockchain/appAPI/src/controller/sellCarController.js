const { validationResult } = require('express-validator');
const logger = require('../winston');
const responseFormatter = require('../middlewares/responseFormatter/apiResponse');
const responseMessage = require('../config/apiResponse.json');
const sellCarService = require('../services/sellCarService');

/**
 * Receives API call to contact applicant for application and forwards request to service after
 * authenticating the validators
 *
 * @param  {} retryAttempts
 * @param  {} delay
 * @param  {} req
 * @param  {} res
 * @returns {} res
 */
async function sellCar(retryAttempts, delay, req, res) {
  try {
    logger.info(
      `In sell car controller function`
    );
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      logger.info(
        `Exiting sell car controller function with errorCode: ${
          errors.array()[0].msg
        }`
      );
      return res
        .status(responseFormatter.apiBadRequestStatus)
        .send(responseFormatter.validationErrorResponse(errors.array()[0].msg));
    }
    const response = await sellCarService.sellCar(
      req.body,
      req.headers
    );
    if (response.status) {
      logger.info(
        ` Exiting sell car controller function`
      );
      res
        .status(responseFormatter.apiSuccessStatus)
        .send(
          responseFormatter.apiSuccessResponse(
            response.message,
            response.payload
          )
        );
    } else {
      logger.info(
        ` Exiting sell car controller function`
      );
      res
        .status(responseFormatter.apiSuccessStatus)
        .send(responseFormatter.apiFailureResponse(response.message));
    }
  } catch (error) {
    logger.error(`${error}`);
    if (retryAttempts > 0) {
      logger.debug(`Retrying Process`);
      setTimeout(
        async () => sellCar(retryAttempts - 1, delay, req, res),
        delay * 1000
      );
    } else {
      logger.error(`Reached Maximum number of retries`);
      res
        .status(responseFormatter.apiServerErrorStatus)
        .send(
          responseFormatter.serverErrorResponse(
            responseMessage.exceptionMessage
          )
        );
    }
  }
}

module.exports.sellCar = sellCar;
