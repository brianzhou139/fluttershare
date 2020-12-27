import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/pages/home.dart';

void main() {

  //FirebaseFirestore.instance.settings(timestampsInSnapshotsEnabled: true).then((_){print("timestamps enabled");});
  //FirebaseFirestore.instance.settings.sslEnabled.then((_){print("timestamps enabled");});
  //FirebaseFirestore.instance.settings =Settings(sslEnabled: );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterShare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // primarySwatch: Colors.deepPurple,
        primaryColor: Colors.deepPurple,
        accentColor: Colors.teal,
      ),
      home: Home(),
    );
  }

}//end of MyApp
