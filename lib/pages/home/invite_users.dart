// import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:gisthouse/util/utils.dart';

class InviteContants extends StatefulWidget {

  @override
  _InviteContantsState createState() => _InviteContantsState();
}

class _InviteContantsState extends State<InviteContants> {
  bool loading = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();//
    getContacts();
  }

  Future getContacts() async {
    setState(() {
      loading = false;
    });
    await Permission.contacts.request().whenComplete((){
      setState(() {
        loading = true;
      });
    });

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Invites".toUpperCase(), style: TextStyle(color: Colors.black),),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Center(child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text("Who is a great addition to GistHouse?", style: TextStyle(
              fontSize: 18
            ),),
          )),

          Container(
            margin: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Style.search,
                    ),
                    margin: EdgeInsets.only(right: 20),
                    child: TextField(
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(8.0, 13.0, 8.0, 8.0),
                          prefixIcon: Icon(Icons.search),
                          hintText: "Search or invite a phone",
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                        )
                    ),
                  ),
                ),
                Icon(
                  Icons.contact_page,
                  size: 30,
                )
              ],
            ),
          ),
          // if(loading == true) Expanded(
          //     child: Container(
          //       margin: EdgeInsets.symmetric(horizontal: 20),
          //       child: FutureBuilder(
          //         future: ContactsService.getContacts(withThumbnails: true),
          //         builder: (context, snapshot) {
          //           if(snapshot.connectionState == ConnectionState.waiting){
          //             return loadingWidget(context);
          //           }
          //           if(snapshot.data == null){
          //             return Container();
          //           }
          //           Iterable<Contact> contacts = snapshot.data;
          //           return ListView.separated(
          //             separatorBuilder: (c, i) {
          //               return Container(
          //                 height: 15,
          //               );
          //             },
          //             itemCount: contacts.length,
          //             itemBuilder: (context, index) {
          //               return singleItem(contacts.elementAt(index));
          //             },
          //           );
          //         }
          //       ),
          //     )),
        ],

      ),
    );
  }


  // Widget singleItem(Contact contact) {
  //   return Container(
  //     child: Row(
  //       children: [
  //         RoundImage(
  //           txt: contact.displayName,
  //           width: 45,
  //           height: 45,
  //           txtsize: 16,
  //           borderRadius: 18,
  //         ),
  //         SizedBox(
  //           width: 16,
  //         ),
  //         Expanded(
  //           child: Column(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 contact.displayName,
  //                 textScaleFactor: 1,
  //                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  //               ),
  //               // Text(
  //               //   contact.jobTitle,
  //               //   textScaleFactor: 1,
  //               //   maxLines: 2,
  //               //   overflow: TextOverflow.ellipsis,
  //               // ),
  //             ],
  //           ),
  //         ),
  //         SizedBox(
  //           width: 16,
  //         ),
  //         TextButton(
  //           style: ButtonStyle(
  //             overlayColor: MaterialStateProperty.all(Colors.transparent),
  //           ),
  //           child: Container(
  //             padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
  //             decoration: BoxDecoration(
  //                 border: Border.all(
  //                   color: Style.indigo,
  //                   width: 2,
  //                   style: BorderStyle.solid,
  //                 ),
  //                 borderRadius: BorderRadius.circular(20)),
  //             child: Text("Invite",
  //               textScaleFactor: 1,
  //               style: TextStyle(
  //                   color: Style.indigo,
  //                   fontFamily: "InterSemiBold",
  //                   fontSize: 13
  //               ),
  //             ),
  //           ),
  //           onPressed: () {
  //             DynamicLinkService()
  //                 .createGroupJoinLink(contact.displayName,"invite")
  //                 .then((value) async {
  //                   Database.updateProfileData(Get.find<UserController>().user.uid, {
  //                     "invited": FieldValue.arrayUnion([contact.phones.first.value])
  //                   });
  //               _textMe(contact,value);
  //             });
  //           },
  //         ),
  //       ],
  //     ),
  //   );
  // }
  // _textMe(Contact contact,String link) async {
  //
  //   // Android
  //   String uri = 'sms:${contact.phones.first.value}?body=Hey ${contact.displayName} - You should join us on GistHouse. Here is the link! $link';
  //   if (await canLaunch(uri)) {
  //     await launch(uri);
  //   } else {
  //     // iOS
  //     String uri = 'sms:${contact.phones.first.value}?body=Hey ${contact.displayName} - You should join us on GistHouse. Here is the link! $link';
  //     if (await canLaunch(uri)) {
  //       await launch(uri);
  //     } else {
  //       throw 'Could not launch $uri';
  //     }
  //   }
  // }
}
