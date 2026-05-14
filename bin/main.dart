// bin/main.dart
// ─────────────────────────────────────────────────────────────────────
// CLI Calculator — updated to meet all assignment requirements:
//   ✅ Input validation via readNumber()
//   ✅ No switch statements (uses if/else if chains)
//   ✅ [INFO] / [ERROR] output format
//   ✅ Keeps asking until a valid menu choice is entered
//   ✅ Repeat last calculation feature
//   ✅ Modulus, Power, Average, History, Clear History
// ─────────────────────────────────────────────────────────────────────

import 'dart:io';
import '../lib/calculator.dart';

// ── Output Helpers ────────────────────────────────────────────────────
// Requirement #6: Use [INFO] and [ERROR] tags for all output

void info(String message) {
  print('  [INFO] $message');
}

void error(String message) {
  print('  [ERROR] $message');
}

// ── Screen Helpers ────────────────────────────────────────────────────

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
  ┌──────────────────────────────────────────────┐
  │  1 ▸  Basic Calculator  (+ - * / ^ % √)     │
  │  2 ▸  Expression Mode   (e.g. 3+4*2)        │
  │  3 ▸  Average Calculator                     │
  │  4 ▸  Repeat Last Calculation                │
  │  5 ▸  View History                           │
  │  6 ▸  Clear History                          │
  │  7 ▸  Exit                                   │
  └──────────────────────────────────────────────┘''');
}

// ── Requirement #2: Reusable readNumber function ──────────────────────
// Takes a prompt message, keeps asking until the user types a valid number.
// Returns a double.
//
// Why double? Because doubles handle both whole numbers (10) and decimals
// (3.14), making the calculator more flexible than using int.
//
// Why is stdin.readLineSync() nullable?
// Because stdin can theoretically return null if the stream closes
// (e.g. piped input that ends). The ?. and ?? handle this safely.

double readNumber(String message) {
  while (true) {
    stdout.write('  $message');

    // stdin.readLineSync() is nullable — use ?. to safely call trim()
    // and ?? '' as a fallback if it returns null
    final input = stdin.readLineSync()?.trim() ?? '';

    // double.tryParse returns null if input is not a valid number
    // This is input validation — requirement #1
    final value = double.tryParse(input);

    if (value != null) {
      return value; // valid number — exit the loop
    }

    // If we reach here, input was invalid
    error('Invalid input. Please enter a number.\n');

    // Why continue? It skips the rest of the loop body and goes back
    // to the top — keeps asking without exiting the while loop.
    continue;
  }
}

// ── Requirement #7: Valid menu choice loop ────────────────────────────
// Keeps asking until the user enters 1–7. No switch used.

String readMenuChoice() {
  final validChoices = ['1', '2', '3', '4', '5', '6', '7'];

  while (true) {
    stdout.write('\n  Enter choice: ');
    final choice = stdin.readLineSync()?.trim() ?? '';

    if (validChoices.contains(choice)) {
      return choice; // valid — exit loop
    }

    error('Invalid choice. Please enter a number between 1 and 7.\n');
  }
}

// ── Mode Functions ────────────────────────────────────────────────────

String runBasicMode(Calculator calc) {
  print('\n  ── Basic Calculator ──────────────────────');
  print('  Operators: + - * / ^ % s(√)\n');

  final a = readNumber('Enter first number (A): ');
  stdout.write('  Enter operator (+, -, *, /, ^, %, s): ');
  final op = stdin.readLineSync()?.trim() ?? '';

  double result;
  String expression;

  // Requirement #8: No switch — using if/else if instead
  if (op == 's') {
    result = calc.squareRoot(a);
    expression = '√$a = $result';
  } else if (op == '+') {
    final b = readNumber('Enter second number (B): ');
    result = calc.add(a, b);
    expression = '$a + $b = $result';
  } else if (op == '-') {
    final b = readNumber('Enter second number (B): ');
    result = calc.subtract(a, b);
    expression = '$a - $b = $result';
  } else if (op == '*') {
    final b = readNumber('Enter second number (B): ');
    result = calc.multiply(a, b);
    expression = '$a * $b = $result';
  } else if (op == '/') {
    final b = readNumber('Enter second number (B): ');
    result = calc.divide(a, b);
    expression = '$a / $b = $result';
  } else if (op == '^') {
    final b = readNumber('Enter second number (B): ');
    result = calc.power(a, b);
    expression = '$a ^ $b = $result';
  } else if (op == '%') {
    final b = readNumber('Enter second number (B): ');
    result = calc.modulo(a, b);
    expression = '$a % $b = $result';
  } else {
    error('Unknown operator: $op\n');
    return '';
  }

  // Requirement #6: [INFO] format
  info('Result = $result\n');
  calc.addToHistory(expression);
  return expression;
}

String runExpressionMode(Calculator calc) {
  print('\n  ── Expression Mode ───────────────────────');
  print('  Examples: 3 + 4 * 2    (10 + 5) / 3    2^8\n');

  stdout.write('  Expression: ');
  final expr = stdin.readLineSync()?.trim() ?? '';
  if (expr.isEmpty) return '';

  try {
    final result = calc.evaluate(expr);
    info('$expr = $result\n');
    calc.addToHistory('$expr = $result');
    return '$expr = $result';
  } catch (e) {
    error('$e\n');
    return '';
  }
}

String runAverageMode(Calculator calc) {
  print('\n  ── Average Calculator ────────────────────');
  print('  Enter numbers one by one. Type "done" when finished.\n');

  final List<double> numbers = [];

  while (true) {
    stdout.write('  Enter number (or "done"): ');
    final input = stdin.readLineSync()?.trim() ?? '';

    // break exits the loop entirely — we're done collecting numbers
    if (input.toLowerCase() == 'done') break;

    final value = double.tryParse(input);
    if (value != null) {
      numbers.add(value);
      info('Added. Numbers so far: $numbers\n');
    } else {
      error('Invalid number, try again.\n');
    }
  }

  if (numbers.isEmpty) {
    error('No numbers entered.\n');
    return '';
  }

  final result = calc.average(numbers);
  info('Average of $numbers = $result\n');

  final expression = 'Average$numbers = $result';
  calc.addToHistory(expression);
  return expression;
}

// ── Main ──────────────────────────────────────────────────────────────

void main() {
  final calculator = Calculator();

  // Requirement #9: Track the last calculation as a string
  String lastCalculation = '';

  clearScreen();
  printBanner();

  // Main event loop
  while (true) {
    printMenu();

    // Requirement #7: keeps asking until valid choice entered
    final choice = readMenuChoice();
    print('');

    String result = '';

    // Requirement #8: No switch — using if/else if
    if (choice == '1') {
      try {
        result = runBasicMode(calculator);
      } catch (e) {
        error('$e\n');
      }
    } else if (choice == '2') {
      result = runExpressionMode(calculator);
    } else if (choice == '3') {
      try {
        result = runAverageMode(calculator);
      } catch (e) {
        error('$e\n');
      }
    } else if (choice == '4') {
      // Requirement #9: Repeat last calculation
      if (lastCalculation.isEmpty) {
        info('No previous calculation to repeat.\n');
      } else {
        info('Last calculation: $lastCalculation\n');
      }
    } else if (choice == '5') {
      calculator.showHistory();
    } else if (choice == '6') {
      calculator.clearHistory();
    } else if (choice == '7') {
      info('Goodbye!\n');
      exit(0);
    }

    // Save non-empty results as the last calculation
    if (result.isNotEmpty) {
      lastCalculation = result;
    }

    stdout.write('  Press Enter to continue...');
    stdin.readLineSync();
    clearScreen();
    printBanner();
  }
}