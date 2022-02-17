import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gisthouse/controllers/controllers.dart';
import 'package:gisthouse/services/database.dart';
import 'package:gisthouse/util/configs.dart';
import 'package:gisthouse/util/style.dart';
import 'package:gisthouse/widgets/round_button.dart';
import 'package:gisthouse/widgets/widgets.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PickPhotoPage extends StatefulWidget {
  @override
  _PickPhotoPageState createState() => _PickPhotoPageState();
}

class _PickPhotoPageState extends State<PickPhotoPage> {
  final picker = ImagePicker();
  bool loading = false;
  File _imageFile;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/bg.png",),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Style.themeColor,
        body: SafeArea(
          child: loading == true ? loadingWidget(context) :Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(
              top: 20,
              bottom: 20,
            ),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 15),
                  child: InkWell(
                    onTap: () async {
                      setState(() {
                        loading = true;
                      });
                        Get.find<OnboardingController>().imageFile = null;
                        getReferrer();
                        await Database().createUserInfo(FirebaseAuth.instance.currentUser.uid);
                        setState(() {
                          loading = false;
                        });
                    },
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text("Skip", style: TextStyle(fontSize: 19, color: Colors.black54),),
                    ),
                  ),

                ),
                SizedBox(
                  height: 20.0,
                ),
                buildTitle(),
                Spacer(
                  flex: 2,
                ),
                buildContents(),
                Spacer(
                  flex: 3,
                ),
                buildBottom(context),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget buildTitle() {
    return Text(
      'Add a profile photo!',
      style: TextStyle(
        fontSize: 25,
          color: Colors.black

      ),
    );
  }
  Widget buildContents() {
    return Container(
      child: GestureDetector(
        onTap: () {
          // _getFromGallery();
          _showMyDialog();

        },
        child: Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(60),
          ),
          child: _imageFile !=null ? Container(
                child: ClipOval(
                  child: Image.file(
                    _imageFile,
                    height: 140,
                    width: 140,
                    fit: BoxFit.cover,
                  ),
                ),
              ) : Icon(
            Icons.add_photo_alternate_outlined,
            size: 100,
            color: Style.Blue,
          ),
        ),
      ),
    );
  }

  Widget buildBottom(BuildContext context) {
    return CustomButton(
      color: Style.Blue,
      minimumWidth: 200,
      disabledColor: Style.Blue.withOpacity(0.3),
      onPressed: _imageFile == null ? null : () async{
        setState(() {
          loading = true;
        });
        getReferrer();
        await Database().createUserInfo(FirebaseAuth.instance.currentUser.uid);
        setState(() {
          loading = false;
        });
      },
      child: Container(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Next',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5.0),
              child: Icon(
                Icons.east,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showMyDialog() async {
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
              SizedBox(height: 10,),
              InkWell(
                onTap: (){
                  Navigator.pop(context);
                  _getFromGallery();
                },
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text("Choose from galley"),
                ),
              ),
              SizedBox(height: 20,),
              InkWell(
                onTap: (){
                  Navigator.pop(context);
                  _getFromCamera();
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
  _getFromGallery() async {
    PickedFile pickedFile = await picker.getImage(
      source: ImageSource.gallery,
    );
    _cropImage(pickedFile.path);
  }
  _getFromCamera() async {
    PickedFile pickedFile = await picker.getImage(
      source: ImageSource.camera,
    );
    _cropImage(pickedFile.path);
  }

  _cropImage(filePath) async {
    File croppedImage = await ImageCropper.cropImage(
        sourcePath: filePath,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        maxHeight: IMAGE_UPLOAD_SIZE,
        maxWidth: IMAGE_UPLOAD_SIZE,
        aspectRatioPresets: [CropAspectRatioPreset.square],
        compressQuality: 70,
        compressFormat: ImageCompressFormat.jpg,
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
          rotateClockwiseButtonHidden: false,
          rotateButtonsHidden: false,
        )
    );
    if (croppedImage != null) {
      _imageFile = croppedImage;
      Get.find<OnboardingController>().imageFile = _imageFile;
      setState(() {});
    }
  }

  //Get referrer from shared preferences
  getReferrer() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    if(prefs.containsKey('referrerId')) {
      String _referrerId = prefs.getString('referrerId');
      Get.find<OnboardingController>().referrerid = _referrerId;
    }

  }
}
