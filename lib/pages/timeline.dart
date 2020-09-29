import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_social/models/user.dart';
import 'package:flutter_social/pages/home.dart';
import 'package:flutter_social/pages/search.dart';
import 'package:flutter_social/widgets/header.dart';
import 'package:flutter_social/widgets/post.dart';
import 'package:flutter_social/widgets/progress.dart';

final userRef = Firestore.instance.collection('users');

class Timeline extends StatefulWidget {
  final User currentUser;
  Timeline({this.currentUser});
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  List<Post> posts;
  List<String> followings = [];

  @override
  void initState() {
    super.initState();
    getTimeline();
    getFollowing();
  }

  getTimeline() async {
    QuerySnapshot snapshot = await timelineRef
        .document(widget.currentUser?.id)
        .collection('timelinePosts')
        .orderBy('timestamp', descending: true)
        .getDocuments();

    List<Post> posts =
        snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
    setState(() {
      this.posts = posts;
    });
  }

  getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .document(currentUser?.id)
        .collection('userFollowing')
        .getDocuments();
    setState(() {
      followings = snapshot.documents.map((e) => e.documentID).toList();
    });
  }

  buildUsersToFollow() {
    return StreamBuilder(
        stream: userRef
            .orderBy('timeStamp', descending: true)
            .limit(30)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          List<UserResult> userResults = [];
          print(snapshot.data.documents.length);
          snapshot.data.documents.forEach((doc) {
            User user = User.fromDocument(doc);
            print('User $user');
            if (currentUser.id == user.id) {
              return;
            } else if (followings.contains(user.id)) {
              return;
            } else {
              UserResult result = UserResult(user);
              userResults.add(result);
            }
          });
          print(userResults);
          return Container(
            color: Theme.of(context).accentColor.withOpacity(.2),
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.person_add,
                        color: Theme.of(context).primaryColor,
                        size: 30,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        'Users to follow',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 30,
                        ),
                      )
                    ],
                  ),
                ),
                Column(
                  children: userResults,
                )
              ],
            ),
          );
        });
  }

  buildTimeLine() {
    if (posts == null) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return buildUsersToFollow();
    } else {
      return ListView(
        children: posts,
      );
    }
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: header(context, isAppTitle: true),
      body: RefreshIndicator(
        onRefresh: () => getTimeline(),
        child: buildTimeLine(),
      ),
    );
  }
}
