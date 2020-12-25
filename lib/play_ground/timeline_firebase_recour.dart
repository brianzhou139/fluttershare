import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/progress.dart';

/**************************************************************************************************************/
/*                                                                                                            */
/*                                                                                                            */
/*                                                                                                            */
/*                                                                                                            */
/*                                                                                                            */
/*                                                                                                            */
/*                                                                                                            */
/*                                                                                                            */
/*                                                                                                            */
/*                                                                                                            */
/*                                                                                                            */
/*                                                                                                            */
/*                                                                                                            */
/*                                                                                                            */
/**************************************************************************************************************/
//To access the default app, call the initializeApp or app method on the Firebase class:
FirebaseApp defaultApp;

//final usersRef = Firestore.instance.collection('users');
// Access Firestore using the default Firebase app:
//FirebaseFirestore usersRef = FirebaseFirestore.instance;
CollectionReference usersRef = FirebaseFirestore.instance.collection('users');
DocumentReference userDoc=usersRef.doc("lPSxehcGLAWL9YlUutop");

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}


class _TimelineState extends State<Timeline> {

  List<dynamic> users=[];

  @override
  void initState() {
    // TODO: implement initState
    //getUsers();
    //getUserById();
    //getUsers2();
    //createUser();
    //updateUser();
    deleteUser();
    super.initState();
  }

  deleteUser(){
    usersRef.doc("XX8p5gBbSWdkeGM0vTMm").delete();
  }

  updateUser(){
    usersRef.doc("brianzhouhbb").update({
      "username":"Prototype_and_test",
      "isAdmin":false,
      "email":"zet@gmail.com"
    }).catchError((err){
      print("error brian : ${err}");
    });
  }
  createUser()async{
    usersRef.doc("brianzhou").set({
      "username":"zetter",
      "isAdmin":false,
      "email":"zet@gmail.com"
    });
  }
  getUsers2() async {
    defaultApp = await Firebase.initializeApp();
    //initializing firebase shit

    defaultApp = await Firebase.initializeApp();

    final QuerySnapshot snap=await usersRef.get();

    setState(() {
      users=snap.docs;
    });

    snap.docs.forEach((DocumentSnapshot doc) {
      print("<< jerk , ${doc.data()}");
      print("id : ${doc.id}");
      print("exits : ${doc.exists}");
    });


    usersRef
        .snapshots()
        .listen((QuerySnapshot snapshot) {

      print("<<<<  here with data");
      setState(() {
        users=snapshot.docs;
      });
      snapshot.docs.forEach((DocumentSnapshot doc) {
        print("<< ici , ${doc.data()}");
        print("id : ${doc.id}");
        print("exits : ${doc.exists}");
      });
    });
  }
  getUserById()async{
    //initializing firebase shit
    defaultApp = await Firebase.initializeApp();

    userDoc.snapshots()
        .listen((DocumentSnapshot doc) {
      print("User found here yeah yeah");
      print("see ${doc.data()}");
      print("id : ${doc.id}");
      print("exists : ${doc.exists}");
    });

  }
  getUsers() async {
    //initializing firebase shit
    defaultApp = await Firebase.initializeApp();

    usersRef
        .snapshots()
        .listen((QuerySnapshot snapshot) {

      print("<<<<  here with data");

      snapshot.docs.forEach((DocumentSnapshot doc) {
        print("<< ici , ${doc.data()}");
        print("id : ${doc.id}");
        print("exits : ${doc.exists}");
      });

    });
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: header(context,isAppTitle: true,titleText: ""),
      body: StreamBuilder<QuerySnapshot>(
        stream: usersRef.snapshots(),
        builder: (context,snapshot){

          if(!snapshot.hasData){
            return circularProgress();
          }

          final List<Text> children=snapshot.data.docs.map((doc) => Text(doc['username'])).toList();

          return Container(
            child: ListView(
              children: children,
            ),
          );

        },
      ),
      //body: linearProgress(),
    );
  }

}
