import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gisthouse/controllers/controllers.dart';
import 'package:gisthouse/models/models.dart';
import 'package:gisthouse/pages/profiles/following_followers.dart';
import 'package:gisthouse/services/database.dart';
import 'package:gisthouse/services/database_api/user_api.dart';
import 'package:gisthouse/util/configs.dart';
import 'package:gisthouse/util/utils.dart';
import 'package:gisthouse/widgets/widgets.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class UserContent extends StatefulWidget {
  UserModel profile;
  final bool fromRoom;

  // final Room room;
  final bool short;
  final bool isTwoLineDescription;
  final bool isMe;

  UserContent(this.profile,
      {this.isTwoLineDescription = true,
      this.isMe = false,
      // this.room,
      this.fromRoom,
      this.short});

  @override
  _UserContentState createState() => _UserContentState();
}

class _UserContentState extends State<UserContent> {
  UserModel userModel = Get.find<UserController>().user;
  final picker = ImagePicker();
  StreamSubscription<DocumentSnapshot> streamSubscription;
  File _imageFile;

  String followtxt = "";
  bool loading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getUsersFromApi();

    // followersFollowingListener();
  }

  getUsersFromApi() async {
    var user = await UserApi().getUserById(widget.profile.uid);

    widget.profile = UserModel.fromJson(user);
    if (userModel.following.contains(widget.profile.uid)) {
      followtxt = "Unfollow";
    } else if (userModel.blocked.contains(widget.profile.uid)) {
      followtxt = "Blocked";
    } else if (!userModel.following.contains(widget.profile.uid)) {
      followtxt = "Follow";
    }
    setState(() {});
  }

  @override
  void dispose() {
    if (streamSubscription != null) {
      streamSubscription.cancel();
    }

    super.dispose();
  }

  //listening to the users profile cahnges
  followersFollowingListener() async {
    //listener for the current user profile followers and followed
    var currentUser =
        await UserApi().getUserById(Get.find<UserController>().user.uid);

    userModel = UserModel.fromJson(currentUser);

    if (userModel.following.contains(widget.profile.uid)) {
      followtxt = "Unfollow";
    } else if (userModel.blocked.contains(widget.profile.uid)) {
      followtxt = "Blocked";
    } else if (!userModel.following.contains(widget.profile.uid)) {
      followtxt = "Follow";
    }

    setState(() {});

    //listener for the user profile followers and followed
    var profileUser = await UserApi().getUserById(widget.profile.uid);

    widget.profile = UserModel.fromJson(profileUser);
    if (userModel.following.contains(widget.profile.uid)) {
      followtxt = "Unfollow";
    } else if (userModel.blocked.contains(widget.profile.uid)) {
      followtxt = "Blocked";
    } else if (!userModel.following.contains(widget.profile.uid)) {
      followtxt = "Follow";
    }
    setState(() {});
  }

  _cropImage(filePath, setState) async {
    File croppedImage = await ImageCropper.cropImage(
        sourcePath: filePath,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        aspectRatioPresets: [CropAspectRatioPreset.square],
        compressQuality: 70,
        maxHeight: IMAGE_UPLOAD_SIZE,
        maxWidth: IMAGE_UPLOAD_SIZE,
        compressFormat: ImageCompressFormat.jpg,
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
          rotateClockwiseButtonHidden: false,
          rotateButtonsHidden: false,
        ));
    if (croppedImage != null) {
      _imageFile = croppedImage;
      Get.put(OnboardingController()).imageFile = _imageFile;
      setState(() {});
    }
  }

  _getFromGallery(setState, ImageSource imageSource) async {
    PickedFile pickedFile = await picker.getImage(
      source: imageSource,
    );
    _cropImage(pickedFile.path, setState);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () {
            if (widget.profile.uid == Get.find<UserController>().user.uid) {
              updateUserPhoto("upload");
            } else {
              updateUserPhoto("view");
            }
          },
//profile image
          child: RoundImage(
            url: widget.profile.smallimage,
            txtsize: 35,
            txt: widget.profile.firstname,
            width: 110,
            height: 110,
            borderRadius: 40,
          ),
        ),
        SizedBox(
          height: 20,
        ),
        Container(
          width: MediaQuery.of(context).size.width * .5,
          height: 50,
          // padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colors.white,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () {
                  Get.to(() => FollowingFollowers(
                      type: "followers", userid: widget.profile.uid));
                },
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.profile.followers.length.toString(),
                        style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                            fontFamily: "LucidaGrande",
                            color: Style.AccentBrown),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text('Followers',
                          style: TextStyle(
                              fontSize: 12,
                              fontFamily: "LucidaGrande",
                              color: Style.AccentBrown)),
                    ]),
              ),
              Container(
                height: MediaQuery.of(context).size.height,
                width: 1,
                color: Colors.black,
              ),
              InkWell(
                onTap: () {
                  Get.to(() => FollowingFollowers(
                      type: "following", userid: widget.profile.uid));
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.profile.following.length.toString(),
                      style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          fontFamily: "LucidaGrande",
                          color: Style.AccentBrown),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      'Following',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                          fontFamily: "LucidaGrande"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 20,
        ),
        if (widget.profile.uid != userModel.uid)
          InkWell(
            onTap: () {
              if (userModel.following.contains(widget.profile.uid)) {
                userModel.following.remove(widget.profile.uid);
                setState(() {});
                Database().unFolloUser(widget.profile.uid);
              } else {
                userModel.following.add(widget.profile.uid);
                setState(() {});
                Database().folloUser(widget.profile);
              }
            },
//follow and unfollow button
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: userModel.blocked.contains(widget.profile.uid)
                      ? Colors.red
                      : Colors.blue),
              child: Text(
                userModel.following.contains(widget.profile.uid) == true
                    ? "UnFollow"
                    : "follow",
                style: TextStyle(color: Colors.white, fontSize: 17),
              ),
            ),
          ),
        SizedBox(
          height: 10,
        ),
        InkWell(
          onTap: widget.profile.uid != userModel.uid
              ? null
              : () {
                  editProfileInfo(
                      texttoedit: widget.profile.getName(), action: "name");
                },
          child: Text(
            widget.profile.getName(),
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: "LucidaGrande",
                color: Colors.black87
            ),
          ),
        ),
        SizedBox(
          height: 5,
        ),
        InkWell(
          onTap: widget.profile.uid != userModel.uid
              ? null
              : () {
                  editProfileInfo(
                      texttoedit: widget.profile.username, action: "username");
                },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.profile.username,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontFamily: "LucidaGrande",
                  color: Colors.black87),
            ),
          ),
        ),
        SizedBox(
          height: 5,
        ),
        SizedBox(
          height: 50,
          child: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: GridView.count(
              primary: false,
              padding: EdgeInsets.zero,
              shrinkWrap: false,
              childAspectRatio: 8.5,
              crossAxisCount: 2, children: [
              if(widget.profile.twitter != null)
                InkWell(
                onTap: () => launch(widget.profile.twitter),
                child: Row(
                  children: [
                    Image.asset("assets/icons/twitter.png", color: Style.Blue, height: 15, width: 15,),
                    SizedBox(
                      width: 10,
                    ),
                    Text("Twitter", style: TextStyle(color: Style.Blue),)
                  ],
                ),
              ),
              if(widget.profile.instagram != null)
                InkWell(
                onTap: () => launch(widget.profile.instagram),
                child: Row(
                  children: [
                    Image.asset("assets/icons/insta.png", color: Style.Blue, height: 15, width: 15,),
                    SizedBox(
                      width: 10,
                    ),
                    Text("Instagram", style: TextStyle(color: Style.Blue),)
                  ],
                ),
              ),
              if(widget.profile.facebook != null)
                InkWell(
                onTap: () => launch(widget.profile.facebook),
                child: Row(
                  children: [
                    Image.asset("assets/icons/facebook.png", color: Style.Blue, height: 15, width: 15,),
                    SizedBox(
                      width: 10,
                    ),
                    Text("Facebook", style: TextStyle(color: Style.Blue),)
                  ],
                ),
              ),
              if(widget.profile.linkedIn != null)
                InkWell(
                onTap: () => launch(widget.profile.linkedIn),
                child: Row(
                  children: [
                    Image.asset("assets/icons/linkedin.png", color: Style.Blue, height: 15, width: 15,),
                    SizedBox(
                      width: 10,
                    ),
                    Text("LinkedIn", style: TextStyle(color: Style.Blue,))
                  ],
                ),
              ),
            ],),
          ),
        ),

        if (widget.profile.uid == userModel.uid && widget.profile.bio.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: InkWell(
              onTap: () {
                editProfileInfo(texttoedit: "", action: "bio");
              },
              child: Text(
                widget.profile.bio.isEmpty ? "Add a bio" : widget.profile.bio,
                style: TextStyle(
                    fontSize: 15,
                    color: widget.profile.bio.isEmpty
                        ? Style.Blue
                        : Colors.black),
              ),
            ),
          ),
        if (widget.profile.bio.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: InkWell(
              onTap: widget.profile.uid != userModel.uid
                  ? null
                  : () {
                      editProfileInfo(
                          texttoedit: widget.profile.bio, action: "bio");
                    },
              child: Text(
                widget.profile.bio,
                // overflow: TextOverflow.ellipsis,
                maxLines: widget.short == true ? 2 : null,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black,
                  fontFamily: "LucidaGrande",
                ),
              ),
            ),
          ),
        SizedBox(
          height: 5,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Divider(
            color: Style.AccentBrown,
          ),
        ),
        SizedBox(
          height: 4,
        ),
        FutureBuilder(
          future: Database.getProfileEvents(widget.profile.uid, 1),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container();
            }
            if (snapshot.hasError) {}
            if (snapshot.hasData) {
              return ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: snapshot.data.map<Widget>((document) {
                    UpcomingRoom upcomingroom = UpcomingRoom.fromJson(document);
                    return InkWell(
                      onTap: () {
                        upcomingroomBottomSheet(
                            context, upcomingroom, loading, false);
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat("dd, MM yyyy")
                                      .format(
                                          DateTime.fromMillisecondsSinceEpoch(
                                              upcomingroom.eventdate))
                                      .toString(),
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.white),
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  DateFormat("h:mma")
                                      .format(
                                          DateTime.fromMillisecondsSinceEpoch(
                                              upcomingroom.eventtime))
                                      .toString(),
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.white),
                                      text: upcomingroom.title),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (upcomingroom.clubListNames.length > 0)
                                  CategoryRow(
                                    category: upcomingroom.clubListNames,
                                  ),
                                SizedBox(
                                  height: 4,
                                ),
                                RichText(
                                  text: TextSpan(
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.white),
                                      text: upcomingroom.description),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            child: Icon(
                              CupertinoIcons.bell,
                              color: upcomingroom.users.indexWhere((element) =>
                                          element.uid ==
                                          Get.find<UserController>()
                                              .user
                                              .uid) !=
                                      -1
                                  ? Colors.red
                                  : Colors.white,
                            ),
                            onTap: () async {
                              if (upcomingroom.users.indexWhere((element) =>
                                      element.uid ==
                                      Get.find<UserController>().user.uid) ==
                                  -1) {
                                await Database().addUsertoUpcomingRoom(
                                    upcomingroom,
                                    fromhome: true);
                              } else {}
                            },
                          )
                        ],
                      ),
                    );
                  }).toList());
            }
            return Container();
          },
        ),
      ],
    );
  }

  Future<void> _showMyDialog(setState) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: false,
          title: const Text('Add a profile photo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 10,
              ),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  _getFromGallery(setState, ImageSource.gallery);
                },
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text("Choose from galley"),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  _getFromGallery(setState, ImageSource.camera);
                },
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text("Take photo"),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  /*
      user profile photo
   */
  updateUserPhoto(String type) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Style.LightBrown,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
        topLeft: Radius.circular(15),
        topRight: Radius.circular(15),
      )),
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return DraggableScrollableSheet(
              initialChildSize: 0.9,
              expand: false,
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (type == "view")
                        Align(
                          alignment: Alignment.topRight,
                          child: InkWell(
                            onTap: () => Get.back(),
                            child: Icon(
                              Icons.close,
                              size: 30,
                            ),
                          ),
                        ),
                      if (type == "upload")
                        Text(
                          "Change your photo",
                          style: TextStyle(fontSize: 26),
                        ),
                      SizedBox(
                        height: 10,
                      ),
                      InkWell(
                        onTap: () {
                          if (type == "upload") _showMyDialog(setState);
                        },
                        child: type == "view"
                            ? Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: Container(
                                    height: 250,
                                    width: 250,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[350],
                                      borderRadius: BorderRadius.circular(80),
                                      image: widget
                                              .profile.profileImage.isNotEmpty
                                          ? DecorationImage(
                                              image: NetworkImage(
                                                  widget.profile.profileImage),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                    ),
                                  ),
                                ),
                              )
                            : _imageFile != null
                                ? Container(
                                    width: 200,
                                    height: 200,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(80),
                                    ),
                                    child: _imageFile != null
                                        ? Container(
                                            child: ClipOval(
                                              child: Image.file(
                                                _imageFile,
                                                height: 250,
                                                width: 250,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          )
                                        : Icon(
                                            Icons.add_photo_alternate_outlined,
                                            size: 100,
                                            color: Style.AccentBlue,
                                          ),
                                  )
                                : RoundImage(
                                    url: userModel.profileImage,
                                    txt: userModel.firstname,
                                    txtsize: 35,
                                    width: 200,
                                    height: 200,
                                    borderRadius: 60,
                                  ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      loading == true
                          ? Container(
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : type == "view"
                              ? Container()
                              : CustomButton(
                                  text: "Done",
                                  color: Style.Blue,
                                  onPressed: type == "update" &&
                                          _imageFile == null
                                      ? null
                                      : () async {
                                          setState(() {
                                            loading = true;
                                          });
                                          if (_imageFile != null) {
                                            await Database().uploadImage(
                                                FirebaseAuth
                                                    .instance.currentUser.uid,
                                                update:
                                                    true); //createUserInfo(FirebaseAuth.instance.currentUser.uid);
                                          } else {
                                            Get.back();
                                            Get.snackbar("", "",
                                                snackPosition:
                                                    SnackPosition.BOTTOM,
                                                borderRadius: 0,
                                                margin: EdgeInsets.all(0),
                                                backgroundColor: Colors.red,
                                                colorText: Colors.white,
                                                messageText: Text.rich(TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text:
                                                          "Choose your profile image first",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                )));
                                          }

                                          Navigator.pop(context);
                                          setState(() {
                                            loading = false;
                                            _imageFile = null;
                                          });
                                        },
                                )
                    ],
                  ),
                );
              });
        });
      },
    );
  }

  /*
      user profile bio
   */
  editProfileInfo({String texttoedit, String action}) {
    var biocontroller = TextEditingController();

    biocontroller.text = texttoedit;

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Style.LightBrown,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
        topLeft: Radius.circular(15),
        topRight: Radius.circular(15),
      )),
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return DraggableScrollableSheet(
              initialChildSize: 0.9,
              expand: false,
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return Container(
                  padding: EdgeInsets.only (
                    right: 30,
                    left: 30,
                    top: 30
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Update your $action",
                        style: TextStyle(fontSize: 21, color: Colors.black),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      if (action == "name") buildForm(),
                      if (action != "name")
                        Container(
                          decoration: new BoxDecoration(
                              shape: BoxShape.rectangle,
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                          height: 200,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: TextFormField(
                            controller: biocontroller,
                            maxLength: null,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            decoration: InputDecoration(
                                hintStyle: TextStyle(
                                  fontSize: 20,
                                ),
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                fillColor: Colors.white),
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      SizedBox(
                        height: 30,
                      ),
                      CustomButton(
                        text: "Done",
                        color: Style.Blue,
                        onPressed: () {
                          if (action == "name") {
                            if (_firstNameController.text.isNotEmpty &&
                                _lastNameController.text.isNotEmpty) {
                              Navigator.pop(context);
                              Database.updateProfileData(widget.profile.uid, {
                                "firstname": _firstNameController.text,
                                "lastname": _lastNameController.text
                              });

                              Get.find<UserController>().user.firstname =
                                  _firstNameController.text;

                              Get.find<UserController>().user.lastname =
                                  _lastNameController.text;

                              setState(() {});
                            }
                          } else if(action == "username") {
                            Database.checkUsername(biocontroller.text)
                                .then((value) {
                              if (value == 0) {
                                Navigator.pop(context);
                                Database.updateProfileData(widget.profile.uid,
                                    {action: biocontroller.text});
                              } else {
                                topTrayPopup("Username is already taken");
                              }
                            });
                          } else{
                            Navigator.pop(context);
                            Database.updateProfileData(
                                widget.profile.uid, {"bio": biocontroller.text});
                            Get.find<UserController>().user.bio = biocontroller.text;
                            setState((){});
                          }
                          Navigator.pop(context);
                        },
                      )
                    ],
                  ),
                );
              });
        });
      },
    );
  }

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _firstNameFormKey = GlobalKey<FormState>();
  final _lastNameFormKey = GlobalKey<FormState>();

  Widget buildForm() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Form(
              key: _firstNameFormKey,
              child: TextFormField(
                textAlign: TextAlign.center,
                onChanged: (value) {
                  _firstNameFormKey.currentState.validate();
                },
                controller: _firstNameController,
                autocorrect: false,
                autofocus: false,
                decoration: InputDecoration(
                  hintText: 'First Name',
                  hintStyle: TextStyle(fontSize: 20, color: Style.AccentBrown),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                ),
                keyboardType: TextInputType.text,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: 10,
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Form(
              key: _lastNameFormKey,
              child: TextFormField(
                textAlign: TextAlign.center,
                onChanged: (value) {
                  _lastNameFormKey.currentState.validate();
                },
                controller: _lastNameController,
                autocorrect: false,
                autofocus: false,
                decoration: InputDecoration(
                  hintText: 'Last Name',
                  hintStyle: TextStyle(fontSize: 20, color: Style.AccentBrown),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                ),
                keyboardType: TextInputType.text,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
