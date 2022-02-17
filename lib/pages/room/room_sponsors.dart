import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gisthouse/services/database.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class RoomSponsors extends StatefulWidget {
  Function sponsorClickBack;

  RoomSponsors({this.sponsorClickBack});

  @override
  _RoomSponsorsState createState() => _RoomSponsorsState();
}

class _RoomSponsorsState extends State<RoomSponsors> {
  final sponsornamecontroller = TextEditingController();
  final sponsorwebsiteurlcontroller = TextEditingController();
  File _imageFile;
  String _imageUrl;
  final picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset("assets/images/bg.png", height: MediaQuery.of(context).size.height * 100, fit: BoxFit.cover,),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: Text(
              "Add a sponsor",
              style: TextStyle(
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SizedBox(
                  height: 40,
                ),
                Container(
                  child: Column(children: [
                    Container(
                      padding: const EdgeInsets.only(
                          top: 10, bottom: 10, right: 10, left: 10),
                      width: 350,
                      child: Column(
                        children: [
                          TextFormField(
                            decoration: InputDecoration(
                                border: UnderlineInputBorder(),
                                icon: Icon(Icons.account_circle, color: Colors.grey[500],),
                                contentPadding: EdgeInsets.all(10),
                                labelText: 'Sponsor name',
                                labelStyle: TextStyle(color: Colors.grey[500]),
                                hintStyle: TextStyle(color: Colors.grey[500]),
                                hintText: 'Enter room sponsor name'),
                            controller: sponsornamecontroller,
                            style: TextStyle(color: Colors.white),
                          ),
                          // TextFormField(
                          //   decoration: InputDecoration(
                          //       border: UnderlineInputBorder(),
                          //       icon: Icon(Icons.link),
                          //       contentPadding: EdgeInsets.all(10),
                          //       labelText: 'Sponsor Website',
                          //       hintText: 'Enter room sponsor website'),
                          //   controller: sponsorwebsiteurlcontroller,
                          // ),
                          // Container(
                          //   padding: EdgeInsets.only(
                          //       left: 3, top: 20, right: 5, bottom: 20),
                          //   alignment: Alignment.centerLeft,
                          //   child: GestureDetector(
                          //     onTap: () {
                          //       // _getFromGallery();
                          //       _getFromGallery();
                          //     },
                          //     child: Container(
                          //       child: _imageFile != null
                          //           ? Row(
                          //               children: [
                          //                 Icon(
                          //                   Icons.add_photo_alternate_outlined,
                          //                   size: 25,
                          //                   color: Style.AccentGrey,
                          //                 ),
                          //                 SizedBox(
                          //                   width: 15,
                          //                 ),
                          //                 Container(
                          //                   child: Image.file(
                          //                     _imageFile,
                          //                     height: 50,
                          //                     width: 200,
                          //                     fit: BoxFit.contain,
                          //                     alignment: Alignment.centerLeft,
                          //                   ),
                          //                 ),
                          //               ],
                          //             )
                          //           : Row(
                          //               children: [
                          //                 Icon(
                          //                   Icons.add_photo_alternate_outlined,
                          //                   size: 50,
                          //                   color: Style.AccentBlue,
                          //                 ),
                          //                 SizedBox(
                          //                   width: 20,
                          //                 ),
                          //                 Text('Pick Sponsor image')
                          //               ],
                          //             ),
                          //     ),
                          //   ),
                          // )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: ElevatedButton(
                        child: Text('Save'),
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Colors.green),
                            minimumSize: MaterialStateProperty.all(Size(200, 50))),
                        onPressed: () {
                          Database()
                              .uploadSponsorImage(_imageFile)
                              .then((value) => _imageUrl = value);
                          widget.sponsorClickBack(sponsornamecontroller.text);
                          setState(() {});
                          Get.back();
                        },
                      ),
                    )
                  ]),
                ),
              ]),
            ),
          ),
        ),
      ],
    );
  }

  _getFromGallery() async {
    PickedFile pickedFile = await picker.getImage(
      source: ImageSource.gallery,
    );
    _cropImage(pickedFile.path);
  }

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
}
