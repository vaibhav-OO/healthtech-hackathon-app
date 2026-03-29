import 'package:aisymtoms/models/user.dart';
import 'package:aisymtoms/services/db_service.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();


  // var user = await dbService.loginUser(email, password);

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            const SizedBox(height: 20),
            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: () async {
                setState(() => loading = true);


                // final user = await AuthService().register(
                //   emailController.text.trim(),
                //   passwordController.text.trim(),
                // );


                //Change to SQL services
                try {
                  await DBService.instance.registerUser(
                    UserModel(
                      name: nameController.text.trim(),
                      email: emailController.text.trim(),
                      password: passwordController.text.trim(),
                    ),
                  );

                  setState(() => loading = false);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Registration successful")),
                  );

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                } catch (e) {
                  setState(() => loading = false);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("User already exists or error occurred")),
                  );
                }
              },
                child: const Text("Register"),
            ),
          ],
        ),
      ),
    );
  }
}