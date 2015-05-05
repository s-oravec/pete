'use strict';

/**
 * Module dependencies.
 */
var _ = require('lodash');

/**
 * Load configurations
 */
module.exports = _.extend(
	require('./env/all'),
	require('./env/' + process.env.PETE_ENV) || {}
);


