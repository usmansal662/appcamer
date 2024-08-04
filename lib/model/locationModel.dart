// ignore_for_file: file_names

class LocationModel {
  double lat;
  double long;
  String address;
  String imageUrl;
  DateTime dateTime;

  LocationModel(
      {required this.address,
      required this.imageUrl,
      required this.lat,
      required this.long,
      required this.dateTime,
      });

  factory LocationModel.fromjson(Map<String, dynamic> json) {
    return LocationModel(
        address: json['address'],
        imageUrl: json['img'],
        lat: json['lat'],
        long: json['long'],
    dateTime: DateTime.parse(json['dateTime'])
    );

  }

  toJson() {
    return {'lat': lat, 'long': long, 'img': imageUrl, 'address': address, 'dateTime':dateTime.toString()};
  }
}
