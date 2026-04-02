import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen.dart';
import 'providers/media_provider.dart';
// Note: Other imports will be added as we reconstruct screens

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const QalaamProApp());
}

class QalaamProApp extends StatelessWidget {
  const QalaamProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MediaProvider()),
        // Other providers will be added here
      ],
      child: MaterialApp(
        title: 'Qalaam Pro',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2ECC71), // Qalaam Green
            primary: const Color(0xFF2ECC71),
            secondary: const Color(0xFF27AE60),
            surface: Colors.white,
            background: const Color(0xFFF8FCFB),
          ),
          textTheme: GoogleFonts.outfitTextTheme(
            Theme.of(context).textTheme,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Color(0xFF2ECC71),
            elevation: 0,
            centerTitle: true,
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
