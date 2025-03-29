class CalculatePriceModel {
  String? typeOfMove;
  String? numberOfRooms;
  String? originAddress;
  String? destinationAddress;
  String? originLat;
  String? originLng;
  String? destinationLat;
  String? destinationLng;
  String? selectedOption;

  CalculatePriceModel(
      {this.typeOfMove,
      this.numberOfRooms,
      this.originAddress,
      this.destinationAddress,
      this.originLat,
      this.originLng,
      this.destinationLat,
      this.destinationLng,
      this.selectedOption});

  factory CalculatePriceModel.fromMap(Map<String, dynamic> map) {
    return CalculatePriceModel(
        typeOfMove: map['typeOfMove'],
        numberOfRooms: map['numberOfRooms'],
        originAddress: map['originAddress'],
        destinationAddress: map['destinationAddress'],
        originLat: map['originLat'],
        originLng: map['originLng'],
        destinationLat: map['destinationLat'],
        destinationLng: map['destinationLng'],
        selectedOption: map['selectedOption']);
  }

  Map<String, dynamic> toMap() {
    return {
      'typeOfMove': typeOfMove,
      'numberOfRooms': numberOfRooms,
      'originAddress': originAddress,
      'destinationAddress': destinationAddress,
      'originLat': originLat,
      'originLng': originLng,
      'destinationLat': destinationLat,
      'destinationLng': destinationLng,
      'selectedOption': selectedOption
    };
  }

  CalculatePriceModel copyWith(
      {String? typeOfMove,
      String? numberOfRooms,
      String? originAddress,
      String? destinationAddress,
      String? originLat,
      String? originLng,
      String? destinationLat,
      String? destinationLng,
      String? selectdedOption}) {
    return CalculatePriceModel(
        typeOfMove: typeOfMove ?? this.typeOfMove,
        numberOfRooms: numberOfRooms ?? this.numberOfRooms,
        originAddress: originAddress ?? this.originAddress,
        destinationAddress: destinationAddress ?? this.destinationAddress,
        originLat: originLat ?? this.originLat,
        originLng: originLng ?? this.originLng,
        destinationLat: destinationLat ?? this.destinationLat,
        destinationLng: destinationLng ?? this.destinationLng,
        selectedOption: selectdedOption ?? selectedOption);
  }
}
