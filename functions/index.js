const functions = require("firebase-functions");
const admin = require("firebase-admin");
// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });

admin.initializeApp();

exports.onCreateFollower = functions.firestore
  .document("/followers/{userId}/userFollowers/{followerId}")
  .onCreate(async (snapshot, context) => {
    console.log("Follower created ", snapshot.data);
    const userId = context.params.userId;
    const followerId = context.params.followerId;

    const followedUserPostRef = admin
      .firestore()
      .collection("posts")
      .doc(userId)
      .collection("userPosts");

    const timelinePostRef = admin
      .firestore()
      .collection("timeline")
      .doc(followerId)
      .collection("timelinePosts");

    const querySnapshot = await followedUserPostRef.get();

    querySnapshot.forEach((doc) => {
      if (doc.exists) {
        const postId = doc.id;
        const postData = doc.data();
        timelinePostRef.doc(postId).set(postData);
      }
    });
  });

exports.onDeleteFollower = functions.firestore
  .document("/followers/{userId}/userFollowers/{followerId}")
  .onDelete(async (snapshot, context) => {
    console.log("Follower deleted ", snapshot.data);
    const userId = context.params.userId;
    const followerId = context.params.followerId;

    const timelinePostRef = admin
      .firestore()
      .collection("timeline")
      .doc(followerId)
      .collection("timelinePosts")
      .where("userId", "==", userId);

    const querySnapshot = await timelinePostRef.get();

    querySnapshot.forEach((doc) => {
      if (doc.exists) {
        doc.ref.delete();
      }
    });
  });

exports.onCreatePost = functions.firestore
  .document("/posts/{userId}/userPosts/{postId}")
  .onCreate(async (snapshot, context) => {
    const post = snapshot.data();
    const { userId, postId } = context.params;

    const userFollowersRef = admin.firestore
      .collection("followers")
      .doc(userId)
      .collection("userFollowers");

    const querySnapshot = await userFollowersRef.get();

    querySnapshot.forEach((doc) => {
      const followerId = doc.id;

      admin.firestore
        .collection("timeline")
        .doc(followerId)
        .collection("timelinePosts")
        .doc(postId)
        .set(post);
    });
  });

exports.onUpdatePost = functions.firestore
  .document("/posts/{userId}/userPosts/{postId}")
  .onUpdate(async (change, context) => {
    const postUpdated = change.after.data();

    const { userId, postId } = context.params;

    const userFollowersRef = admin.firestore
      .collection("followers")
      .doc(userId)
      .collection("userFollowers");

    const querySnapshot = await userFollowersRef.get();

    querySnapshot.forEach((doc) => {
      const followerId = doc.id;

      admin.firestore
        .collection("timeline")
        .doc(followerId)
        .collection("timelinePosts")
        .doc(postId)
        .get()
        .then((doc) => {
          if (doc.exists) {
            doc.ref.update(postUpdated);
          }
        });
    });
  });

exports.onUpdatePost = functions.firestore
  .document("/posts/{userId}/userPosts/{postId}")
  .onDelete(async (snapshot, context) => {
    const { userId, postId } = context.params;

    const userFollowersRef = admin.firestore
      .collection("followers")
      .doc(userId)
      .collection("userFollowers");

    const querySnapshot = await userFollowersRef.get();

    querySnapshot.forEach((doc) => {
      const followerId = doc.id;

      admin.firestore
        .collection("timeline")
        .doc(followerId)
        .collection("timelinePosts")
        .doc(postId)
        .get()
        .then((doc) => {
          if (doc.exists) {
            doc.ref.delete();
          }
        });
    });
  });
