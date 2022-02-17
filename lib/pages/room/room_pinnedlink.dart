
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gisthouse/anylinks/web_analyzer.dart';
import 'package:gisthouse/widgets/widgets.dart';

class RoomPinnedLink extends StatefulWidget {
  Function pinnedlinkCallback;
  String link;

  RoomPinnedLink({this.pinnedlinkCallback,this.link});

  @override
  _RoomPinnedLinkState createState() => _RoomPinnedLinkState();
}

class _RoomPinnedLinkState extends State<RoomPinnedLink> {
  final pinnedlinkurl = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.link !=null && widget.link.isNotEmpty){
      pinnedlinkurl.text = widget.link;
    }
  }
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Container(

      child: loading == true ?  loadingWidget(context) : Padding(
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
                          labelText: 'Pin a Link (without http(s))',
                          labelStyle: TextStyle(color: Colors.grey[500]),
                          hintStyle: TextStyle(color: Colors.grey[500])),
                      controller: pinnedlinkurl,
                      style: TextStyle(color: Colors.white),
                    ),
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
                  onPressed: () async {
                    String _url = "https://"+pinnedlinkurl.text;
                    setState(() {
                      loading = true;
                    });
                    final response = await WebAnalyzer.requestUrl(_url.trim(), callback: (type,data){
                      setState(() {
                        loading = false;
                      });
                      if(type){
                        widget.pinnedlinkCallback(pinnedlinkurl.text.trim());
                        // setState(() {});
                        Get.back();
                      }else{
                        topTrayPopup("we cannot accept that url");
                      }

                    });

                    // InfoBase info = await WebAnalyzer.requestUrl(_url);
                    // if(response)


                  },
                ),
              )
            ]),
          ),
        ]),
      ),
    );
  }


}
