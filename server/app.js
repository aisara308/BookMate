const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');

const UserRouter = require('./routers/user_router');
const FriendsRouter = require('./routers/friends_router');
const BookRouter = require("./routers/book_router");

const app = express();
const path = require('path');

const { scanLocalBooks } = require("./service/book_services");

(async () => {
  try {
    const books = await scanLocalBooks();
    // console.log("Covers generated for books:", books.map(b => b.cover));
  } catch (err) {
    console.error("❌ Error generating covers:", err);
  }
})();

app.use(cors({
    origin: "*",
    methods: ["GET", "POST", "PUT", "DELETE"],
    allowedHeaders: ["Content-Type", "Authorization"]
}));

app.use(
  '/assets',
  express.static(path.join(__dirname, 'assets'))
);

app.use(bodyParser.json());

app.use('/users', UserRouter);
app.use('/friends', FriendsRouter);
app.use("/books", BookRouter);

module.exports = app;
