import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class CalculatorKeypad extends StatelessWidget {
  final Function(String) onKeyPressed;

  const CalculatorKeypad({super.key, required this.onKeyPressed});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: _buildKeyRow(['C', '÷', '×', '⌫'])),
        Expanded(child: _buildKeyRow(['7', '8', '9', '-'])),
        Expanded(child: _buildKeyRow(['4', '5', '6', '+'])),
        Expanded(child: _buildKeyRow(['1', '2', '3', '='])),
        Expanded(child: _buildKeyRow(['', '0', ',', ''])), // 0 aligned under 2
      ],
    );
  }

  Widget _buildKeyRow(List<String> keys) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: keys.map((key) {
        if (key.isEmpty) {
          return const Expanded(child: SizedBox.shrink());
        }

        bool isAction = ['C', '⌫'].contains(key);
        bool isOperator = ['÷', '×', '-', '+', '='].contains(key);

        Color bgColor = Colors.transparent;
        Color textColor = Colors.white;

        if (isAction) {
          textColor = Colors.orangeAccent;
        } else if (isOperator) {
          bgColor = AppTheme.cardBackground;
          textColor = AppTheme.textAccent;
          if (key == '=') {
            bgColor = AppTheme.textAccent;
            textColor = Colors.white;
          }
        }

        // Map display symbols to internal logic
        String val = key;
        if (key == '÷') val = '/';
        if (key == '×') val = '*';

        return Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Material(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => onKeyPressed(val),
                child: Center(
                  child: isAction && key == '⌫'
                      ? const Icon(
                          Icons.backspace_outlined,
                          color: Colors.orangeAccent,
                        )
                      : Text(
                          key,
                          style: GoogleFonts.montserrat(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
