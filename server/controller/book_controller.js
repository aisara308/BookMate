const bookService = require("../service/book_services");
const Book = require("../model/book_model");
exports.addBook = async (req, res) => {
  try {
    const { filePath } = req.body;
    const userUid = req.user.uid;

    const book = await bookService.addBookForUser(userUid, filePath);
    res.json(book);
  } catch (e) {
    res.status(400).json({ message: e.message });
  }
};

exports.getMyBooks = async (req, res) => {
  try {
    // uid передаём через query-параметр или body
    const uid = req.query.uid || req.body.uid;
    if (!uid) return res.status(400).json({ message: "UID required" });

    const books = await bookService.getUserBooks(uid);
    res.json(books);
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
};


exports.updateProgress = async (req, res) => {
  try {
    const { uid, filePath, progress, lastCfi } = req.body;

    if (!uid || !filePath || progress === undefined) {
      return res.status(400).json({
        message: "uid, filePath and progress are required",
      });
    }

    const book = await Book.findOne({
      userUid: uid,
      filePath,
    });

    if (!book) {
      return res.status(404).json({ message: "Book not found" });
    }

    // защита от мусора
    const safeProgress = Math.min(Math.max(Number(progress), 0), 100);

    book.progress = safeProgress;
    book.lastCfi = lastCfi ?? book.lastCfi;
    book.isFinished = safeProgress === 100;

    await book.save();

    res.json({
      message: "Progress updated",
      book,
    });
  } catch (err) {
    console.error("🔥 updateProgress error:", err);
    res.status(500).json({ message: err.message });
  }
};

exports.toggleFavorite = async (req, res) => {
  try {
    const uid = req.body.uid;
    const title = req.body.title;

    if (!uid || !title) return res.status(400).json({ message: 'UID and title required' });

    const book = await Book.findOne({ userUid: uid, title: title });
    if (!book) return res.status(404).json({ message: 'Book not found' });

    book.isFavorite = !book.isFavorite;
    await book.save();

    res.json(book);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.toggleFinished = async (req, res) => {
  try {
    const uid = req.body.uid;
    const title = req.body.title;

    if (!uid || !title) return res.status(400).json({ message: 'UID and title required' });

    const book = await Book.findOne({ userUid: uid, title: title });
    if (!book) return res.status(404).json({ message: 'Book not found' });

    book.isFinished = !book.isFinished;
    await book.save();

    res.json(book);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.scanFolder = async (req, res) => {
  const books = await bookService.scanBooksFolder(req.user.uid);
  res.json(books);
};

exports.syncUserBooks = async (req, res) => {
  try {
    const { uid } = req.body;
    if (!uid) return res.status(400).json({ message: 'UID required' });
console.log('req.body:', req.body);

    const result = await bookService.syncUserBooks(uid);
    res.json({ message: 'Sync finished', syncedBooks: result });
  } catch (error) {
    console.error('🔥 Sync error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

exports.scanLocalBooks = async (req, res) => {
  try {
    const books = await bookService.scanLocalBooks();
    res.json(books);
  } catch (error) {
    console.error("🔥 Local scan error:", error);
    res.status(500).json({ message: "Internal server error" });
  }
};
