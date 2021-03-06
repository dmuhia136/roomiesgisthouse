import 'package:gisthouse/util/firebase_refs.dart';

class Data{

  static addInterests(){
    Map<String, Map<String, dynamic>>  interests = {
      "π± Tech" : {
        "data" : [
          "π΄ Startups",
          "π± Product",
          "π Engineering",
          "πΉ Marketing",
          "π AI",
        ]
      },
      "π± Identity" : {
        "data" : [
          "π« Woman",
          "π± Indigenous",
          "πΉ Gemz",
          "π South Asia",
          "πΏπ¦ Millenials",
          "π« Latino",
          "π± Black",
          "πΉ Disabled",
          "π East Asia",
          "πΏπ¦ Africa",
        ]
      },
      "π± Places" : {
        "data" : [
          "π« NewYork",
          "π± London",
          "πΉ Africa",
          "π Australia",
          "πΏπ¦ China",
        ]
      },
      "π± Sports" : {
        "data" : [
          "π« Soccer",
          "π± Cricket",
          "πΉ Tennis",
          "π Volley Ball",
          "πΏπ¦ Golf",
        ]
      }
    };
    interestsRef.get().then((value){
      if(value.docs.length == 0){
        interests.forEach((key, value) {
          interestsRef.doc(key).set(value);
        });
      }
    });

  }
}