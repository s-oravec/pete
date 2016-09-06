'use strict';

module.exports = {
    db: {
        superUserDbConnectString: process.env.PETE_SUPERUSER_CONN || 'PETE_SUPERUSER_CONN',
        appUserDbConnectString:  process.env.PETE_PETEUSER_CONN || 'PETE_PETEUSER_CONN'
    },
};