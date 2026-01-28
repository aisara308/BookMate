const UserService = require('../service/user_services');
const UserModel = require('../model/user_model');

exports.register = async (req, res, next) => {
  try {
    const { name, email, password } = req.body;

    if (!name || !email || !password) {
      return res.status(400).json({ message: 'All fields required' });
    }

    const exists = await UserService.checkUser(email);
    if (exists) {
      return res.status(400).json({ message: 'User already exists' });
    }

    const user = await UserService.registerUser(name, email, password);

    let tokenData = { _id: user._id, uid: user.uid, email: user.email };

    const token = await UserService.generateToken(tokenData, "secretKey", '1h');

    res.status(200).json({ status: true, token, uid: user.uid });
  } catch (error) {
    throw error;
  }
};

exports.login = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    const user = await UserService.checkUser(email);

    if (!user) {
      return res.status(500).json({ message: 'User not found' });
    }

    const isMatch = await user.comparePasswords(password);

    if (!isMatch) {
      return res.status(401).json({ message: 'Invalid password' });
    }

    let tokenData = { _id: user._id, uid: user.uid, email: user.email };

    const token = await UserService.generateToken(tokenData, "secretKey", '1h');

    res.status(200).json({ status: true, token, uid: user.uid });
  } catch (error) {
    throw error;
  }
};

exports.getUserByEmail = async (req, res) => {
  try {
    const { email } = req.params;
    const user = await UserService.getUserByEmail(email);

    if (!user) return res.status(404).json({ message: 'User not found' });

    res.json(user);
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
};

exports.updateProfile = async (req, res) => {
  try {
    const updates = {
      birthDate: req.body.birthDate,
      gender: req.body.gender,
    };

    if (req.file) {
      const avatarUrl = `/assets/photos/avatars/${req.file.filename}`;
      updates.avatar = avatarUrl;
      console.log('Avatar saved to:', req.file.path);
      console.log('Avatar URL for DB:', avatarUrl);
    }

    const user = await UserModel.findByIdAndUpdate(
      req.user._id,
      { $set: updates },
      { new: true }
    );

    res.json({ message: 'Profile updated', user });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.getUserByUid = async (req, res) => {
  try {
    const { uid } = req.params;
    const user = await UserService.findByUID(uid);

    if (!user) return res.status(404).json({ message: 'User not found' });

    res.json(user);
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
};
exports.deleteAvatar = async (req, res) => {
  try {
    await UserModel.findByIdAndUpdate(
      req.user._id,
      { $set: { avatar: '' } } 
    );

    res.json({ message: 'Avatar removed' });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
};
