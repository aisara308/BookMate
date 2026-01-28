const FriendsModel = require('../model/friends_model');
const UserModel = require('../model/user_model');

async function sendFriendRequest(userUid, targetUid) {
  if (userUid === targetUid) {
    throw new Error('Cannot add yourself');
  }

  await FriendsModel.findOneAndUpdate(
    { userUid },
    {
      $addToSet: {
        friends: { friendUid: targetUid, status: 'pending', isSender: false }
      }
    },
    { upsert: true }
  );

  await FriendsModel.findOneAndUpdate(
    { userUid: targetUid },
    {
      $addToSet: {
        friends: { friendUid: userUid, status: 'pending' , isSender: true}
      }
    },
    { upsert: true }
  );

  return true;
}

async function acceptFriendRequest(userUid, targetUid) {
  await FriendsModel.updateOne(
    { userUid, 'friends.friendUid': targetUid },
    { $set: { 'friends.$.status': 'accepted' } }
  );

  await FriendsModel.updateOne(
    { userUid: targetUid, 'friends.friendUid': userUid },
    { $set: { 'friends.$.status': 'accepted' } }
  );

  return true;
}

async function removeFriend(userUid, targetUid) {
  await FriendsModel.updateOne(
    { userUid },
    { $pull: { friends: { friendUid: targetUid } } }
  );

  await FriendsModel.updateOne(
    { userUid: targetUid },
    { $pull: { friends: { friendUid: userUid } } }
  );

  return true;
}

async function getFriendsList(uid) {
  const doc = await FriendsModel.findOne({ userUid: uid });
  if (!doc) return [];

  const result = [];

  for (const f of doc.friends) {
    const user = await UserModel.findOne({ uid: f.friendUid })
      .select('uid name avatar');

    if (!user) continue;

    result.push({
      uid: user.uid,
      name: user.name,
      avatar: user.avatar,
      status: f.status,
      isSender: f.isSender,
    });
  }

  return result;
}

module.exports = {
  sendFriendRequest,
  acceptFriendRequest,
  removeFriend,
  getFriendsList
};
