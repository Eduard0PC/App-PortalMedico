import 'package:flutter/material.dart';
import 'core/app_state.dart';
import 'core/theme.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/paciente/paciente_home_screen.dart';
import 'features/medico/medico_home_screen.dart';

void main() {
  runApp(
    AppStateProvider(
      notifier: AppState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Portal Médico Clínico',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/paciente-home': (context) => const PacienteHomeScreen(),
        '/medico-home': (context) => const MedicoHomeScreen(),
      },
    );
  }
}
