import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'services/chat_service.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // TODO: Replace with your Firebase project config
    // Run `flutterfire configure` to auto-generate firebase_options.dart
  );
  runApp(const DetooApp());
}

class DetooApp extends StatelessWidget {
  const DetooApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ChatService()),
      ],
      child: MaterialApp(
        title: 'Detoo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFF128C7E), // WhatsApp-style Indian green
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF128C7E),
            primary: const Color(0xFF128C7E),
          ),
          scaffoldBackgroundColor: const Color(0xFFECE5DD),
          fontFamily: 'Roboto',
          useMaterial3: true,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
