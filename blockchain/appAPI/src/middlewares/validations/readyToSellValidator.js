const { body } = require('express-validator');
const logger = require('../../winston');
const constants = require('../../config/constants.json');



/**
 * Checks Input Validation for contact application using express-validator
 *
 * @param  {} method
 * @returns {} express-validator response
 */
function readyToSellValidation(method) {
  try {
    if (method == 'readyToSell') {
      return [
        body('carID', constants.errorMessage.INVALID_INPUT_REQUEST)
          .exists()
          .isString()
          .not()
          .isEmpty(),
        body('seller', constants.errorMessage.INVALID_INPUT_REQUEST)
          .exists(),
        body('manufacturer', constants.errorMessage.INVALID_INPUT_REQUEST)
          .exists()
      ];
    }
    else {
      return [];
    }
  } catch (error) {
    logger.error(error);
  }
}
module.exports.readyToSellValidation = readyToSellValidation;
