import 'dart:io';
import '../lib/calculator.dart';

void clearScreen() {
  stdout.write('\x1B[2J\x1B[0;0H');
}

void printBanner() {
  print('''
╔══════════════════════════════════════════════╗
║          🧮  DART CLI CALCULATOR             ║
╚══════════════════════════════════════════════╝
  ''');
}

void printMenu() {
  print('''
  ┌─────────────────────────────────────────┐
  │  1 ▸  Basic Calculator (+ - * / ^ %)   │
  │  2 ▸  Expression Mode  (e.g. 3+4*2)    │
  │  3 ▸  View History                      │
  │  4 ▸  Clear History                     │
  │  5 ▸  Exit                              │
  └─────────────────────────────────────────┘
  Enter choice: ''');
}

double readDouble(String prompt) {
  while (true) {
    stdout.write('  $prompt');
    final input = stdin.readLineSync()?.trim() ?? '';
    final value = double.tryParse(input);
    if (value != null) return value;
    print('  ⚠️  Please enter a valid number.\n');
  }
}

void runBasicMode(Calculator calc) {
  print('\n  ── Basic Calculator ──────────────────────');

  final a = readDouble('Enter first number (A): ');
  stdout.write('  Enter operator (+, -, *, /, ^, %, s for √): ');
  final op = stdin.readLineSync()?.trim() ?? '';

  double result;
  String expression;

  if (op == 's') {
    result = calc.squareRoot(a);
    expression = '√$a = $result';
  } else {
    final b = readDouble('Enter second number (B): ');
    switch (op) {
      case '+': result = calc.add(a, b);
      case '-': result = calc.subtract(a, b);
      case '*': result = calc.multiply(a, b);
      case '/': result = calc.divide(a, b);
      case '^': result = calc.power(a, b);
      case '%': result = calc.modulo(a, b);
      default:
        print('  ❌ Unknown operator: $op\n');
        return;
    }
    expression = '$a $op $b = $result';
  }

  print('\n  ✅ Result: $result\n');
  calc.addToHistory(expression);
}

void runExpressionMode(Calculator calc) {
  print('\n  ── Expression Mode ───────────────────────');
  stdout.write('  Expression: ');
  final expr = stdin.readLineSync()?.trim() ?? '';
  if (expr.isEmpty) return;

  try {
    final result = calc.evaluate(expr);
    print('\n  ✅ $expr = $result\n');
    calc.addToHistory('$expr = $result');
  } catch (e) {
    print('\n  ❌ Error: $e\n');
  }
}

void main() {
  final calculator = Calculator();
  clearScreen();
  printBanner();

  while (true) {
    printMenu();
    final choice = stdin.readLineSync()?.trim() ?? '';
    print('');

    switch (choice) {
      case '1':
        try { runBasicMode(calculator); } catch (e) { print('  ❌ $e\n'); }
      case '2':
        runExpressionMode(calculator);
      case '3':
        calculator.showHistory();
      case '4':
        calculator.clearHistory();
      case '5':
        print('  👋 Goodbye!\n');
        exit(0);
      default:
        print('  ⚠️  Invalid choice. Enter 1–5.\n');
    }

    stdout.write('  Press Enter to continue...');
    stdin.readLineSync();
    clearScreen();
    printBanner();
  }
}