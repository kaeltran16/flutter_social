import 'dart:async';

import 'package:animator/animator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_social/models/user.dart';
import 'package:flutter_social/pages/home.dart';
import 'package:flutter_social/widgets/custom_image.dart';
import 'package:flutter_social/widgets/progress.dart';

class Post extends StatefulWidget {
  final String postId;
  final String userId;
  final String username;
  final String location;
  final String desc;
  final String mediaUrl;
  final dynamic likes;

  Post({
    this.postId,
    this.userId,
    this.username,
    this.location,
    this.desc,
    this.mediaUrl,
    this.likes,
  });

  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      postId: doc['postId'],
      userId: doc['userId'],
      username: doc['username'],
      location: doc['location'],
      desc: doc['desc'],
      mediaUrl: doc['mediaUrl'],
      likes: doc['likes'],
    );
  }

  int getLikeCount(Map likes) {
    if (likes == null) return 0;
    int count = 0;

    likes.values.forEach((val) {
      if (val) {
        count += 1;
      }
    });
    return count;
  }

  @override
  State<StatefulWidget> createState() => _PostState(
        postId: this.postId,
        ownerId: this.userId,
        username: this.username,
        location: this.location,
        desc: this.desc,
        mediaUrl: this.mediaUrl,
        likes: this.likes,
        likeCount: this.getLikeCount(this.likes),
      );
}

class _PostState extends State<Post> {
  final String currentUserId = currentUser?.id;
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String desc;
  final String mediaUrl;
  Map likes;
  int likeCount;

  bool isLiked;
  bool showHeart = false;

  _PostState({
    this.postId,
    this.ownerId,
    this.username,
    this.location,
    this.desc,
    this.mediaUrl,
    this.likes,
    this.likeCount,
  });

  onLikePost() {
    bool isLike = (likes[currentUserId] == true);

    if (isLike) {
      postRef
          .document(ownerId)
          .collection('userPosts')
          .document(postId)
          .updateData({'likes.$currentUserId': false});
      setState(() {
        likeCount -= 1;
        isLiked = false;
        likes[currentUserId] = false;
      });
    } else {
      postRef
          .document(ownerId)
          .collection('userPosts')
          .document(postId)
          .updateData({'likes.$currentUserId': true});
      setState(() {
        likeCount += 1;
        isLiked = true;
        likes[currentUserId] = true;
        showHeart = true;
      });
      Timer(Duration(milliseconds: 500), () {
        setState(() {
          showHeart = false;
        });
      });
    }
  }

  FutureBuilder buildPostHeader() {
    return FutureBuilder(
      future: userRef.document(ownerId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }

        User user = User.fromDocument(snapshot.data);
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(user.photoUrl),
            backgroundColor: Colors.grey,
          ),
          title: GestureDetector(
            child: Text(
              user.username,
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            onTap: () => print('profile'),
          ),
          subtitle: Text(location),
          trailing: IconButton(
            onPressed: () => print('deleting post'),
            icon: Icon(Icons.more_vert),
          ),
        );
      },
    );
  }

  Column buildPostFooter() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 40, left: 20),
            ),
            GestureDetector(
              child: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                size: 28,
                color: Colors.pink,
              ),
              onTap: onLikePost,
            ),
            Padding(
              padding: EdgeInsets.only(right: 20),
            ),
            GestureDetector(
              child: Icon(
                Icons.chat,
                size: 28,
                color: Colors.blue[900],
              ),
              onTap: () => print('showing comment'),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Text(
                '$likeCount likes',
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Text(
                '$username ',
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Text(desc),
            )
          ],
        ),
      ],
    );
  }

  GestureDetector buildPostImage() {
    return GestureDetector(
      onDoubleTap: onLikePost,
      child: Stack(alignment: Alignment.center, children: <Widget>[
        cachedNetworkImage(mediaUrl),
        showHeart
            ? Animator(
                duration: Duration(milliseconds: 300),
                tween: Tween(begin: 0.8, end: 1.4),
                curve: Curves.elasticOut,
                cycles: 0,
                builder: (context, anim, child) => Transform.scale(
                  scale: anim.value,
                  child: Icon(Icons.favorite, size: 80, color: Colors.red),
                ),
              )
            : Text('')
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    isLiked = (likes[currentUserId] == true);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buildPostHeader(),
        buildPostImage(),
        buildPostFooter()
      ],
    );
  }
}
