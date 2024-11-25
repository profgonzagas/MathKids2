import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:async';
//https://docs.flutter.dev/platform-integration/platform-channels


void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => QuizState(),
      child: MathQuizApp(),
    ),
  );
}

class MathQuizApp extends StatelessWidget {
  static const platform = MethodChannel('samples.flutter.dev/battery');
  // Get battery level.
 /* String _batteryLevel = 'Unknown battery level.';

  Future<void> _getBatteryLevel() async {
    String batteryLevel;
    try {
      final result = await platform.invokeMethod<int>('getBatteryLevel');
      batteryLevel = 'Battery level at $result % .';
    } on PlatformException catch (e) {
      batteryLevel = "Failed to get battery level: '${e.message}'.";
    }

    setState(() {
      _batteryLevel = batteryLevel;
    });
  } */
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
class SoundPlayer {
  static const platform = MethodChannel('samples.flutter.dev/sound');

  Future<void> playSound(String soundName) async {
    try {
      await platform.invokeMethod('playSound', {'sound': soundName});
      print("Chamando método para tocar som: $soundName");
    } on PlatformException catch (e) {
      print("Erro ao tentar tocar som: '${e.message}'.");

    }
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
  // Função para abrir o Instagram
  Future<void> _openInstagram() async {
    final url = 'https://www.instagram.com/profgonzagas/';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Não foi possível abrir o Instagram $url';
    }
  }
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
          IconButton(
            icon: FaIcon(FontAwesomeIcons.instagram),  // Ícone do Instagram usando FontAwesome
            onPressed: () {
              _openInstagram();
            },
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
// Função para abrir o Instagram
Future<void> _openInstagram() async {
  const url = 'https://www.instagram.com/profgonzagas';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Não foi possível abrir o Instagram.';
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

// O restante do código continua sem alterações


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
    final question = widget.questions[_currentQuestionIndex];
    bool isCorrect = question['options'][selectedOption] == question['answer'];
    if (isCorrect) {
      _correctAnswers++;
    }

    /* ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
       content: Text(isCorrect ? 'Acertou!' : 'Errou!'),

        //  content: Lottie.asset('lib/assets/animations/acertou.json'),

        duration: Duration(seconds: 1),
      ),
    ); */
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isCorrect ? 'Acertou!' : 'Errou!'),
        duration: Duration(seconds: 1),
      ),
    );
// Instancie o SoundPlayer
    SoundPlayer soundPlayer = SoundPlayer();

// Toque o som baseado na resposta
    if (isCorrect) {
      soundPlayer.playSound('correct'); // Som para acerto
    } else {
      soundPlayer.playSound('incorrect'); // Som para erro
    }

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