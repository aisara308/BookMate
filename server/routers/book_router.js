const express = require("express");
const router = express.Router();
const controller = require("../controller/book_controller");

router.get("/", controller.getMyBooks);
router.post("/", controller.addBook);
router.post("/scan", controller.scanFolder);
router.patch("/progress", controller.updateProgress);// вместо /:id/favorite
router.patch("/favorite", controller.toggleFavorite);
router.patch("/finished", controller.toggleFinished);
router.post('/sync', controller.syncUserBooks);
router.get("/local-scan", controller.scanLocalBooks);

module.exports = router;
