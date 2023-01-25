const express = require('express');

const submitUserController = require('../../controller/submitUserController');
const submitCarController = require('../../controller/submitCarController');
const sellCarController = require('../../controller/sellCarController');
const getCarDetailsController = require('../../controller/getCarDetailsController');
const readyToSellController = require('../../controller/readyToSellController');

// Validators
const submitCarUserValidator = require('../../middlewares/validations/submitUserValidator');
const submitCarValidator = require('../../middlewares/validations/submitCarValidator');
const sellCarValidator = require('../../middlewares/validations/sellCarValidator');
const getCarDetailsValidator = require('../../middlewares/validations/getCarDetailsValidator');
const readyToSellValidator = require('../../middlewares/validations/readyToSellValidator');

const config = require('../../config/config.json');
const constants = require('../../config/constants.json');
const responseFormatter = require('../../middlewares/responseFormatter/apiResponse');

const router = express.Router();


/**
 *
 * Receives API call to submit user and forwards request to
 * controllers after setting the validators
 *
 * @param {} '/submit-user'
 * @param {} 'submitUserValidator.submitUserValidation('submitUser')'
 */
router.post(
  '/submit-user',
  submitCarUserValidator.submitUserValidation('submitUser'),
  async (req, res) => {
    submitUserController.submitCarUser(
      config.totalRetryAttempts,
      config.retryDelaySeconds,
      req,
      res
    );
  }
);

/**
 *
 * Receives API call to submit car and forwards request to
 * controllers after setting the validators
 *
 * @param {} '/submit-car'
 * @param {} 'submitCarValidator.submitCarValidation('submitCar')'
 */
router.post(
  '/submit-car',
  submitCarValidator.submitCarValidation('submitCar'),
  async (req, res) => {
    submitCarController.submitCar(
      config.totalRetryAttempts,
      config.retryDelaySeconds,
      req,
      res
    );
  }
);

/**
 *
 * Receives API call to sell car and forwards request to
 * controllers after setting the validators
 *
 * @param {} '/sell-car'
 * @param {} 'sellCarValidator.sellCarValidation('sellCar')'
 */
router.post(
  '/ready-to-sell',
  readyToSellValidator.readyToSellValidation('readyToSell'),
  async (req, res) => {
    readyToSellController.readyToSell(
      config.totalRetryAttempts,
      config.retryDelaySeconds,
      req,
      res
    );
  }
);

/**
 *
 * Receives API call to sell car and forwards request to
 * controllers after setting the validators
 *
 * @param {} '/sell-car'
 * @param {} 'sellCarValidator.sellCarValidation('sellCar')'
 */
router.post(
  '/sell-car',
  sellCarValidator.sellCarValidation('sellCar'),
  async (req, res) => {
    sellCarController.sellCar(
      config.totalRetryAttempts,
      config.retryDelaySeconds,
      req,
      res
    );
  }
);

/**
 *
 * Receives API call to sell car and forwards request to
 * controllers after setting the validators
 *
 * @param {} '/get-car-details'
 * @param {} 'sellCarValidator.sellCarValidation('sellCar')'
 */
router.post(
  '/get-car-details',
  getCarDetailsValidator.getCarDetailsValidation('getCarDetails'),
  async (req, res) => {
    getCarDetailsController.getCarDetails(
      config.totalRetryAttempts,
      config.retryDelaySeconds,
      req,
      res
    );
  }
);

router.use((_, res) => {
  res
    .status(responseFormatter.apiNotFoundStatus)
    .send(
      responseFormatter.apiFailureResponse(
        constants.errorMessage.INVALID_ADDRESS
      )
    );
});

module.exports = router;
