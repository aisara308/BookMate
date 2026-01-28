const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');

const UserRouter = require('./routers/user_router');
const FriendsRouter = require('./routers/friends_router');

const app = express();

app.use(cors({
    origin: "*",
    methods: ["GET", "POST", "PUT", "DELETE"],
    allowedHeaders: ["Content-Type", "Authorization"]
}));

app.use(bodyParser.json());

app.use('/users', UserRouter);
app.use('/friends', FriendsRouter);

module.exports = app;
