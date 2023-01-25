const { body } = require('express-validator');
const logger = require('../../winston');
const constants = require('../../config/constants.json');



/**
 * Checks Input Validation for get Car Details using express-validator
 *
 * @param  {} method
 * @returns {} express-validator response
 */
function getCarDetailsValidation(method) {
  try {
    if (method == 'getCarDetails') {
      return [
        body('carID', constants.errorMessage.INVALID_INPUT_REQUEST)
          .exists()
          .isString()
          .not()
          .isEmpty()
      ];
    }
    else {
      return [];
    }
  } catch (error) {
    logger.error(error);
  }
}
module.exports.getCarDetailsValidation = getCarDetailsValidation;
