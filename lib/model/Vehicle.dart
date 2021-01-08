class Vehicle {
  String plateNumber;
  // ignore: non_constant_identifier_names
  String CR;
  List<dynamic> currentUsers;
  String ownerId;
  String vehicleImage;
  String make;
  String model;
  int type;
  String color;
  bool isVerified;
  // ignore: non_constant_identifier_names
  String OR;

  Vehicle.fromJson(Map<String, dynamic> json)
      : plateNumber = json['plateNumber'] as String,
        vehicleImage = json['vehicleImage'] as String,
        CR = json['CR'] as String,
        OR = json['OR'] as String,
        ownerId = json['ownerId'] as String,
        make = json['make'] as String,
        model = json['model'] as String,
        type = json['type'] as int,
        color = json['color'] as String,
        isVerified = json['isVerified'] as bool,
        currentUsers = json['currentUsers'] as List<dynamic>;

  toJson() {
    return {
      "plateNumber": this.plateNumber,
      "vehicleImage": this.vehicleImage,
      "OR": this.OR,
      "CR": this.CR,
      "ownerId": this.ownerId,
      "make": this.make,
      "model": this.model,
      "type": this.type,
      "color": this.color,
      "isVerified": this.isVerified,
      "currentUsers": this.currentUsers
    };
  }
}
