enum ConnectionStatus {
  CONNECTED('CONNECTED'),
  DISCONNECTED('DISCONNECTED'),
  BUSY('BUSY');

  final String value;


  const ConnectionStatus(this.value);

  factory ConnectionStatus.fromString(String value) { 

    return values.firstWhere((e) => e.value == value.toUpperCase(), orElse: () => throw ArgumentError('Invalid ConnectionStatus: $value'));
  }

  @override
  String toString() => value;

  bool get isConnected => this == ConnectionStatus.CONNECTED;
  bool get isOnTrip => this == ConnectionStatus.DISCONNECTED;
  bool get isAvailable => this == ConnectionStatus.BUSY;
}
