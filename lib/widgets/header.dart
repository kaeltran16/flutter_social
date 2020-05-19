import 'package:flutter/material.dart';

AppBar header(context,
    {bool isAppTitle = false,
    String titleText,
    bool removeBackButton = false}) {
  return AppBar(
    automaticallyImplyLeading: !removeBackButton,
    title: Text(
      isAppTitle ? 'FlutterSocial' : titleText,
      style: TextStyle(
          color: Colors.white,
          fontFamily: isAppTitle ? 'Signatra' : '',
          fontSize: isAppTitle ? 50 : 24),
    ),
    centerTitle: true,
    backgroundColor: Theme.of(context).accentColor,
  );
}
