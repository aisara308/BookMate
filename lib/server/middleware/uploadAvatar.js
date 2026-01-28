const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Абсолютный путь к папке для аватаров в корне проекта
const avatarsDir = path.join(process.cwd(), 'assets', 'photos', 'avatars');

// Создаем папку, если её нет
if (!fs.existsSync(avatarsDir)) {
  fs.mkdirSync(avatarsDir, { recursive: true });
  console.log('Created avatars directory at:', avatarsDir);
}

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, avatarsDir);
  },
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname); // сохраняем расширение
    cb(null, `${req.user.uid}${ext}`);
  }
});

module.exports = multer({ storage });
