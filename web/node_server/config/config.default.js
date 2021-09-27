/* eslint valid-jsdoc: "off" */

'use strict';

const path = require('path');

/**
 * @param {Egg.EggAppInfo} appInfo app info
 */
module.exports = appInfo => {
  /**
   * built-in config
   * @type {Egg.EggAppConfig}
   **/
  const config = exports = {};

  // use for cookie sign key, should change to your own and keep security
  config.keys = appInfo.name + '_1596255292198_1848';

  config.security = {
    csrf: {
      enable: false,
    },
  };

  // add your middleware config here
  config.middleware = [];

  // add your user config here
  const userConfig = {
    // myAppName: 'egg',
  };

  config.logrotator = {
    filesRotateBySize: [
      path.join('/PPPoker/node_server/log', 'node_server-web.log'),
    ],
    maxFileSize: 10 * 1024 * 1024,
  };

  return {
    ...config,
    ...userConfig,
  };
};
