import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Calculator',
      theme: ThemeData.dark(),
      home: const CalculatorHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CalculatorHome extends StatefulWidget {
  const CalculatorHome({super.key});

  @override
  State<CalculatorHome> createState() => _CalculatorHomeState();
}

class _CalculatorHomeState extends State<CalculatorHome> {
  String _input = '';
  String _result = '';

  void _append(String value) {
    setState(() {
      if ('+-*/'.contains(value)) {
        if (_input.isEmpty || '+-*/'.contains(_input[_input.length - 1])) {
          return; // ignore duplicate or starting with operator
        }
      }
      _input += value;
    });
  }

  void _clear() {
    setState(() {
      _input = '';
      _result = '';
    });
  }

  void _calculate() {
    try {
      final exp = _input.replaceAll('×', '*').replaceAll('÷', '/');
      final result = _evaluate(exp);
      setState(() {
        _result = '=$_input = $result';
        _input = result;
      });
    } catch (_) {
      setState(() {
        _result = 'Error';
      });
    }
  }

  String _evaluate(String expr) {
    expr = expr.replaceAll('×', '*').replaceAll('÷', '/');

    // Tokenize using a smarter loop (not just RegExp)
    List<String> tokens = [];
    String numBuffer = '';
    for (int i = 0; i < expr.length; i++) {
      String ch = expr[i];

      if ('0123456789.'.contains(ch)) {
        numBuffer += ch;
      } else if ('+-*/'.contains(ch)) {
        // Handle unary minus (e.g., 5*-2 or -3+2)
        if (ch == '-' && (i == 0 || '+-*/'.contains(expr[i - 1]))) {
          numBuffer = '-';
        } else {
          if (numBuffer.isNotEmpty) tokens.add(numBuffer);
          tokens.add(ch);
          numBuffer = '';
        }
      }
    }

    if (numBuffer.isNotEmpty) tokens.add(numBuffer);

    // Convert to postfix
    List<String> output = [];
    List<String> ops = [];

    int precedence(String op) => {'+': 1, '-': 1, '*': 2, '/': 2}[op] ?? 0;

    for (final token in tokens) {
      if (double.tryParse(token) != null) {
        output.add(token);
      } else {
        while (ops.isNotEmpty && precedence(ops.last) >= precedence(token)) {
          output.add(ops.removeLast());
        }
        ops.add(token);
      }
    }

    while (ops.isNotEmpty) {
      output.add(ops.removeLast());
    }

    // Evaluate postfix
    List<double> stack = [];
    for (final token in output) {
      if (double.tryParse(token) != null) {
        stack.add(double.parse(token));
      } else {
        final b = stack.removeLast();
        final a = stack.removeLast();
        switch (token) {
          case '+': stack.add(a + b); break;
          case '-': stack.add(a - b); break;
          case '*': stack.add(a * b); break;
          case '/': stack.add(a / b); break;
        }
      }
    }

    double result = stack.single;
    return result == result.toInt() ? result.toInt().toString() : result.toString();
  }


  Widget _buildButton(String text, {Color? color}) {
    return ElevatedButton(
      onPressed: () {
        if (text == '=') {
          _calculate();
        } else if (text == 'C') {
          _clear();
        } else {
          _append(text);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? Colors.grey[800],
        padding: const EdgeInsets.all(20),
      ),
      child: Text(text, style: const TextStyle(fontSize: 24)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final buttons = [
      ['7', '8', '9', '÷'],
      ['4', '5', '6', '×'],
      ['1', '2', '3', '-'],
      ['C', '0', '=', '+'],
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Calculator')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  _input,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
            Text(
              _result,
              style: const TextStyle(fontSize: 20, color: Colors.greenAccent),
            ),
            const SizedBox(height: 20),
            ...buttons.map((row) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row.map((text) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: _buildButton(text, color: '0123456789'.contains(text) ? Colors.grey[700] : null),
                ),
              )).toList(),
            )),
          ],
        ),
      ),
    );
  }
}
