enum StatusOfTheMove {
  // ignore: constant_identifier_names
  DRIVER_ARRIVED,
  // ignore: constant_identifier_names
  MOVING_STARTED, 
  // ignore: constant_identifier_names
  MOVE_COMPLETE,

  // ignore: constant_identifier_names
  MOVE_FINISHED,

}

extension MoveTypeExtension on StatusOfTheMove {
  String get label {
    switch (this) {
      case StatusOfTheMove.DRIVER_ARRIVED:
        return 'Pequeña';
      case StatusOfTheMove.MOVING_STARTED:
        return 'Mediana';
      case StatusOfTheMove.MOVE_COMPLETE:
        return 'Completada';
        case StatusOfTheMove.MOVE_FINISHED:
        return 'Completada';
    }
  }

  String get value => name;
}
