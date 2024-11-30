import 'package:flutter/material.dart';
import 'package:mc_test/page/page.dart';

Future<void> showAttemptDialog({
  required BuildContext context,
  required String name,
  required String email,
}) async {
  // Mostrar el diálogo de intento único
  await showDialog(
    context: context,
    barrierDismissible: true, // Permite cerrar tocando fuera del diálogo
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Aviso importante'),
        content: const Text(
          'Solo tienes un intento. Si abandonas esta ventana, se cerrará el intento.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar el diálogo
              redirectToTestPage(context: context, name: name, email: email);
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );

  // En caso de que se cierre el diálogo tocando fuera
  redirectToTestPage(context: context, name: name, email: email);
}

void redirectToTestPage({
  required BuildContext context,
  required String name,
  required String email,
}) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => TestPage(
        name: name,
        email: email,
      ),
    ),
  );
}
