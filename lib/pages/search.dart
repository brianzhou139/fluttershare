import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/activity_feed.dart';
import 'package:fluttershare/pages/home.dart';
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

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {

  TextEditingController searchController=TextEditingController();
  Future<QuerySnapshot> searchResultsFuture;

  handleSearch(String query) async {
    //Future<QuerySnapshot> users_snap = usersRef.where("displayName",isGreaterThanOrEqualTo: query).get();
    Future<QuerySnapshot> users_snap = usersRef.where("displayName", isGreaterThanOrEqualTo: query).get();

    /*
    QuerySnapshot snapkit =await usersRef.where("displayName",isGreaterThanOrEqualTo: query).get();
    print("in handle__search");
    snapkit.docs.forEach((DocumentSnapshot element) {
      print(element.data());
    });*/

    setState(() {
      searchResultsFuture=users_snap;
    });

  }


  clearSearch(){
    searchController.clear();
  }

  AppBar buildSearchField(){
    return AppBar(
      backgroundColor: Colors.white,
      title: TextFormField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: "Search for a user",
          filled: true,
          prefixIcon: Icon(
              Icons.account_box,
            size: 28.0,
          ),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            onPressed: clearSearch,
          ),
        ),
        onFieldSubmitted: handleSearch,
      ),
    );

  }

  Container buildNoContent(){
    final Orientation orientation=MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            SvgPicture.asset(
              "assets/images/search.svg",
              height: orientation==Orientation.portrait ? 300.0:200.0,
            ),
            Text("Find users",textAlign: TextAlign.center,style: TextStyle(
              color: Colors.white,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
              fontSize: 60.0,
            ),),
          ],
        ),
      ),
    );
  }

  buildSearchResults(){
    return FutureBuilder(
      future: searchResultsFuture,

        builder: (context,snapst){
          if(!snapst.hasData){
            return circularProgress();
          }

          List<UserResult> searchResults=[];
          print("hulalop *************");
          snapst.data.docs.forEach((QueryDocumentSnapshot doc){
            //print(doc.data());
            User user=User.fromDocument(doc);
            //print(user.displayName);
            UserResult searcResults=UserResult(user);
            searchResults.add(searcResults);
          });

          return ListView(
            children: searchResults,
          );

        },

    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.8),
      appBar: buildSearchField(),
      body:searchResultsFuture==null ? buildNoContent() : buildSearchResults(),
    );
  }
}

class UserResult extends StatelessWidget {

  final User user;

  UserResult(this.user);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(0.7),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: ()=>showProfile(context,profileId: user.id),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage: CachedNetworkImageProvider(user.photoUrl),
              ),
              title: Text(
                user.displayName,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                  user.username,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Divider(
            height: 2.0,
            color: Colors.white54,
          ),
        ],
      ),
    );
  }

}
