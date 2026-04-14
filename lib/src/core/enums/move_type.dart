enum MoveType { PEQUENA, MEDIANA}

extension MoveTypeExtension on MoveType {
  String get label {
    switch (this) {
      case MoveType.PEQUENA:
        return 'Pequeña';
      case MoveType.MEDIANA:
        return 'Mediana';
    }
  }

  String get value => name; 
}
