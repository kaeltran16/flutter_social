import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isAuth = false;

  @override
  void initState() {
    super.initState();
    googleSignIn.onCurrentUserChanged.listen((account) {
      onGoogleSignIn(account);
    }, onError: (err) {
      print('User sign in with error $err');
    });

    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      onGoogleSignIn(account);
    }).catchError((err) {
      print('User sign in with error $err');
    });
  }

  onGoogleSignIn(GoogleSignInAccount account) {
    if (account != null) {
      print(account);
      setState(() {
        isAuth = true;
      });
    } else {
      isAuth = false;
    }
  }

  onLogout() {
    googleSignIn.signOut();
    setState(() {
      isAuth = false;
    });
  }

  Widget buildAuthScreen() {
    return RaisedButton(
      child: Text('Logout'),
      onPressed: onLogout,
    );
  }

  onLogin() {
    googleSignIn.signIn();
  }

  Widget buildUnAuthScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Theme.of(context).accentColor,
              Theme.of(context).primaryColor
            ],
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'FlutterSocial',
              style: TextStyle(
                  fontFamily: "Signatra", fontSize: 90, color: Colors.white),
            ),
            GestureDetector(
              onTap: onLogin,
              child: Container(
                width: 260,
                height: 60,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/google_signin_button.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}