import 'package:gisthouse/util/firebase_refs.dart';

class Data{

  static addInterests(){
    Map<String, Map<String, dynamic>>  interests = {
      "🖱 Tech" : {
        "data" : [
          "🐴 Startups",
          "📱 Product",
          "🚒 Engineering",
          "💹 Marketing",
          "🎙 AI",
        ]
      },
      "🖱 Identity" : {
        "data" : [
          "👫 Woman",
          "📱 Indigenous",
          "🐹 Gemz",
          "🌏 South Asia",
          "🇿🇦 Millenials",
          "👫 Latino",
          "📱 Black",
          "🐹 Disabled",
          "🌏 East Asia",
          "🇿🇦 Africa",
        ]
      },
      "🖱 Places" : {
        "data" : [
          "👫 NewYork",
          "📱 London",
          "🐹 Africa",
          "🌏 Australia",
          "🇿🇦 China",
        ]
      },
      "🖱 Sports" : {
        "data" : [
          "👫 Soccer",
          "📱 Cricket",
          "🐹 Tennis",
          "🌏 Volley Ball",
          "🇿🇦 Golf",
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