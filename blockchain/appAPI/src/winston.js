const appRoot = require('app-root-path');
const winston = require('winston');
const config = require('./config/config.json');
require('winston-daily-rotate-file');

const { format } = winston;
const { combine, timestamp, label, printf } = format;
const myFormat = printf((info) => {
  if (info.stack) {
    return `[${info.label}] [${info.timestamp}]  ${info.level}: ${info.message}: ${info.stack}`;
  }
  return `[${info.label}] [${info.timestamp}]  ${info.level}: ${info.message}`;
});

const myModulePath = appRoot.resolve(config.logConfig.logPath);

const transport = new winston.transports.DailyRotateFile({
  filename: myModulePath,
  level: config.logConfig.logLevel,
  datePattern: config.logConfig.datePattern,
  zippedArchive: config.logConfig.zippedArchive,
  maxFiles: config.logConfig.maxFiles,
  createSymlink: true,
  symlinkName: 'app.log',
});

const logger = winston.createLogger({
  format: combine(
    label({ label: config.logConfig.label }),
    timestamp(),
    myFormat
  ),
  transports: [transport],
  exitOnError: false,
});

logger.stream = {
  write: () => {/**/},
};

module.exports = logger;
