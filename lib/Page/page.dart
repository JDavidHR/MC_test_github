import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mc_test/core/colors.dart';
import 'package:mc_test/core/components/mcTextfield.dart';
import 'package:mc_test/core/components/mcbutton.dart';
import 'package:mc_test/model/entity/answer.dart';
import 'package:mc_test/model/entity/question.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> with WidgetsBindingObserver {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
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
  bool _dialogShown = false;
  final Map<String, double> _questionScores = {};

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

  bool get _isFormValid {
    return _nameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _selectedAnswers.length == questions.length;
  }

  // Método para generar el PDF
  Future<void> _generatePDF() async {
    final pdf = pw.Document();

    // Cargar imagen desde los activos
    final ByteData bytes = await rootBundle.load('assets/logos/MC_logo.png');
    final Uint8List uint8List = bytes.buffer.asUint8List();

    // Crear MemoryImage usando el Uint8List
    final pw.MemoryImage pdfImage = pw.MemoryImage(uint8List);

    final outputDir =
        await getApplicationDocumentsDirectory(); // Directorio donde guardar el archivo
    final filePath = '${outputDir.path}/test_results.pdf';

    pdf.addPage(pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Image(pdfImage), // Mostrar la imagen en el PDF
            pw.Text('Resultados del examen',
                style: const pw.TextStyle(fontSize: 24)),
            pw.SizedBox(height: 20),
            pw.Text('Nombre: ${_nameController.text}'),
            pw.Text('Email: ${_emailController.text}'),
            pw.SizedBox(height: 20),
            pw.Text('Respuestas:'),
            pw.SizedBox(height: 10),
            ...questions.map((question) {
              final selectedAnswer = _selectedAnswers[question.id];
              final correctAnswer =
                  question.answers.firstWhere((answer) => answer.isCorrect);
              final score = selectedAnswer == correctAnswer.id ? 100.0 : 0.0;

              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(question.label),
                  pw.Text(
                      'Respuesta seleccionada: ${question.answers.firstWhere((a) => a.id == selectedAnswer).label}'),
                  pw.Text('Respuesta correcta: ${correctAnswer.label}'),
                  pw.Text('Puntaje: $score%'),
                  pw.SizedBox(height: 10),
                ],
              );
            }).toList(),
            pw.SizedBox(height: 20),
            // pw.Text(
            //     'Total Score: ${_questionScores.values.reduce((a, b) => a + b)}'),
          ],
        );
      },
    ));

    // Guardar el PDF
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    debugPrint('PDF generado en: $filePath');
  }

  void _submitTest() {
    if (_isFormValid) {
      debugPrint('Name: ${_nameController.text}');
      debugPrint('Email: ${_emailController.text}');
      debugPrint('Selected Answers: $_selectedAnswers');

      // Calcula la calificación de cada pregunta
      _calculateScores();
      _generatePDF();
    }
  }

  void _calculateScores() {
    double totalScore = 0;

    questions.forEach((question) {
      final selectedAnswer = _selectedAnswers[question.id];
      final correctAnswer =
          question.answers.firstWhere((answer) => answer.isCorrect);

      // Usa 100.0 y 0.0 en lugar de 100 y 0
      final score = selectedAnswer == correctAnswer.id ? 100.0 : 0.0;

      _questionScores[question.id] = score;
      totalScore += score;
    });

    // Mostrar calificación total
    final averageScore = totalScore / questions.length;
    debugPrint('Total Score: $totalScore');
    debugPrint('Average Score: $averageScore');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // La app está en primer plano
      debugPrint('is focus: true');
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // La app está en segundo plano o inactiva
      debugPrint('is focus: false');
      _showAppOutOfFocusDialog();
    }
  }

  void _showAppOutOfFocusDialog() {
    if (!_dialogShown) {
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
                  _dialogShown = false; // Restablecer bandera
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const Key('visibility_detector'),
      onVisibilityChanged: (visibilityInfo) {
        if (visibilityInfo.visibleFraction == 0.0 && !_dialogShown) {
          _showAppOutOfFocusDialog();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Image.asset(
            'assets/logos/MC_logo.png',
            height: 54,
          ),
          backgroundColor: MCPaletteColors.background,
        ),
        body: Container(
          color: MCPaletteColors.background,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                McTextField(
                  controller: _nameController,
                  labelText: 'Nombre',
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                McTextField(
                  controller: _emailController,
                  labelText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 32),
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
                                      _selectedAnswers[question.id] = value!;
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
    );
  }
}
