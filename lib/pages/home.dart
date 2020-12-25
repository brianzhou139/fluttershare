import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/activity_feed.dart';
import 'package:fluttershare/pages/profile.dart';
import 'package:fluttershare/pages/search.dart';
import 'package:fluttershare/pages/timeline.dart';
import 'package:fluttershare/pages/upload.dart';
import 'package:google_sign_in/google_sign_in.dart';

//firebase storage
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import 'create_account.dart';


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
User currentUser;
FirebaseApp defaultApp;
//FirebaseFirestore usersRef = FirebaseFirestore.instance;
CollectionReference usersRef = FirebaseFirestore.instance.collection('users');
CollectionReference postsRef = FirebaseFirestore.instance.collection('posts');
final GoogleSignIn googleSignIn=GoogleSignIn();
final DateTime timestamp=DateTime.now();
//final GoogleSignIn
//Firebase Storage refs yeh
firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance;
firebase_storage.Reference storageRef = firebase_storage.FirebaseStorage.instance.ref();

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
    test();
    //initialising page controller
    pageController=PageController();

    //Detects when user signs in .....
    googleSignIn.onCurrentUserChanged.listen((account) {
      //handle SignIn
      handleSignIn(account);
      createUserInFireStore();
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

  test() async {
    defaultApp = await Firebase.initializeApp();
  }

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
      //createUserInFireStore();
      setState(() {
        isAuth=true;
      });
    }else{
      setState(() {
        isAuth=false;
      });
    }
  }

  createUserInFireStore() async {
    //check if use exists in users collection
    //if use doesn;t exists ..take them to account page...
    final GoogleSignInAccount user=googleSignIn.currentUser;
    DocumentSnapshot doc=await usersRef.doc(user.id).get();

    //check if  doc exists
    if(!doc.exists){

      print("**********************************  createUserInfireStoreFired Now");
      final username = await Navigator.push(context, MaterialPageRoute(builder: (context)=>CreateAccount()));

      print("I recevived the data from create_account");
      print("FF ${username}");

      //get username and create account yeah
      usersRef.doc(user.id).set({
        "id":user.id,
        "username":username,
        "photoUrl":user.photoUrl,
        "email":user.email,
        "displayName":user.displayName,
        "bio":"",
        "timestamp":timestamp
      });

      doc=await usersRef.doc(user.id).get();

    }

    currentUser=User.fromDocument(doc);
    print("current User : ${currentUser.email}");

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
    pageController.animateToPage(
      pageIndex,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget buildAuthScreen2(){
    return RaisedButton(
      child: Text('Logout'),
        onPressed: logout,
    );
  }

  //If isAuth is true, the following function is fired

  Scaffold buildAuthScreen(){
    return Scaffold(
      body: PageView(
        children: <Widget>[
          Timeline(),
          ActivityFeed(),
          Upload(currentUser: currentUser,),
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
