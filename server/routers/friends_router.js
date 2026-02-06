const router = require('express').Router();
const controller = require('../controller/friends_controller');

router.post('/request', controller.sendRequest);
router.post('/accept', controller.acceptRequest);
router.post('/remove', controller.remove);
router.get('/:uid', controller.list);

module.exports = router;
