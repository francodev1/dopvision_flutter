import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Formata telefone brasileiro (XX) XXXXX-XXXX
class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }
    
    final buffer = StringBuffer();
    
    if (text.isNotEmpty) {
      buffer.write('(');
      buffer.write(text.substring(0, text.length >= 2 ? 2 : text.length));
    }
    
    if (text.length >= 3) {
      buffer.write(') ');
      if (text.length <= 6) {
        buffer.write(text.substring(2));
      } else {
        buffer.write(text.substring(2, text.length >= 7 ? 7 : text.length));
        if (text.length >= 7) {
          buffer.write('-');
          buffer.write(text.substring(7, text.length >= 11 ? 11 : text.length));
        }
      }
    }
    
    final formatted = buffer.toString();
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Formata valores monetários em Real (R$)
class CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Remove tudo exceto dígitos
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digitsOnly.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Converte para double (centavos)
    final value = double.parse(digitsOnly) / 100;
    
    // Formata
    final formatted = _formatter.format(value);
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Formata email (lowercase automático)
class EmailInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(
      text: newValue.text.toLowerCase().trim(),
      selection: newValue.selection,
    );
  }
}

/// Extrai apenas dígitos de um telefone formatado
String extractPhoneDigits(String phone) {
  return phone.replaceAll(RegExp(r'[^\d]'), '');
}

/// Extrai valor numérico de um valor monetário formatado
double? extractCurrencyValue(String formatted) {
  final digitsOnly = formatted.replaceAll(RegExp(r'[^\d]'), '');
  if (digitsOnly.isEmpty) return null;
  return double.parse(digitsOnly) / 100;
}
