import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => QuizState(),
      child: MathQuizApp(),
    ),
  );
}

class MathQuizApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<QuizState>().isDarkMode;

    return MaterialApp(
      title: 'Matemática para crianças',
      theme: isDarkMode ? _buildDarkTheme() : _buildLightTheme(),
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
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
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      colorScheme: ColorScheme.dark(
        primary: Colors.deepOrange,
        secondary: Colors.amber,
      ),
      scaffoldBackgroundColor: Colors.black87,
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        bodyMedium: TextStyle(color: Colors.white70, fontSize: 18),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orangeAccent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}

class QuizState with ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('darkMode', _isDarkMode);
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
        actions: [
          IconButton(
            icon: Icon(context.watch<QuizState>().isDarkMode ? Icons.dark_mode : Icons.light_mode),
            onPressed: () => context.read<QuizState>().toggleDarkMode(),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            MathOptionButton('Adição', Icons.add, Colors.amber, () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => QuizSettingsPage(operation: 'Adição')));
            }),
            MathOptionButton('Subtração', Icons.remove, Colors.lightGreen, () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => QuizSettingsPage(operation: 'Subtraction')));
            }),
            MathOptionButton('Multiplicação', Icons.clear, Colors.lightBlue, () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => QuizSettingsPage(operation: 'Multiplication')));
            }),
            MathOptionButton('Divisão', Icons.horizontal_rule, Colors.pinkAccent, () {
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
        title: Text('${widget.operation} Padrão respostas', style: TextStyle(fontSize: 24)),
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
        case 'Adição':
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
    final currentQuestion = widget.questions[_currentQuestionIndex];
    if (selectedOption == currentQuestion['answer']) {
      _correctAnswers++;
    }

    if (_currentQuestionIndex + 1 < widget.questions.length) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Resultados'),
          content: Text('Você acertou $_correctAnswers de ${widget.questions.length} perguntas!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text('Voltar'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = widget.questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz de ${currentQuestion['question']}'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              currentQuestion['question'],
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 16),
            ...currentQuestion['options'].map<Widget>(
                  (option) => ElevatedButton(
                onPressed: () => _answerQuestion(option),
                child: Text(option.toString()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
