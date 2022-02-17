import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:gisthouse/models/models.dart';
import 'package:gisthouse/pages/clubs/view_club.dart';
import 'package:gisthouse/pages/home/select_interests.dart';
import 'package:gisthouse/pages/room/followers_list.dart';
import 'package:gisthouse/services/database.dart';
import 'package:gisthouse/util/utils.dart';

class NewClub extends StatefulWidget {
  @override
  _NewClubState createState() => _NewClubState();
}

class _NewClubState extends State<NewClub> {
  final picker = ImagePicker();
  File _imageFile;
  bool publish = false,
      membersprivate = false,
      allowfollowers = false,
      membercanstartrooms = false;
  List<Interest> selectedTopicsList = [];
  List<String> selectedTopicsListString = [];
  bool loading = false;

  final clubcontroller = TextEditingController();
  final descriptioncontroller = TextEditingController();

  _cropImage(filePath) async {
    File croppedImage = await ImageCropper.cropImage(
        sourcePath: filePath,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        aspectRatioPresets: [CropAspectRatioPreset.square],
        compressQuality: 70,
        compressFormat: ImageCompressFormat.jpg,
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
          rotateClockwiseButtonHidden: false,
          rotateButtonsHidden: false,
        ));
    if (croppedImage != null) {
      _imageFile = croppedImage;
      setState(() {});
    }
  }

  _getFromGallery(ImageSource imageSource) async {
    PickedFile pickedFile = await picker.getImage(
      source: imageSource,
    );
    _cropImage(pickedFile.path);
  }

  selectedItemsCallback(List<Interest> items) {
    selectedTopicsList = items;
    selectedTopicsListString.clear();
    items.forEach((element) {
      selectedTopicsListString.add(element.title);
    });
    setState(() {});
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
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
                  _getFromGallery(ImageSource.gallery);
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
                  _getFromGallery(ImageSource.camera);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Style.themeColor,
      body: loading == true
          ? Center(
              child: Container(
                height: MediaQuery.of(context).size.height,
                color: Colors.white60,
                child: LoadingIndicator(
                  indicatorType: Indicator.ballPulse,

                  /// Required, The loading type of the widget
                  colors: const [Colors.white],
                ),
              ),
            )
          : SafeArea(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 20,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
//cancel text button
                              GestureDetector(
                                onTap: () {
                                  Get.back();
                                },
                                child: Text(
                                  "Cancel",
                                  style: TextStyle(
                                      color: Colors.green, fontSize: 23),
                                ),
                              ),
//new club text
                              Text(
                                "NEW CLUB",
                                style: TextStyle(
                                    fontSize: 19, color: Colors.black),
                              ),
//create text button
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                child: Text(
                                  "Create",
                                  style: TextStyle(
                                      color: clubcontroller.text.isEmpty
                                          ? Colors.grey
                                          : Colors.green,
                                      fontSize: 23),
                                ),
                                onPressed: clubcontroller.text.isEmpty
                                    ? null
                                    : () async {
                                        setState(() {
                                          loading = true;
                                        });
                                        var ref = await Database().addClub(
                                          title: clubcontroller.text,
                                          image: _imageFile,
                                          description:
                                              descriptioncontroller.text,
                                          allowfollowers: allowfollowers,
                                          membersprivate: membersprivate,
                                          membercanstartrooms:
                                              membercanstartrooms,
                                          selectedTopicsList:
                                              selectedTopicsList,
                                        );
                                        if (ref != null) {
                                          Club club = await Database()
                                              .getClubByIdDetails(ref.toString());
                                          Get.back();
                                          Get.to(() => ViewClub(club: club));
                                          Get.to(
                                              () => FollowersList(club: club));
                                        }
                                        setState(() {
                                          loading = false;
                                        });
                                      },
                              )
                            ],
                          )),
                      buildContents(),
                      SizedBox(
                        height: 20,
                      ),
//club name textfield
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: TextFormField(
                          controller: clubcontroller,
                          maxLength: 30,
                          onChanged: (val) {
                            if (val.isEmpty) {
                              setState(() {
                                publish = false;
                              });
                            } else {
                              setState(() {
                                publish = true;
                              });
                            }
                          },
                          decoration: InputDecoration(
                              hintStyle: TextStyle(
                                  fontSize: 16, color: Style.AccentBrown),
                              hintText: "Club Name",
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              fillColor: Colors.white),
                          keyboardType: TextInputType.text,
                          style:
                              TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ),
                      SizedBox(
                        height: 3,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Required can't be changed later",
                              style: TextStyle(
                                  fontFamily: "InterRegular",
                                  color: Colors.black54),
                            )),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Card(
                        color: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      "Allow Followers",
                                      style: (TextStyle(
                                          fontSize: 18,
                                          color: Colors.black)),
                                    ),
                                  ),
                                  CupertinoSwitch(
                                    value: allowfollowers,
                                    onChanged: (value) {
                                      allowfollowers = value;
                                      setState(() {});
                                    },
                                  )
                                ],
                              ),
                              Divider(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      "Let Members Start Rooms",
                                      style: (TextStyle(
                                          fontSize: 18,
                                          color: Colors.black)),
                                    ),
                                  ),
                                  CupertinoSwitch(
                                    value: membercanstartrooms,
                                    onChanged: (value) {
                                      membercanstartrooms = value;
                                      setState(() {});
                                    },
                                  )
                                ],
                              ),
                              Divider(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      "Make Member List Private",
                                      style: (TextStyle(
                                          fontSize: 18,
                                          color: Colors.black)),
                                    ),
                                  ),
                                  CupertinoSwitch(
                                    value: membersprivate,
                                    onChanged: (value) {
                                      membersprivate = value;
                                      setState(() {});
                                    },
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        color: Colors.white,
                        elevation: 2,
                        child: InkWell(
                          onTap: () {
                            Get.to(() => InterestsPick(
                                  title: "Choose Topics",
                                  subtitle:
                                      "Choose up to 3 topics to help others find and understand your club",
                                  selectedItemsCallback: selectedItemsCallback,
                                  club: new Club(topics: selectedTopicsList),
                                ));
                          },
//topics container
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Topics",
                                  style: (TextStyle(
                                      fontSize: 18, color: Colors.black)),
                                ),
                                // Container(
                                //     child: Text(selectedTopicsListString.join(", ").substring(0,28),
                                //     ),
                                // ),
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    selectedTopicsListString.join(", ").length >
                                            28
                                        ? Text(selectedTopicsListString
                                            .join(", ")
                                            .substring(0, 28), style: TextStyle(color: Colors.black),)
                                        : Text(selectedTopicsListString
                                            .join(", "), style: TextStyle(color: Colors.black)),
                                    if (selectedTopicsListString.length == 0)
//add button
                                      Text(
                                        "Add",
                                        style: (TextStyle(
                                          fontSize: 16,
                                          color: Colors.black54,
                                        )),
                                      ),
                                    Icon(
                                      Icons.keyboard_arrow_right_rounded,
                                      size: 30,
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
//description
                      Padding(
                        padding: const EdgeInsets.only(bottom: 40.0),
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          elevation: 2,
                          child: Container(
                            decoration: new BoxDecoration(
                                shape: BoxShape.rectangle,
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10)),
                            height: 200,
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: TextFormField(
                              controller: descriptioncontroller,
                              maxLines: null,
                              decoration: InputDecoration(
                                  hintStyle:
                                      TextStyle(fontSize: 20, color: Colors.black54),
                                  hintText: 'Description',
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  fillColor: Colors.white),
                              keyboardType: TextInputType.multiline,
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
//photo place holder
  Widget buildContents() {
    return InkWell(
      onTap: () {
        _showMyDialog();
      },
      child: Container(
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(35),
        ),
        child: _imageFile != null
            ? Container(
                child: ClipOval(
                  child: Image.file(
                    _imageFile,
                    height: 90,
                    width: 90,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            : Icon(
                Icons.add_photo_alternate_outlined,
                size: 80,
                color: Style.AccentGreen,
              ),
      ),
    );
  }
}
