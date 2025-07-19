import 'package:holi/src/core/enums/move_type.dart';

extension MoveTypeExtension on MoveType {
  String get displayName {
    switch (this) {
      case MoveType.PEQUENA:
        return "Pequeña";
      case MoveType.MEDIANA:
        return "Mediana";
      case MoveType.GRANDE:
        return "Grande";
    }
  }
}
