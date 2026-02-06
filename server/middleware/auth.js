const jwt = require('jsonwebtoken');

module.exports = (req, res, next) => {
  // ✅ ВАЖНО ДЛЯ FLUTTER WEB
  if (req.method === 'OPTIONS') {
    return next();
  }
console.log('HEADERS:', req.headers);

  const authHeader = req.headers.authorization;

  if (!authHeader) {
    return res.status(401).json({ message: 'No token' });
  }

  const token = authHeader.split(' ')[1];

  try {
    const decoded = jwt.verify(token, 'secretKey');
    req.user = decoded;
    next();
  } catch (err) {
    res.status(401).json({ message: 'Invalid token' });
  }
};
