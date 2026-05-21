enum MoveType { XPRESS, MEDIANA, GRANDE}

extension MoveTypeExtension on MoveType {
  String get label {
    switch (this) {
      case MoveType.XPRESS:
        return 'Xpress';
      case MoveType.MEDIANA:
        return 'Mediana';
         case MoveType.GRANDE:
        return 'Grande';
    }
  }

  String get value => name; 
}
