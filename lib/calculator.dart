import 'dart:math';

class Calculator {
  final List<String> history = [];

  double add(double a, double b) => a + b;
  double subtract(double a, double b) => a - b;
  double multiply(double a, double b) => a * b;

  double divide(double a, double b) {
    if (b == 0) throw ArgumentError('Cannot divide by zero!');
    return a / b;
  }

  double power(double base, double exponent) => pow(base, exponent).toDouble();

  double squareRoot(double n) {
    if (n < 0) throw ArgumentError('Cannot square root a negative number!');
    return sqrt(n);
  }

  double modulo(double a, double b) {
    if (b == 0) throw ArgumentError('Cannot modulo by zero!');
    return a % b;
  }

  double evaluate(String expression) {
    final expr = expression.replaceAll(' ', '');
    int depth = 0;

    for (int i = expr.length - 1; i >= 0; i--) {
      if (expr[i] == ')') depth++;
      if (expr[i] == '(') depth--;
      if (depth != 0) continue;
      if ((expr[i] == '+' || expr[i] == '-') && i > 0) {
        final left = evaluate(expr.substring(0, i));
        final right = evaluate(expr.substring(i + 1));
        return expr[i] == '+' ? left + right : left - right;
      }
    }

    depth = 0;
    for (int i = expr.length - 1; i >= 0; i--) {
      if (expr[i] == ')') depth++;
      if (expr[i] == '(') depth--;
      if (depth != 0) continue;
      if ((expr[i] == '*' || expr[i] == '/' || expr[i] == '%') && i > 0) {
        final left = evaluate(expr.substring(0, i));
        final right = evaluate(expr.substring(i + 1));
        if (expr[i] == '*') return left * right;
        if (expr[i] == '/') return divide(left, right);
        return modulo(left, right);
      }
    }

    if (expr.contains('^')) {
      final parts = expr.split('^');
      return power(double.parse(parts[0]), double.parse(parts[1]));
    }

    if (expr.startsWith('(') && expr.endsWith(')')) {
      return evaluate(expr.substring(1, expr.length - 1));
    }

    return double.parse(expr);
  }

  void addToHistory(String entry) {
    history.add(entry);
    if (history.length > 20) history.removeAt(0);
  }

  void showHistory() {
    if (history.isEmpty) {
      print('\n  No history yet.\n');
      return;
    }
    print('\n  Calculation History:');
    for (int i = 0; i < history.length; i++) {
      print('  ${i + 1}. ${history[i]}');
    }
    print('');
  }

  void clearHistory() {
    history.clear();
    print('  History cleared.\n');
  }
}