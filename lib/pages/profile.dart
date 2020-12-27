import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/post.dart';
import 'package:fluttershare/widgets/post_tile.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'edit_profile.dart';


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


class Profile extends StatefulWidget {

  final String profileId;

  Profile({this.profileId});
  @override
  _ProfileState createState() => _ProfileState();

}

class _ProfileState extends State<Profile> {
  bool isLoading=false;
  int postCount=0;
  List<Post> posts=[];
  String postOrientation="grid";
  final String currentUserId=currentUser?.id;
  bool isFollowing=false;
  int followerCount=0;
  int followingCount=0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getProfilePosts();
    getFollowers();
    getFollowing();
    checkIfFollowing();
  }


  getFollowers()async{
    QuerySnapshot snapshot=await followersRef.doc(widget.profileId).collection("userFollowers").get();

    setState(() {
      followerCount=snapshot.docs.length;
    });

  }//end of getFollowers


  getFollowing()async{
    QuerySnapshot snapshot=await followingRef.doc(widget.profileId).collection("userFollowing").get();

    setState(() {
      followingCount=snapshot.docs.length;
    });
  }//end getFollowing

  checkIfFollowing()async{

    DocumentSnapshot doc=await followersRef.doc(widget.profileId).collection("userFollowers").doc(currentUserId).get();
    setState(() {
      isFollowing=doc.exists;
    });

  }//check if following


  Column buildCountColumn(String label,int count){
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.bold
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 4.0),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }


  editProfile(){
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditProfile(currentUserId: currentUser.id)));
  }

  Container buildButton({String text,Function function}){
    return Container(
      child: FlatButton(
        onPressed: function,
        child: Container(
          width: 200.0,
          height: 26.0,
          child: Container(
            child: Text(
              text,
              style: TextStyle(
                color: isFollowing ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isFollowing ? Colors.white : Colors.blue,
            border: Border.all(
              color: isFollowing ? Colors.grey : Colors.blue,
            ),
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
      ),
    );
  }

  buildProfileButton(){
    //viewing your own profile- should show edit profile button
    bool isProfileOwner=currentUser.id==widget.profileId;

    if(isProfileOwner){
      return buildButton(
        text: "Edit Profile",
        function: editProfile
      );
    }else if(isFollowing){
      return buildButton(text: "Unfollow",function: handleUnfollowUser);
    }else if(!isFollowing){
      return buildButton(text: "Follow",function: handlefollowUser);
    }

  }//end of buildProfileButton()

  handlefollowUser(){
    setState(() {
      isFollowing=true;
    });
    //make auth user follower of that user
    followersRef.doc(widget.profileId).collection("userFollowers").doc(currentUserId).set({});

    //put that user on your following list yeah ....
    followingRef.doc(currentUserId).collection("userFollowing").doc(widget.profileId).set({});

    //Add activity feed to notify use about new follower
    acitivityFeedRef.doc(widget.profileId).collection("feedItems").doc(currentUserId).set({
      "type":"follow",
      "ownerId":widget.profileId,
      "username":currentUser.username,
      "userId":currentUserId,
      "userProfileImg":currentUser.photoUrl,
      "timestamp":timestamp
    });

  }//end of handlefollowUser..

  handleUnfollowUser(){
    setState(() {
      isFollowing=false;
    });

    //mremove auth user follower of that user
    //followersRef.doc(widget.profileId).collection("userFollowers").doc(currentUserId).delete();
    followersRef.doc(widget.profileId).collection("userFollowers").doc(currentUserId).get().then((doc){
      if(doc.exists){
        doc.reference.delete();
      }
    });

    //remove following
    followingRef.doc(currentUserId).collection("userFollowing").doc(widget.profileId).get().then((doc){
      if(doc.exists){
        doc.reference.delete();
      }
    });

    //remove activity feed to notify use about new follower
    acitivityFeedRef.doc(widget.profileId).collection("feedItems").doc(currentUserId).get().then((doc){
      if(doc.exists){
        doc.reference.delete();
      }
    });

  }//end of handleUnfollow_User...

  buildProfileHeader(){
    return FutureBuilder(
      future: usersRef.doc(widget.profileId).get(),

        builder: (context,snapshot){
          if(!snapshot.hasData){
            return circularProgress();
          }

          User user=User.fromDocument(snapshot.data);
          //annegrere    .....    .....   ......   .......   ......
          return Padding(
              padding: EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 40.0,
                      backgroundColor: Colors.grey,
                      backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              buildCountColumn("posts",postCount),
                              buildCountColumn("followers",followerCount),
                              buildCountColumn("following",followingCount),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              buildProfileButton(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 12.0),
                  child: Text(
                    user.username,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 4.0),
                  child: Text(
                    user.displayName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 2.0),
                  child: Text(
                    //user.bio,
                    "bio here....delete me",
                  ),
                ),
              ],
            ),
          );
        },
    );
  }

  getProfilePosts() async {
    setState(() {
      isLoading:true;
    });

    QuerySnapshot snapshot=await postsRef.doc(widget.profileId).collection("userPosts").orderBy('timestamp',descending: true).get();
    setState(() {
      isLoading:false;
      postCount=snapshot.docs.length;
      posts=snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
    });

  }

  Container showNoPostsIndicator(){
    return Container(
      color: Theme.of(context).accentColor.withOpacity(0.6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset(
            'assets/images/no_content.svg',
            height: 200.0,
          ),
          Padding(
            padding: EdgeInsets.only(top: 20.0),
              child: Text(
                "No Posts",
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 40.0,
                  fontWeight: FontWeight.bold
                ),
              ),
          ),
        ],
      ),
    );
  }

  buildProfilePosts(){
    if(isLoading){
      return circularProgress();
    }else if(posts.isEmpty){
      return showNoPostsIndicator();
    }else if(postOrientation=="grid"){
      List<GridTile> gridTiles=[];
      posts.forEach((post) {
        gridTiles.add(GridTile(child: PostTile(post: post)));
      });

      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridTiles,
      );
    }else if(postOrientation=="list"){
    return Column(
      children: posts,
    );
    }

    /*
    return Column(
      children: posts,
    );*/


  }


  setPostOrientation(String postOrientation){
    setState(() {
      this.postOrientation=postOrientation;
    });
  }

  buildTogglePostOrientation(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
            icon: Icon(Icons.grid_on),
            color: postOrientation=="grid" ? Theme.of(context).primaryColor: Colors.grey,
            onPressed: ()=>setPostOrientation("grid"),
        ),
        IconButton(
          icon: Icon(Icons.list),
          color:postOrientation=="list" ? Theme.of(context).primaryColor:Colors.grey,
          onPressed: ()=>setPostOrientation("list"),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: header(context,isAppTitle: false,titleText: "Profile"),
      body: ListView(
        children: <Widget>[
          buildProfileHeader(),
          Divider(),
          buildTogglePostOrientation(),
          Divider(
            height: 0.0,
          ),
          buildProfilePosts(),
        ],
      ),
    );
  }
}



