const friendsService = require('../service/friends_services');

async function sendRequest(req, res) {
  try {
    const { userUid, targetUid } = req.body;
    await friendsService.sendFriendRequest(userUid, targetUid);
    res.json({ success: true });
  } catch (e) {
    res.status(400).json({ message: e.message });
  }
}

async function acceptRequest(req, res) {
  try {
    const { userUid, targetUid } = req.body;
    await friendsService.acceptFriendRequest(userUid, targetUid);
    res.json({ success: true });
  } catch (e) {
    res.status(400).json({ message: e.message });
  }
}

async function remove(req, res) {
  try {
    const { userUid, targetUid } = req.body;
    await friendsService.removeFriend(userUid, targetUid);
    res.json({ success: true });
  } catch (e) {
    res.status(400).json({ message: e.message });
  }
}

async function list(req, res) {
  try {
    const { uid } = req.params;
    const friends = await friendsService.getFriendsList(uid);
    res.json(friends);
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
}

module.exports = {
  sendRequest,
  acceptRequest,
  remove,
  list
};
