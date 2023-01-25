const applicationRoute = require('./appRoutes/applicationRoute');

function init(server) {
  server.get('*', (req, res, next) => next());
  server.use('/api/blockchain', applicationRoute);
}

module.exports = {
  init,
};
