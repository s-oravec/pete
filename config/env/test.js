'use strict';

module.exports = {
    db: {
        superUserDbConnectString: process.env.PETE_SUPERUSER_CONN || 'PETE_SUPERUSER_CONN',
        peteUserDbConnectString:  process.env.PETE_PETEUSER_CONN || 'PETE_PETEUSER_CONN'
    },
};