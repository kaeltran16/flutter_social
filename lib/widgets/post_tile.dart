import 'package:flutter/material.dart';
import 'package:flutter_social/pages/post_screen.dart';
import 'package:flutter_social/widgets/custom_image.dart';
import 'package:flutter_social/widgets/post.dart';

class PostTile extends StatelessWidget {
  final Post post;
  PostTile({this.post});
  onShowPost(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PostScreen(
                  postId: post.postId,
                  userId: post.userId,
                )));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onShowPost(context),
      child: cachedNetworkImage(post.mediaUrl),
    );
  }
}
