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

async function getCarDetails(req, headers) {
    try {
        logger.debug(
            `Executing get Car Details service`
        );
        let result = {};

        result = await fabricService.queryChaincode(
            'ReadCarDetails',
            [req.carID]
        );
        if (result.status) {
            result.payload = JSON.parse(result.payload);
            result.message = constants.successMessage.CAR_DETAILS_RETRIEVED;
            logger.info(
                `Exiting get Car Details service function`
            );

        }
        if (
            result.message === constants.errorMessage.BLOCKCHAIN_RUNTIME_ERROR
        ) {
            logger.info(
                `Exiting get Car Details service function with errorCode: ${result.message}`
            );
            result.message = constants.errorMessage.BLOCKCHAIN_RUNTIME_ERROR;
        }
        return result;
    } catch (error) {
        logger.error(`${error}`);
        throw new Error(error);
    }
}
module.exports.getCarDetails = getCarDetails;