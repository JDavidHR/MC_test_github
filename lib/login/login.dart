import 'package:flutter/material.dart';
import 'package:mc_test/core/components/mcButton.dart';
import 'package:mc_test/core/components/mcTextfield.dart';

import 'package:mc_test/login/functions.dart'; // Importar las funciones

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logos/MC_logo.png',
                height: 180,
              ),
              const SizedBox(height: 8),
              const Text(
                'Bienvenido',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 260,
                child: McTextField(
                  controller: _nameController,
                  labelText: "Nombre",
                  keyboardType: TextInputType.text,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 260,
                child: McTextField(
                  controller: _emailController,
                  labelText: "Email",
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              const SizedBox(height: 24),
              MCButton(
                width: 100,
                height: 40,
                onPressed: () {
                  final email = _emailController.text.trim();
                  final name = _nameController.text.trim();
                  if (email.isNotEmpty && name.isNotEmpty) {
                    showAttemptDialog(
                      context: context,
                      name: name,
                      email: email,
                    ); // Mostrar diálogo
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Por favor, rectifica los campos.'),
                      ),
                    );
                  }
                },
                text: "Login",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
