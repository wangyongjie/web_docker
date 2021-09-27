'use strict';

/**
 * @param {Egg.Application} app - egg application
 */
module.exports = app => {
  const { router, controller } = app;
  router.get('/update/:project', controller.home.index);
  router.post('/update/:project', controller.home.index);
  router.get('/getlog/:tag', controller.home.getLog);
};
