import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_social/pages/activity_feed.dart';
import 'package:flutter_social/pages/profile.dart';
import 'package:flutter_social/pages/search.dart';
import 'package:flutter_social/pages/timeline.dart';
import 'package:flutter_social/pages/upload.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isAuth = false;
  PageController pageController;
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
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
    return Scaffold(
      body: PageView(
        children: <Widget>[
          Timeline(),
          ActivityFeed(),
          Upload(),
          Search(),
          Profile()
        ],
        controller: pageController,
        onPageChanged: onPageChange,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: 0,
        onTap: onTap,
        activeColor: Theme.of(context).primaryColor,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.whatshot)),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_active)),
          BottomNavigationBarItem(
              icon: Icon(
            Icons.photo_camera,
            size: 35,
          )),
          BottomNavigationBarItem(icon: Icon(Icons.search)),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle)),
        ],
      ),
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

  onPageChange(int index) {
    setState(() {
      pageIndex = index;
    });
  }

  onTap(int index) {
    pageController.animateToPage(index,
        duration: Duration(milliseconds: 200), curve: Curves.bounceInOut);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}
