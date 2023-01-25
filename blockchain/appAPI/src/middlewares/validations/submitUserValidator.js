const { body } = require('express-validator');
const logger = require('../../winston');
const constants = require('../../config/constants.json');



/**
 * Checks Input Validation for contact application using express-validator
 *
 * @param  {} method
 * @returns {} express-validator response
 */
function submitUserValidation(method) {
  try {
    if (method == 'submitUser') {
      return [
        body('userID', constants.errorMessage.INVALID_INPUT_REQUEST)
          .exists()
          .isString()
          .not()
          .isEmpty(),
        body('email', constants.errorMessage.INVALID_INPUT_REQUEST)
          .exists()
          .isString()
          .not()
          .isEmpty(),
        body('role', constants.errorMessage.INVALID_INPUT_REQUEST)
          .exists()
          .isString()
          .not()
          .isEmpty(),
      ];
    }
    else {
      return [];
    }
  } catch (error) {
    logger.error(error);
  }
}
module.exports.submitUserValidation = submitUserValidation;
