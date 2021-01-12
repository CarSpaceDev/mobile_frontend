class Lot {
  String lotId;
  String partnerId;
  List<String> lotImage;
  LotAddress address;
  double pricing;
  int parkingType;
  int vehicleTypeAccepted;
  bool isActive;
  int rating;
  int numberOfRatings;
  int availableFrom;
  int availableTo;
  List<int> availableDays;
  int availableSlots;
  int capacity;
  bool disabled;

  Lot.fromJson(Map<String, dynamic> json)
      : lotId = json["lotId"] as String,
        partnerId = json["partnerId"] as String,
        lotImage = List<String>.from(json["lotImage"]),
        address = LotAddress.fromJson(json["address"]),
        pricing = double.parse(int.parse(json["pricing"]).toString()),
        parkingType = json["parkingType"] as int,
        vehicleTypeAccepted = json["vehicleTypeAccepted"] as int,
        isActive = json["isActive"] as bool,
        rating = json["rating"] as int,
        numberOfRatings = json["numberOfRatings"] as int,
        availableFrom = int.parse(json["availableFrom"]),
        availableTo = int.parse(json["availableTo"]),
        availableDays = List<int>.from(json["availableDays"]),
        availableSlots = json["availableSlots"] as int,
        capacity = json["capacity"] as int,
        disabled = json["disabled"] as bool;
}

class LotAddress {
  String houseAndStreet;
  String brgy;
  String municipality;
  String city;
  String province;
  String country;
  int zipCode;

  LotAddress.fromJson(Map<String, dynamic> json)
      : houseAndStreet = json["houseAndStreet"] as String,
        brgy = json["brgy"] as String,
        municipality = json["municipality"] as String,
        city = json["city"] as String,
        province = json["province"] as String,
        country = json["country"] as String,
        zipCode = int.parse(json["zipCode"]);
}
