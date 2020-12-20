import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/pages/activity_feed.dart';
import 'package:fluttershare/pages/profile.dart';
import 'package:fluttershare/pages/search.dart';
import 'package:fluttershare/pages/timeline.dart';
import 'package:fluttershare/pages/upload.dart';
import 'package:google_sign_in/google_sign_in.dart';


/***************************************************************************************************/
/* MainActivity of the App                                                                         */
/*bool isAuth is true when user is logged on or logs on                                            */
/*ternary operater dispays GoogleSignIn Option is isAuth==false                                    */
/*googleSignIn.onCurrentUserChanged  Detects when user signs in and changes state of isAuth        */
/*googleSignIn.signInSilently checks already signed in session/ signs in use silently              */
/*                                                                                                 */
/*                                                                                                 */
/*                                                                                                 */
/*                                                                                                 */
/*                                                                                                 */
/***************************************************************************************************/


final GoogleSignIn googleSignIn=GoogleSignIn();
//final GoogleSignIn

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isAuth=false;
  PageController pageController;
  int pageIndex=0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //initialising page controller
    pageController=PageController();

    //Detects when user signs in .....
    googleSignIn.onCurrentUserChanged.listen((account) {
      //handle SignIn
      handleSignIn(account);
    },onError: (err){
      print('Error signing in : ${err}'); //display error to the console yeah ....
    });

    //ReAuthenticate User when App is re_opened yeah...
    googleSignIn.signInSilently(suppressErrors: false)
    .then((account){
      handleSignIn(account);
    }).catchError((err){
      print("err signing in : ${err}");
    });

  }//end of initState

  @override
  void dispose() {
    // TODO: implement dispose
    pageController.dispose();
    super.dispose();
  }

  handleSignIn(GoogleSignInAccount account){
    if(account!=null){
      print("User Signed In YEah");
      print("account data ${account}");
      setState(() {
        isAuth=true;
      });
    }else{
      setState(() {
        isAuth=false;
      });
    }
  }


  login(){
    googleSignIn.signIn();
  }

  logout(){
    googleSignIn..signOut();
  }

  onPageChangedHere(int pageIndex){
    setState(() {
      this.pageIndex=pageIndex;
    });
  }

  onTapHere(int pageIndex){
    pageController.jumpToPage(
      pageIndex,
    );
  }
  /*
  Widget buildAuthScreen(){
    return RaisedButton(
      child: Text('Logout'),
        onPressed: logout,
    );
  }*/

  //If isAuth is true, the following function is fired

  Scaffold buildAuthScreen(){
    return Scaffold(
      body: PageView(
        children: <Widget>[
          Timeline(),
          ActivityFeed(),
          Upload(),
          Search(),
          Profile(),
        ],
        controller: pageController,
        onPageChanged: onPageChangedHere,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex,
        onTap: onTapHere,
        activeColor: Theme.of(context).primaryColor,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.whatshot)),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_active)),
          BottomNavigationBarItem(icon: Icon(Icons.photo_camera,size: 35.0,)),
          BottomNavigationBarItem(icon: Icon(Icons.search)),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle)),
        ],
      ),
    );
  }

  //If isAuth is false, the following function is fired
  Scaffold buildUnAuthScreen(){
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Theme.of(context).accentColor,
              Theme.of(context).primaryColor,
            ],
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
                'FlutterShare',
              style: TextStyle(
                fontFamily: 'Signatra',
                fontSize: 90.0,
                color: Colors.white

              ),
            ),
            GestureDetector(
              onTap: (){
                login();
              },
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
            ),
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
