const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const logger = require('./winston');
const winston = require('./winston');
const config = require('./config/config.js');
const configuration = require('./config/config.json');
const routes = require('./routes');
require('dotenv').config();


const app = express();
app.options('*', cors());
app.use(cors());
app.use(helmet());
app.use(express.json({ limit: configuration.requestLimit }));
app.use(morgan('combined', { stream: winston.stream }));
app.use(express.urlencoded({ extended: false }));


routes.init(app);

const server = app.listen(config.PORT, () => {
  logger.info('****************** SERVER STARTED ************************');
  logger.debug(`Server listening at http://${config.HOST}:${config.PORT}`);
});
server.timeout = configuration.serverTimeout;
module.exports.app = app;
