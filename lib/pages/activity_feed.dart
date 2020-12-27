import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/pages/post_screen.dart';
import 'package:fluttershare/pages/profile.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'package:timeago/timeago.dart' as timeago;

class ActivityFeed extends StatefulWidget {
  @override
  _ActivityFeedState createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {

  getActivityFeed()async{
    QuerySnapshot snapshot=await acitivityFeedRef.doc(currentUser.id).collection("feedItems")
        .orderBy("timestamp",descending: true)
        .limit(40).get();

    List<ActivityFeedItem> feedItems=[];

    snapshot.docs.forEach((doc){
      feedItems.add(ActivityFeedItem.fromDocument(doc));
    });

    return feedItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context,titleText: "Activity Feed"),
      body: Container(
        child: FutureBuilder(
          future: getActivityFeed(),
          builder: (context,snapshot){
            if(!snapshot.hasData){
              return circularProgress();
            }

            return ListView(
              children: snapshot.data,
            );
          },
        ),
      ),
    );
  }
}


Widget mediaPreview;
String activityItemText;

class ActivityFeedItem extends StatelessWidget {

  final String username;
  final String userId;
  final String type;
  final String mediaUrl;
  final String postId;
  final String userProfileImg;
  final String commentData;
  final Timestamp timestamp;

  ActivityFeedItem({this.username,
    this.userId,
    this.type,
    this.mediaUrl,
    this.postId,
    this.userProfileImg,
    this.commentData,
    this.timestamp});

  factory ActivityFeedItem.fromDocument(DocumentSnapshot doc){
    return ActivityFeedItem(
      username: doc['username'],
      userId: doc['userId'],
      type: doc['type'],
      mediaUrl: doc['mediaUrl'],
      postId: doc['postId'],
      userProfileImg: doc['userProfileImg'],
      commentData: doc['commentData'],
      timestamp: doc['timestamp'],
    );
  }

  showPost(context){
    Navigator.push(context, MaterialPageRoute(builder: (context)=>PostScreen(userId: userId,postId: postId,)));
  }

  configureMediaPreview(context){
    if(type=="like" || type=="comment"){
      mediaPreview=GestureDetector(
        onTap: ()=>showPost(context),
        child: Container(
          height: 50.0,
          width: 50.0,
          child: AspectRatio(
            aspectRatio: 16/9,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit:BoxFit.cover,
                  image: CachedNetworkImageProvider(mediaUrl),
                ),
              ),
            ),
          ),
        ),
      );
    }else{
      mediaPreview=Text('');
    }

    if(type=="like"){
      activityItemText="liked your post";
    }else if(type=="follow"){
      activityItemText="is following you";
    }else if(type=="comment"){
      activityItemText="replied : ${commentData}";
    }else{
      activityItemText="Error unknown type >> ${type}";
    }

  }//end of configureMediaPreview......

  @override
  Widget build(BuildContext context) {
    configureMediaPreview(context);
    return Padding(
        padding: EdgeInsets.only(bottom: 2.0),
      child: Container(
        color: Colors.white54,
        child: ListTile(
          title: GestureDetector(
            onTap: ()=>showProfile(context,profileId: userId),
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.black
                ),
                children: [
                  TextSpan(
                    text: username,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: ' ${activityItemText}',
                  ),
                ],
              ),
            ),
          ),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(userProfileImg),
          ),
          subtitle: Text(
            timeago.format(timestamp.toDate()),
            overflow: TextOverflow.ellipsis,
          ),
          trailing: mediaPreview,
        ),
      ),
    );
  }
}


showProfile(BuildContext context, {String profileId}){
  Navigator.push(context, MaterialPageRoute(builder: (context)=>Profile(profileId: profileId)));
}