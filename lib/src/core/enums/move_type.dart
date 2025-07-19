enum MoveType { PEQUENA, MEDIANA, GRANDE }

extension MoveTypeExtension on MoveType {
  String get label {
    switch (this) {
      case MoveType.PEQUENA:
        return 'Pequeña';
      case MoveType.MEDIANA:
        return 'Mediana';
      case MoveType.GRANDE:
        return 'Grande';
    }
  }

  String get value => name; 
}
