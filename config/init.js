'use strict';

/**
 * Module dependencies.
 */
var glob = require('glob'),
	chalk = require('chalk');

/**
 * Module init function.
 */
module.exports = function() {
    if (!process.env.PETE_ENV) {
        console.error(chalk.red('PETE_ENV is not defined! Using default development environment'));
	    process.env.PETE_ENV =  'development';
 	} else {
	    console.log(chalk.black.bgWhite('Loading using the "' + process.env.PETE_ENV + '" environment configuration'));
	}
};
