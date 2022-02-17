
class Sponsors {
  final String sponsorname;
  final String imageUrl;
  final String sponsorurl;

  Sponsors({this.sponsorname, this.imageUrl, this.sponsorurl});

  factory Sponsors.fromJson(json) {

    return Sponsors(
      sponsorname: json['sponsorname'],
      imageUrl: json['image'],
      sponsorurl: json['sponsorurl']
    );
  }

  Map<String, dynamic> toMap() => {
      'sponsorname' : sponsorname,
      'image' : imageUrl,
      'sponsorurl' : sponsorurl,
    };
  }
