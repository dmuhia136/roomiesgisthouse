import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gisthouse/controllers/controllers.dart';
import 'package:gisthouse/models/models.dart';
import 'package:gisthouse/services/database.dart';
import 'package:gisthouse/util/utils.dart';
import 'package:gisthouse/widgets/top_tray_popup.dart';
//ignore: must_be_immutable
class SelectHostClub extends StatefulWidget {
  List<Club> selectedClubs;
  Function setSelectedClubs;
  SelectHostClub({this.selectedClubs,this.setSelectedClubs});
  @override
  _SelectHostClubState createState() => _SelectHostClubState();
}

class _SelectHostClubState extends State<SelectHostClub> {
  List<Club> clubs = [];


  @override
  void initState() {
    clubs = widget.selectedClubs;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Style.themeColor,
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(top: 30, left: 20, right: 20),
          child: Column(
            children: [
              Container(
                height: 80,
                child: CupertinoNavigationBar(
                  backgroundColor: Style.themeColor,
                  padding: EdgeInsetsDirectional.only(top: 15, end: 10,bottom: 10),
                  leading: GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: Icon(Icons.arrow_back_ios),
                  ),
                  border: Border(bottom: BorderSide(color: Colors.transparent)),
                  middle: Text(
                    "HOST CLUB",
                    style: TextStyle(fontSize: 20, color: Colors.black),
                  ),
                ),
              ),
              SizedBox(height: 20,),
              Card(
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text("No Host Club", style: TextStyle(color: Colors.black),),
                        trailing: clubs.isEmpty
                            ? Icon(Icons.check, size: 30,color: Colors.green,)
                            : null,
                        onTap: (){
                          clubs = [];
                          widget.setSelectedClubs(clubs);
                          setState(() {});
                        },
                      ),
                      Divider(color: Colors.grey),
                      FutureBuilder(
                          future: Database.getMyClubs(Get.find<UserController>().user.uid),
                          builder: (context, snapshot) {
                            if(snapshot.hasError){
                            }
                            if (snapshot.hasData) {
                              List<Club> club = snapshot.data;
                              return ListView(
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                  physics: const NeverScrollableScrollPhysics(),
                                  children: club.map((e) => Column(
                                  children: [
                                    ListTile(
                                      title: Text(e.title, style: TextStyle(fontFamily: "InterSemiBold", fontSize: 16,color: Style.AccentBrown)),
                                      leading: Container(
                                        width: 50,
                                        height: 50,
                                        margin: EdgeInsets.only(right: 5),
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(20),
                                            color: Style.SelectedItemGrey),
                                        child: Center(
                                            child: Text(
                                              e.title.substring(0,2).toUpperCase(),
                                              style: TextStyle(fontFamily: "InterSemiBold",color: Style.AccentBrown),
                                            )),
                                      ),
                                      trailing: clubs.any((element) => element.id == e.id)
                                          ? Icon(Icons.check, size: 30,color: Colors.green,)
                                          : null,
                                      onTap: (){
                                        if(e.membercanstartrooms == false && e.ownerid != Get.find<UserController>().user.uid){
                                          topTrayPopup("You are not allowed to start a room with ${e.title} club");
                                        }else{
                                          if(clubs.any((element) => element.id == e.id)){
                                            clubs.removeWhere((element) => element.id == e.id);

                                          } else {
                                            clubs.add(e);

                                          }
                                          widget.setSelectedClubs(clubs);
                                          setState(() {});

                                        }

                                      },
                                    ),
                                    Divider()
                                  ],
                                )).toList(),
                              );
                            }else{
                              return Container();
                            }
                          })
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

}
