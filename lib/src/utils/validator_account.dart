class Validators {
  static String? validateNotEmpty(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo no puede estar vacio';
    }

    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo no puede estar vacio';
    }

    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}\$');
    if (!emailRegex.hasMatch(value)) {
      return 'Por favor ingresa un email valido';
    }
    return null;
  }

  /// Valida que la contraseña cumpla con ciertos requisitos.
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, ingresa una contraseña';
    }

    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }

    return null;
  }

  /// Valida nombres o textos genéricos.
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor, ingresa un nombre';
    }

    if (value.trim().length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }

    return null;
  }
}
