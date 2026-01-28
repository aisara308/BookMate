const router = require('express').Router();
const UserController = require('../controller/user_controller');
const auth = require('../middleware/auth');
const uploadAvatar = require('../middleware/uploadAvatar');

router.post('/registration', UserController.register);
router.post('/login', UserController.login);
router.get('/email/:email', UserController.getUserByEmail);
router.get('/uid/:uid', UserController.getUserByUid);
router.post(
  '/update',
  auth,
  uploadAvatar.single('avatar'),
  UserController.updateProfile
);
router.delete(
  '/avatar',
  auth,
  UserController.deleteAvatar
);
module.exports = router;
