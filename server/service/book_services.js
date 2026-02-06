const Book = require("../model/book_model");
const path = require("path");
const EPub = require("epub");
const fs = require("fs");
const User = require("../model/user_model"); 

const PROJECT_ROOT = path.resolve(__dirname, '../');
const COVER_DIR = path.join(PROJECT_ROOT, "assets", "covers");
if (!fs.existsSync(COVER_DIR)) fs.mkdirSync(COVER_DIR, { recursive: true });

async function syncUserBooks(uid) {
  console.log('---');
  console.log('🔄 Sync for user:', uid);

  const user = await User.findOne({ uid });
  if (!user) throw new Error('User not found');

  const syncedBooks = [];

  for (const bookPath of user.books) {
    const cleanPath = bookPath.startsWith('/') ? bookPath.slice(1) : bookPath;
    const absolutePath = path.join(PROJECT_ROOT, cleanPath);

    if (!fs.existsSync(absolutePath)) {
      console.log('❌ File not found:', absolutePath);
      continue;
    }

    let book = await Book.findOne({ userUid: uid, filePath: bookPath });
    if (!book) {
      try {
        const meta = await parseEpubMetadata(absolutePath);

        book = await Book.create({
          userUid: uid,
          filePath: bookPath,
          ...meta
        });

        console.log('✅ Book created with metadata:', book.title, '-', book.author);
      } catch (e) {
        console.log('⚠️ Failed to parse EPUB, fallback to file name:', bookPath);
        const title = path.parse(bookPath).name;
        book = await Book.create({
          userUid: uid,
          filePath: bookPath,
          title
        });
      }
    } else {
      console.log('📘 Book already exists:', book.title);
    }

    syncedBooks.push(book);
  }

  console.log('🎉 Sync finished for', uid);
  return syncedBooks;
}

/**
 * Парсит метаданные EPUB и сохраняет обложку
 */
function parseEpubMetadata(filePath) {
  return new Promise((resolve, reject) => {
    const epub = new EPub(filePath);

    epub.on("end", async () => {
      let coverPath = null;

      if (epub.metadata.cover) {
        try {
          const coverId = epub.metadata.cover;
          // Делаем getImage в промис, чтобы дождаться записи файла
          coverPath = await new Promise((res) => {
            epub.getImage(coverId, (err, data, mimeType) => {
              if (!err && data) {
                const ext = mimeType.split("/")[1] || "jpg";
                const fileName = path.basename(filePath, ".epub") + "." + ext;
                const absoluteCoverPath = path.join(COVER_DIR, fileName);
                fs.writeFileSync(absoluteCoverPath, data);
                res(`/assets/covers/${fileName}`);
              } else {
                res(null);
              }
            });
          });
        } catch (err) {
          console.warn("⚠️ Failed to extract cover for", filePath);
        }
      }

      resolve({
        title: epub.metadata.title || path.basename(filePath, ".epub"),
        author: epub.metadata.creator || "Unknown",
        description: epub.metadata.description || "",
        language: epub.metadata.language || "",
        genres: epub.metadata.subject
          ? Array.isArray(epub.metadata.subject)
            ? epub.metadata.subject
            : [epub.metadata.subject]
          : [],
        cover: coverPath
      });
    });

    epub.on("error", reject);
    epub.parse();
  });
}

async function addBookForUser(userUid, filePath) {
  const absolutePath = path.join(PROJECT_ROOT, filePath);

  if (!fs.existsSync(absolutePath)) {
    throw new Error("EPUB file not found");
  }

  const meta = await parseEpubMetadata(absolutePath);

  const exists = await Book.findOne({ userUid, filePath });
  if (exists) return exists;

  return Book.create({
    userUid,
    filePath,
    ...meta
  });
}

async function getUserBooks(userUid) {
  return Book.find({ userUid }).sort({ createdAt: -1 });
}

async function scanBooksFolder(userUid) {
  const booksDir = path.join(PROJECT_ROOT, "assets", "books");
  const files = fs.readdirSync(booksDir).filter(f => f.endsWith(".epub"));

  const added = [];

  for (const file of files) {
    const filePath = `/assets/books/${file}`;
    const book = await addBookForUser(userUid, filePath);
    added.push(book);
  }

  return added;
}

/**
 * Локальное сканирование всех EPUB без базы, возвращает метаданные
 */
async function scanLocalBooks() {
  const booksDir = path.join(PROJECT_ROOT, "assets", "books");

  if (!fs.existsSync(booksDir)) return [];

  const files = fs.readdirSync(booksDir).filter(f => f.endsWith(".epub"));
  const books = [];

  for (const file of files) {
    const filePath = path.join(booksDir, file);
    try {
      const meta = await parseEpubMetadata(filePath);
      books.push({
        filePath: `/assets/books/${file}`,
        ...meta
      });
    } catch (e) {
      console.warn(`⚠️ Failed to parse EPUB: ${file}`, e.message);
    }
  }

  return books;
}

module.exports = {
  syncUserBooks,
  addBookForUser,
  getUserBooks,
  scanBooksFolder,
  scanLocalBooks
};
