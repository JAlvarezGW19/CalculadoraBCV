import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  final int maxIntegerDigits;
  final int maxDecimalDigits;

  CurrencyInputFormatter({
    this.maxIntegerDigits = 15,
    this.maxDecimalDigits = 2,
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    try {
      String newText = newValue.text;
      int selectionIndex = newValue.selection.baseOffset;

      // 1. Detect if user explicitly typed a dot (intended as decimal)
      if (selectionIndex > 0 &&
          selectionIndex <= newText.length &&
          newText[selectionIndex - 1] == '.') {
        newText = newText.replaceRange(selectionIndex - 1, selectionIndex, ',');
      }

      // 2. Remove all existing dots (thousands separators)
      newText = newText.replaceAll('.', '');

      // 3. Validate structure (prevent multiple commas)
      List<String> parts = newText.split(',');
      if (parts.length > 2) {
        return oldValue;
      }

      String integerPart = parts[0].replaceAll(RegExp(r'[^0-9]'), '');
      String? decimalPart = parts.length > 1 ? parts[1] : null;

      // Check Limits
      if (integerPart.length > maxIntegerDigits) {
        return oldValue;
      }
      if (decimalPart != null && decimalPart.length > maxDecimalDigits) {
        return oldValue;
      }

      // 4. Format Integer Part using es_VE locale (dots for thousands)
      final formatter = NumberFormat("#,###", "es_VE");
      String formattedInteger;

      if (integerPart.isEmpty) {
        if (decimalPart != null) {
          formattedInteger = "0";
        } else {
          formattedInteger = "";
        }
      } else {
        try {
          // Use BigInt logic if needed, but NumberFormat doesn't support BigInt well in standard intl.
          // Try parse as int. If it overflows (too large), fallback to raw string (no dots).
          // Or strictly limit length?
          // Let's fallback to unformatted if too huge to avoid crash.
          final value = int.parse(integerPart);
          formattedInteger = formatter.format(value);
        } catch (e) {
          // Fallback: don't format if invalid (e.g. overflow)
          formattedInteger = integerPart;
        }
      }

      // 5. Build Final String
      String finalString = formattedInteger;
      if (decimalPart != null) {
        finalString += ',$decimalPart';
      } else if (newText.contains(',')) {
        finalString += ',';
      }

      // 6. Calculate New Cursor Position
      // Logic same as before...
      String userIntentRaw = newValue.text;
      if (selectionIndex > 0 &&
          selectionIndex <= userIntentRaw.length &&
          userIntentRaw[selectionIndex - 1] == '.') {
        userIntentRaw = userIntentRaw.replaceRange(
          selectionIndex - 1,
          selectionIndex,
          ',',
        );
      }

      int meaningfulCharsBeforeCursor = 0;
      for (int i = 0; i < selectionIndex && i < userIntentRaw.length; i++) {
        if ("0123456789,".contains(userIntentRaw[i])) {
          meaningfulCharsBeforeCursor++;
        }
      }

      int newCursorPos = 0;
      int meaningfulCharsFound = 0;
      for (int i = 0; i < finalString.length; i++) {
        if ("0123456789,".contains(finalString[i])) {
          meaningfulCharsFound++;
        }
        if (meaningfulCharsFound >= meaningfulCharsBeforeCursor) {
          newCursorPos = i + 1;
          break;
        }
      }

      // Edge case constraints
      if (newCursorPos > finalString.length) newCursorPos = finalString.length;
      if (meaningfulCharsBeforeCursor == 0) newCursorPos = 0;
      if (meaningfulCharsFound < meaningfulCharsBeforeCursor) {
        newCursorPos = finalString.length;
      }

      return TextEditingValue(
        text: finalString,
        selection: TextSelection.collapsed(offset: newCursorPos),
      );
    } catch (e) {
      // Emergency fallback to prevent crash
      return newValue;
    }
  }
}
