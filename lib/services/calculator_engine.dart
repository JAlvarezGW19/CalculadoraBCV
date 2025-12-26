// ignore_for_file: deprecated_member_use
import 'package:math_expressions/math_expressions.dart';

class CalculatorEngine {
  static double evaluate(String expression) {
    if (expression.isEmpty) return 0.0;

    // Replace visual operators with math operators
    String finalExpression = expression
        .replaceAll('x', '*')
        .replaceAll('÷', '/');

    try {
      Parser p = ShuntingYardParser();
      Expression exp = p.parse(finalExpression);
      ContextModel cm = ContextModel();
      return exp.evaluate(EvaluationType.REAL, cm);
    } catch (e) {
      // Re-throw or return NaN/0
      // For safe UI, maybe return NaN
      return double.nan;
    }
  }

  static bool isOperator(String key) {
    return key == '+' || key == '-' || key == '*' || key == '/';
  }

  static String formatResult(double value) {
    String resultStr = value.toString();
    if (resultStr.endsWith(".0")) {
      resultStr = resultStr.substring(0, resultStr.length - 2);
    }
    return resultStr;
  }
}
