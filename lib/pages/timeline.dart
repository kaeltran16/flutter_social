import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_social/widgets/header.dart';
import 'package:flutter_social/widgets/progress.dart';

final userRef = Firestore.instance.collection('users');

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  @override
  void initState() {
    super.initState();
  }

  createUser() async {
    userRef.add({'username': 'test'});
  }

  @override
  Widget build(context) {
    return Scaffold(
        appBar: header(context, isAppTitle: true),
        body: StreamBuilder<QuerySnapshot>(
            stream: userRef.snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return circularProgress();
              }
              final List<Text> children = snapshot.data.documents
                  .map((user) => Text(user['username']))
                  .toList();
              return Container(
                child: ListView(
                  children: children,
                ),
              );
            }));
  }
}
