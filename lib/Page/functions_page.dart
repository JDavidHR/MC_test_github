import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:mc_test/model/entity/question.dart';

Future<void> generatePDF({
  required String name,
  required String email,
  required Map<String, String> selectedAnswers,
  required List<Question> questions,
}) async {
  final pdf = pw.Document();

  // Cargar imagen desde los activos
  final ByteData bytes = await rootBundle.load('assets/logos/MC_logo.png');
  final Uint8List uint8List = bytes.buffer.asUint8List();

  // Crear MemoryImage usando el Uint8List
  final pw.MemoryImage pdfImage = pw.MemoryImage(uint8List);

  final outputDir = await getApplicationDocumentsDirectory();
  final filePath = '${outputDir.path}/test_results.pdf';

  pdf.addPage(pw.Page(
    build: (pw.Context context) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Image(pdfImage),
          pw.Text('Resultados del examen',
              style: const pw.TextStyle(fontSize: 24)),
          pw.SizedBox(height: 20),
          pw.Text('Nombre: $name'),
          pw.Text('Email: $email'),
          pw.SizedBox(height: 20),
          pw.Text('Respuestas:'),
          pw.SizedBox(height: 10),
          ...questions.map((question) {
            final selectedAnswer = selectedAnswers[question.id];
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
        ],
      );
    },
  ));

  // Guardar el PDF
  final file = File(filePath);
  await file.writeAsBytes(await pdf.save());
  debugPrint('PDF generado en: $filePath');
}

void calculateScores({
  required Map<String, String> selectedAnswers,
  required List<Question> questions,
  required Map<String, double> questionScores,
}) {
  double totalScore = 0;

  for (var question in questions) {
    final selectedAnswer = selectedAnswers[question.id];
    final correctAnswer =
        question.answers.firstWhere((answer) => answer.isCorrect);

    final score = selectedAnswer == correctAnswer.id ? 100.0 : 0.0;
    questionScores[question.id] = score;
    totalScore += score;
  }

  final averageScore = totalScore / questions.length;
  debugPrint('Total Score: $totalScore');
  debugPrint('Average Score: $averageScore');
}

void showAppOutOfFocusDialog({
  required BuildContext context,
  required ValueNotifier<bool> dialogShown,
}) {
  if (!dialogShown.value) {
    dialogShown.value = true;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('¡Ups!'),
          content: const Text('Estás fuera de la aplicación.'),
          actions: [
            TextButton(
              onPressed: () {
                dialogShown.value = false;
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
