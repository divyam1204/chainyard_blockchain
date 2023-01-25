const fabricService = require('../provider/fabric.service');
const config = require('../config/config.json');
const constants = require('../config/constants.json');
const logger = require('../winston');

/**
 * function to submit user in ledger.
 *
 * @param  {} req
 * @param  {} headers
 * @returns {} submitUser result object
 */

async function submitCar(req, headers) {
    try {
        logger.debug(
            `Executing submit user service`
        );
        let result = {};

        result = await fabricService.invokeChaincode(
            'SubmitCar',
            !config.operations.privateData,
            [JSON.stringify(req), (!config.operations.privateData).toString()]
        );
        if (result.status) {
            result.payload = {};
            result.message = constants.successMessage.CAR_SUBMITTED;
            logger.info(
                `Exiting submit user service function`
            );

        }
        if (
            result.message === constants.errorMessage.BLOCKCHAIN_RUNTIME_ERROR
        ) {
            logger.info(
                `Exiting submit user service function with errorCode: ${result.message}`
            );
            result.message = constants.errorMessage.BLOCKCHAIN_RUNTIME_ERROR;
        }
        return result;
    } catch (error) {
        logger.error(`${error}`);
        throw new Error(error);
    }
}
module.exports.submitCar = submitCar;