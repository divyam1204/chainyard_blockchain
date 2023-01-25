const { body } = require('express-validator');
const logger = require('../../winston');
const constants = require('../../config/constants.json');



/**
 * Checks Input Validation for contact application using express-validator
 *
 * @param  {} method
 * @returns {} express-validator response
 */
function submitCarValidation(method) {
  try {
    if (method == 'submitCar') {
      return [
        body('carID', constants.errorMessage.INVALID_INPUT_REQUEST)
          .exists()
          .isString()
          .not()
          .isEmpty(),
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
module.exports.submitCarValidation = submitCarValidation;
