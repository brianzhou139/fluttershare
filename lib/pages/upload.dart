import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
//import for compressing
import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';
//UUID
import 'package:uuid/uuid_util.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

/**************************************************************************************************************/
/*  ternary controls display ,if file==nul show  buildSplashScreen()                                           */
/*  if fill!=null show buildUploadForm()                                                                       */
/*   buildSplashScreen()  : shows upload button and upload button displays a dialog to choose camera or gallery */
/*    buildUploadForm() : shows uploaded image and form fields for caption and location                       */
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
class Upload extends StatefulWidget {
  final User currentUser;

  Upload({this.currentUser});

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  TextEditingController locationController=TextEditingController();
  TextEditingController captionController=TextEditingController();

  File _image;
  bool isUploading=false;
  String postId=Uuid().v4();

  handleTakePhoto() async {
    Navigator.pop(context);
    PickedFile file = await ImagePicker().getImage(source: ImageSource.camera,maxHeight: 675,maxWidth: 960,);

    setState(() {
      if (file != null) {
        _image = File(file.path);
        //print("**** you picked something dude");
        //print(">> ${_image}");
      } else {
        print('No image selected.');
      }
    });

  }

  handleChooseFromGallery() async {
    Navigator.pop(context);
    PickedFile file = await ImagePicker().getImage(source: ImageSource.gallery);

    setState(() {
      if (file != null) {
        _image = File(file.path);
        print("**** you picked something dude from gallery");
        print(">> ${_image}");
      } else {
        print('No image selected.');
      }
    });

  }

  selectImage(parentContext){
    return showDialog(
        context: parentContext,
      builder: (context){
          return SimpleDialog(
            title: Text("Create Post"),
            children: <Widget>[
              SimpleDialogOption(
                child: Text("Photo with Camera"),
                onPressed: handleTakePhoto,
              ),
              SimpleDialogOption(
                child: Text("Image from Gallery"),
                onPressed: handleChooseFromGallery,
              ),
              SimpleDialogOption(
                child: Text("Cancel"),
                onPressed: ()=>Navigator.pop(context),
              ),
            ],
          );
      }
    );
  }

  Container buildSplashScreen(){
    return Container(
      color: Theme.of(context).accentColor.withOpacity(0.6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset(
              'assets/images/upload.svg',
            height: 260.0,
          ),
          Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: RaisedButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              child: Text(
                  "Upload Image",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22.0,
                ),
              ),
              color: Colors.deepOrange,
              onPressed: ()=>selectImage(context),
            ),
          ),
        ],
      ),
    );
  }


  clearImage(){
    setState(() {
      _image=null;
    });
  }

  compressImage()async{
    final tempDir=await getTemporaryDirectory();
    final path=tempDir.path;

    Im.Image imageResult=Im.decodeImage(_image.readAsBytesSync());
    File compressedImageFile = File('$path/img_$postId.jpg')..writeAsBytesSync(Im.encodeJpg(imageResult,quality: 85));

    setState(() {
      _image=compressedImageFile;
    });

  }

  Future<String> uploadImage(imageFile)async{
    final firebase_storage.UploadTask  uploadTask= storageRef.child("post_$postId.jpg").putFile(_image);

   firebase_storage.TaskSnapshot storageSnap=await uploadTask.whenComplete(() => null);
   // String downloadUrl=await storageSnap.ref.getDownloadURL();
    //String downloadUrl=await uploadTask.storage.ref().getDownloadURL();

    String downloadUrl=await storageSnap.ref.getDownloadURL();

    print("yehahhhhh >>>>>>>>>>>>>>>>>>>>>>>>>>>>");
    print("see : ${downloadUrl}");

    return downloadUrl;
  }

  createPostInFireStore({String mediaUrl,String location,String description}){

    postsRef
        .doc(widget.currentUser.id).collection("userPosts").doc(postId)
        .set({
      "postId":postId,
      "ownerId":widget.currentUser.id,
      "username":widget.currentUser.username,
      "mediaUrl":mediaUrl,
      "description":description,
      "location":location,
      "timestamp":timestamp,
      "likes":{},
    });

  }//end of createPostInFireStore


  handleSubmit() async{
    setState(() {
      isUploading=true;
    });

    await compressImage();
    String mediaUrl=await uploadImage(_image);
    createPostInFireStore(
      mediaUrl: mediaUrl,
      location:  locationController.text,
      description: captionController.text,
    );
    captionController.clear();
    locationController.clear();

    setState(() {
      _image=null;
      isUploading=false;
      postId=Uuid().v4();
    });

  }//end of handleSubmit..

  Scaffold buildUploadForm(){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,color: Colors.black,),
          onPressed: clearImage,
        ),
        title: Text(
          "Caption Post",
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          FlatButton(
              onPressed: isUploading ? null :()=>handleSubmit(),
              child: Text(
                "Post",
                style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold
                ),
              )
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          isUploading ? linearProgress():Text(""),
          Container(
            color: Colors.amber,
            height: 220.0,
            width: MediaQuery.of(context).size.width*0.8,
            child:Center(
              child: AspectRatio(
                aspectRatio: 16/10,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: FileImage(_image),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
              padding: EdgeInsets.only(top: 10.0),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(widget.currentUser.photoUrl),
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                controller: captionController,
                decoration: InputDecoration(
                  hintText: "Write a caption...",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.pin_drop,
              color: Colors.orange,
              size: 35.0,
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                controller: locationController,
                decoration: InputDecoration(
                  hintText: "Where was this photo taken?",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Container(
            width: 200.0,
            height: 100.0,
            alignment: Alignment.center,
            child: RaisedButton.icon(
                onPressed: getUserLocation,
                icon: Icon(Icons.my_location,color: Colors.white ,),
                label: Text(
                    "Use current location",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }//end of buildUploadForm

  getUserLocation()async{
    //Geolocator();
    print("getUser Location clicked 1");
    Position position =await  Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks=await Geolocator().placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placemark=placemarks[0];
    String completeAddress="${placemark.locality},${placemark.country}";
    locationController.text=completeAddress;
    print("getUser Location clicked");
    print(">> : ${completeAddress}");
  }

  @override
  Widget build(BuildContext context) {
    return _image==null ? buildSplashScreen():buildUploadForm();
  }//end of build....

}
