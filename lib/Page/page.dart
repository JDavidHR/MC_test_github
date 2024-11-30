import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mc_test/core/colors.dart';
import 'package:mc_test/core/components/mcbutton.dart';
import 'package:mc_test/login/login.dart';
import 'package:mc_test/model/entity/answer.dart';
import 'package:mc_test/model/entity/question.dart';
import 'package:mc_test/page/functions_page.dart';
import 'package:visibility_detector/visibility_detector.dart';

class TestPage extends StatefulWidget {
  final String? name;
  final String? email;
  const TestPage({
    super.key,
    this.name,
    this.email,
  });

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> with WidgetsBindingObserver {
  final List<Question> questions = [
    Question(
      id: 'q1',
      label: 'What is the capital of France?',
      answers: [
        Answer(id: 'a1', label: 'Berlin'),
        Answer(id: 'a2', label: 'Paris', isCorrect: true),
        Answer(id: 'a3', label: 'Madrid'),
      ],
    ),
    Question(
      id: 'q2',
      label: 'Which planet is known as the Red Planet?',
      answers: [
        Answer(id: 'a1', label: 'Earth'),
        Answer(id: 'a2', label: 'Mars', isCorrect: true),
        Answer(id: 'a3', label: 'Jupiter'),
      ],
    ),
  ];

  final Map<String, String> _selectedAnswers = {};
  final Map<String, double> _questionScores = {};
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void showAppOutOfFocusDialog() {
    if (!_dialogShown && mounted) {
      _dialogShown = true;
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('¡Ups!'),
            content: const Text('Estás fuera de la aplicación.'),
            actions: [
              TextButton(
                onPressed: () {
                  _dialogShown = false;
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ),
                  );
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  bool get _isFormValid => _selectedAnswers.length == questions.length;

  void _submitTest() {
    if (_isFormValid) {
      calculateScores(
        selectedAnswers: _selectedAnswers,
        questions: questions,
        questionScores: _questionScores,
      );
      generatePDF(
        name: widget.name ?? "",
        email: widget.email ?? "",
        selectedAnswers: _selectedAnswers,
        questions: questions,
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      debugPrint('is focus: true');
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      debugPrint('is focus: false');
      showAppOutOfFocusDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const Key('visibility_detector'),
      onVisibilityChanged: (visibilityInfo) {
        if (visibilityInfo.visibleFraction == 0.0 && !_dialogShown) {
          showAppOutOfFocusDialog();
        }
      },
      child: Scaffold(
        backgroundColor: MCPaletteColors.background,
        appBar: AppBar(
          title: Image.asset(
            'assets/logos/MC_logo.png',
            height: 54,
          ),
          backgroundColor: MCPaletteColors.background,
        ),
        body: Center(
          child: Container(
            color: MCPaletteColors.background,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: 400,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: questions.length,
                        itemBuilder: (context, index) {
                          final question = questions[index];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                question.label,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: MCPaletteColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Column(
                                children: question.answers.map((answer) {
                                  return Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: RadioListTile<String>(
                                      title: Text(
                                        answer.label,
                                        style: const TextStyle(
                                          color: MCPaletteColors.textSecondary,
                                        ),
                                      ),
                                      value: answer.id,
                                      groupValue: _selectedAnswers[question.id],
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedAnswers[question.id] =
                                              value!;
                                        });
                                      },
                                    ),
                                  );
                                }).toList(),
                              ),
                              const Divider(),
                            ],
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: MCButton(
                        onPressed: _isFormValid ? _submitTest : null,
                        text: 'Enviar Test',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
