import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(MathQuizApp());
}

class MathQuizApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Matemática para crianças',
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: Colors.deepOrange,
          secondary: Colors.amber,
        ),
        scaffoldBackgroundColor: Colors.lightBlueAccent.shade100,
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(color: Colors.white, fontSize: 18),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orangeAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            padding: EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Matemática para crianças', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepOrange,
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            MathOptionButton('Addition', Icons.add, Colors.amber, () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => QuizSettingsPage(operation: 'Addition')));
            }),
            MathOptionButton('Subtraction', Icons.remove, Colors.lightGreen, () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => QuizSettingsPage(operation: 'Subtraction')));
            }),
            MathOptionButton('Multiplication', Icons.clear, Colors.lightBlue, () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => QuizSettingsPage(operation: 'Multiplication')));
            }),
            MathOptionButton('Division', Icons.horizontal_rule, Colors.pinkAccent, () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => QuizSettingsPage(operation: 'Division')));
            }),
          ],
        ),
      ),
    );
  }
}

class MathOptionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  MathOptionButton(this.label, this.icon, this.color, this.onPressed);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      onPressed: onPressed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 50, color: Colors.white),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class QuizSettingsPage extends StatefulWidget {
  final String operation;

  QuizSettingsPage({required this.operation});

  @override
  _QuizSettingsPageState createState() => _QuizSettingsPageState();
}

class _QuizSettingsPageState extends State<QuizSettingsPage> {
  final _questionsController = TextEditingController();
  final _startValueController = TextEditingController();
  final _endValueController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.operation} Quiz Settings', style: TextStyle(fontSize: 24)),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField('Quantas questões?', _questionsController),
            _buildTextField('Valor inicial', _startValueController),
            _buildTextField('Valor final', _endValueController),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _generateQuiz,
              child: Text('Gerar as perguntas'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          fillColor: Colors.amber,
          filled: true,
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }

  void _generateQuiz() {
    final int numberOfQuestions = int.tryParse(_questionsController.text) ?? 5;
    final int startValue = int.tryParse(_startValueController.text) ?? 1;
    final int endValue = int.tryParse(_endValueController.text) ?? 10;

    List<Map<String, dynamic>> questions = [];

    for (int i = 0; i < numberOfQuestions; i++) {
      int num1 = Random().nextInt(endValue - startValue + 1) + startValue;
      int num2 = Random().nextInt(endValue - startValue + 1) + startValue;
      int correctAnswer = 0;
      String questionText = '';
      List<int> options = [];

      switch (widget.operation) {
        case 'Addition':
          correctAnswer = num1 + num2;
          questionText = '$num1 + $num2';
          break;
        case 'Subtraction':
          correctAnswer = num1 - num2;
          questionText = '$num1 - $num2';
          break;
        case 'Multiplication':
          correctAnswer = num1 * num2;
          questionText = '$num1 × $num2';
          break;
        case 'Division':
          num1 = num2 * Random().nextInt(10) + 1;
          correctAnswer = num1 ~/ num2;
          questionText = '$num1 ÷ $num2';
          break;
      }

      while (options.length < 3) {
        int wrongAnswer = Random().nextInt(20) + (startValue * 2);
        if (wrongAnswer != correctAnswer && !options.contains(wrongAnswer)) {
          options.add(wrongAnswer);
        }
      }

      options.add(correctAnswer);
      options.shuffle();

      questions.add({'question': questionText, 'options': options, 'answer': correctAnswer});
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizPage(questions: questions),
      ),
    );
  }
}

class QuizPage extends StatefulWidget {
  final List<Map<String, dynamic>> questions;

  QuizPage({required this.questions});

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int _currentQuestionIndex = 0;
  int _correctAnswers = 0;

  void _answerQuestion(int selectedOption) {
    final question = widget.questions[_currentQuestionIndex];
    bool isCorrect = question['options'][selectedOption] == question['answer'];
    if (isCorrect) {
      _correctAnswers++;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isCorrect ? 'Acertou!' : 'Errou!'),
        duration: Duration(seconds: 1),
      ),
    );

    if (_currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      Future.delayed(Duration(seconds: 1), _showResults);
    }
  }

  void _showResults() {
    double percentage = (_correctAnswers / widget.questions.length) * 100;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Resultado das perguntas',
            style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Respostas corretas: $_correctAnswers\nPorcentagem: ${percentage.toStringAsFixed(2)}%',
            style: TextStyle(fontSize: 18, color: Colors.black),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text('Fechar', style: TextStyle(color: Colors.deepOrange)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('perguntas', style: TextStyle(fontSize: 24)),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              question['question'],
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepOrangeAccent),
            ),
            SizedBox(height: 20),
            ...List.generate(question['options'].length, (optionIndex) {
              return GestureDetector(
                onTap: () => _answerQuestion(optionIndex),
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.deepOrange,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${question['options'][optionIndex]}',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
