
import 'dart:io';
import '../lib/calculator.dart';

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

double readNumber(String message) {
  while (true) {
    stdout.write('  $message');

 
    final input = stdin.readLineSync()?.trim() ?? '';

    final value = double.tryParse(input);

    if (value != null) {
      return value;
    }

   
    error('Invalid input. Please enter a number.\n');


    continue;
  }
}

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


String runBasicMode(Calculator calc) {
  print('\n  ── Basic Calculator ──────────────────────');
  print('  Operators: + - * / ^ % s(√)\n');

  final a = readNumber('Enter first number (A): ');
  stdout.write('  Enter operator (+, -, *, /, ^, %, s): ');
  final op = stdin.readLineSync()?.trim() ?? '';

  double result;
  String expression;


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