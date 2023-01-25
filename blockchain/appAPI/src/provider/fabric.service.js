/* eslint-disable consistent-return */
const { Gateway, Wallets } = require('fabric-network');
const FabricCAServices = require('fabric-ca-client');
const path = require('path');
const fss = require('file-system');
const config = require('../config/config.json');
const logger = require('../winston');
const fabriccommon = require('fabric-common');

fabriccommon.Utils.setConfigSetting('connection-timeout', 30000);
fabriccommon.Utils.setConfigSetting('request-timeout', 30000);
const connectionOptions = {
  'grpc-wait-for-ready-timeout': 100000,
  'request-timeout': 100000,
};

fabriccommon.Utils.setConfigSetting('connection-options', connectionOptions);


/**
 * Enrolls an admin user for an organisation participating in the blockchain network.
 */
async function enrollAdmin() {
  try {
    const ccpPath = path.resolve(
      __dirname,
      '..',
      '..',
      '..',
      '..',
      'artifacts',
      'organizations',
      'peerOrganizations',
      config.authority.orgName,
      config.authority.networkConfig
    );
    const ccp = JSON.parse(fss.readFileSync(ccpPath, 'utf8'));

    const caInfo = ccp.certificateAuthorities[config.authority.caName];
    const caTLSCACerts = caInfo.tlsCACerts.pem;
    const ca = new FabricCAServices(
      caInfo.url,
      { trustedRoots: caTLSCACerts, verify: false },
      caInfo.caName
    );

    const walletPath = path.join(
      process.cwd(),
      'wallet',
      config.authority.name
    );
    const wallet = await Wallets.newFileSystemWallet(walletPath);
    logger.debug(`Wallet path for ${config.authority.name}: ${walletPath}`);

    const identity = await wallet.get('admin');
    if (identity) {
      logger.error(
        'An identity for the admin user "admin" already exists in the wallet'
      );
      return;
    }

    const enrollment = await ca.enroll({
      enrollmentID: 'admin',
      enrollmentSecret: 'adminpw',
    });
    const x509Identity = {
      credentials: {
        certificate: enrollment.certificate,
        privateKey: enrollment.key.toBytes(),
      },
      mspId: config.authority.mspId,
      type: 'X.509',
    };
    await wallet.put('admin', x509Identity);
    logger.debug(
      `Exiting enroll Admin Function for org : ${config.authority.name}`
    );
    logger.debug(
      `Successfully enrolled admin user "admin" for ${config.authority.name} and imported it into the wallet`
    );
  } catch (error) {
    logger.error(
      `Failed to enroll admin user "admin" for ${config.authority.name}: ${error}`
    );
    throw new Error(error);
  }
}

/**
 * Register users for an organisation with different roles in the network.
 */
async function registerUser() {
  try {
    const ccpPath = path.resolve(
      __dirname,
      '..',
      '..',
      '..',
      '..',
      'artifacts',
      'organizations',
      'peerOrganizations',
      config.authority.orgName,
      config.authority.networkConfig
    );
    const ccp = JSON.parse(fss.readFileSync(ccpPath, 'utf8'));

    const caURL = ccp.certificateAuthorities[config.authority.caName].url;
    const ca = new FabricCAServices(caURL);

    const walletPath = path.join(
      process.cwd(),
      'wallet',
      config.authority.name
    );
    const wallet = await Wallets.newFileSystemWallet(walletPath);
    logger.debug(`Wallet path for ${config.authority.name}: ${walletPath}`);

    const userIdentity = await wallet.get(config.authority.userName);
    if (userIdentity) {
      logger.error('An identity for the user already exists in the wallet');
      return;
    }

    const adminIdentity = await wallet.get('admin');
    if (!adminIdentity) {
      logger.error(
        'An identity for the admin user "admin" does not exist in the wallet'
      );
      logger.error('Run the enrollAdmin.ts application before retrying');
      return;
    }

    const provider = wallet
      .getProviderRegistry()
      .getProvider(adminIdentity.type);
    const adminUser = await provider.getUserContext(adminIdentity, 'admin');

    const secret = await ca.register(
      {
        affiliation: config.authority.affiliation,
        enrollmentID: config.authority.userName,
        role: 'client',
      },
      adminUser
    );
    const enrollment = await ca.enroll({
      enrollmentID: config.authority.userName,
      enrollmentSecret: secret,
    });
    const x509Identity = {
      credentials: {
        certificate: enrollment.certificate,
        privateKey: enrollment.key.toBytes(),
      },
      mspId: config.authority.mspId,
      type: 'X.509',
    };
    await wallet.put(config.authority.userName, x509Identity);
    logger.debug(
      `Exiting register user Function for org : ${config.authority.name}`
    );
    logger.debug(
      `Successfully registered and enrolled ${config.authority.name} user and imported it into the wallet`
    );
  } catch (error) {
    logger.error(
      `Failed to register user for ${config.authority.name}: ${error}`
    );
    throw new Error(error);
  }
}

/**
 * Invoke functions defined in the chaincode which eventually
 * results in writing data on the blockchain
 *
 * @param  {} functionName
 * @param  {} privateData
 * @param  {} functionArgs
 * @returns {} chaincode response object
 */
async function invokeChaincode(
  functionName,
  privateData,
  functionArgs
) {
  try {
    logger.debug(
      ` In invoke chaincode Function for function : ${functionName}`
    );
    let result = {};
    let channel, chaincode;
    const ccpPath = path.resolve(
      __dirname,
      '..',
      '..',
      '..',
      '..',
      'artifacts',
      'organizations',
      'peerOrganizations',
      config.authority.orgName,
      config.authority.networkConfig
    );
    const ccp = JSON.parse(fss.readFileSync(ccpPath, 'utf8'));

    const walletPath = path.join(
      process.cwd(),
      'wallet',
      config.authority.name
    );
    const wallet = await Wallets.newFileSystemWallet(walletPath);
    logger.debug(` Wallet path: ${walletPath}`);

    const identity = await wallet.get(config.authority.userName);
    if (!identity) {
      logger.error(
        ` An identity for the user does not exist in the wallet`
      );
      logger.error(
        ` Run the registerUser.js application before retrying`
      );
      return;
    }

    const gateway = new Gateway();
    await gateway.connect(ccp, {
      wallet,
      identity: config.authority.userName,
      discovery: { enabled: true, asLocalhost: true },
      queryHandlerOptions: {
        timeout: 100,
      },
    });


      channel = config.authority.channelName;
      chaincode = config.authority.chaincodeName;

    const network = await gateway.getNetwork(channel);
    const contract = network.getContract(chaincode);
    if (privateData) {
      const transaction = contract.createTransaction(functionName);
      transaction.setEndorsingOrganizations(config.authority.mspId);
      result = await transaction.submit(...functionArgs);
    } else {
      result = await contract.submitTransaction(functionName, ...functionArgs);
    }
    logger.info(
      ` Transaction has been submitted on ${channel} channel successfully for function : ${functionName}`
    );
    await gateway.disconnect();
    logger.debug(` Exiting invoke chaincode Function`);
    return JSON.parse(result.toString());
  } catch (error) {
    logger.error(` Failed to submit transaction: ${error}`);
    throw new Error(error);
  }
}

/**
 * Query functions on the chaincode to return data already present on the blockchain.
 *
 * @param  {} functionName
 * @param  {} functionArgs
 * @returns {} chaincode response object
 */
async function queryChaincode(functionName, functionArgs) {
  try {
    let channel, chaincode;
    logger.debug(
      ` In query chaincode Function for function : ${functionName}`
    );
    const ccpPath = path.resolve(
      __dirname,
      '..',
      '..',
      '..',
      '..',
      'artifacts',
      'organizations',
      'peerOrganizations',
      config.authority.orgName,
      config.authority.networkConfig
    );
    const ccp = JSON.parse(fss.readFileSync(ccpPath, 'utf8'));

    const walletPath = path.join(
      process.cwd(),
      'wallet',
      config.authority.name
    );
    const wallet = await Wallets.newFileSystemWallet(walletPath);
    logger.debug(` Wallet path: ${walletPath}`);

    const identity = await wallet.get(config.authority.userName);
    if (!identity) {
      logger.error(
        ` An identity for the user does not exist in the wallet`
      );
      logger.error(
        ` Run the registerUser.js application before retrying`
      );
      return;
    }

    const gateway = new Gateway();
    await gateway.connect(ccp, {
      wallet,
      identity: config.authority.userName,
      discovery: { enabled: true, asLocalhost: true },
      queryHandlerOptions: {
        timeout: 100,
      },
    });

      channel = config.authority.channelName;
      chaincode = config.authority.chaincodeName;

    const network = await gateway.getNetwork(channel);

    const contract = network.getContract(chaincode);

    const result = await contract.evaluateTransaction(
      functionName,
      ...functionArgs
    );
    logger.info(
      ` Transaction has been evaluated on ${channel} successfully for function : ${functionName}.`
    );
    await gateway.disconnect();
    logger.debug(` Exiting query chaincode Function`);
    return JSON.parse(result.toString());
  } catch (error) {
    logger.error(` Failed to evaluate transaction: ${error}`);
    throw new Error(error);
  }
}

/**
 * Function to call enrollAdmin and eventListener functions.
 */
async function runEnrollRegister() {
  await enrollAdmin();
}

runEnrollRegister();

module.exports.registerUser = registerUser;

module.exports.enrollAdmin = enrollAdmin;

module.exports.invokeChaincode = invokeChaincode;

module.exports.queryChaincode = queryChaincode;

