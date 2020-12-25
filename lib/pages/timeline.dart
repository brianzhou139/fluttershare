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
CollectionReference usersRef = FirebaseFirestore.instance.collection('users');
//DocumentReference userDoc=usersRef.doc("lPSxehcGLAWL9YlUutop");
class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}


class _TimelineState extends State<Timeline> {

  List<dynamic> users=[];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: header(context,isAppTitle: true,titleText: ""),
      body:Text('Timeline'),
      //body: linearProgress(),
    );
  }

}
