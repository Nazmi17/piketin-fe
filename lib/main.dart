import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Services & Core
import 'core/network/dio_client.dart';
import 'services/auth_service.dart';
import 'services/permit_service.dart';
import 'services/piket_schedule_service.dart';
import 'services/teacher_assignment_service.dart';
import 'services/user_service.dart';
import 'services/student_service.dart'; 
import 'services/subject_service.dart';

// Providers & Screens
import 'providers/auth_provider.dart';
import 'ui/screens/auth/login_screen.dart';
import 'ui/screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Setup Dio (Network Client) & CookieJar
  final dioClient = DioClient();
  await dioClient.init();

  // 2. Setup Services (Dependency Injection manual)
  final authService = AuthService(dioClient);
  final permitService = PermitService(dioClient);
  final piketService = PiketScheduleService(dioClient);
  final assignmentService = TeacherAssignmentService(dioClient);
  final userService = UserService(dioClient);
  final studentService = StudentService(dioClient);
  final subjectService = SubjectService(dioClient);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService)..checkSession(),
        ),
        Provider.value(value: permitService),
        Provider.value(value: piketService),
        Provider.value(value: assignmentService),
        Provider.value(value: userService),
        Provider.value(value: studentService),
        Provider.value(value: subjectService),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Definisi Warna Utama
    const primaryColor = Color(0xFF2563EB); // Biru yang lebih modern
    const secondaryColor = Color(
      0xFFEFF6FF,
    ); // Biru sangat muda untuk background

    return MaterialApp(
      title: 'Piketin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          background: secondaryColor,
        ),
        scaffoldBackgroundColor: secondaryColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: secondaryColor,
          surfaceTintColor: secondaryColor,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.black87),
        ),
        // Style global untuk Input Field (Rounded & Filled)
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
        ),
        // Style global untuk Elevated Button
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        if (auth.isLoading && auth.user == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (auth.isLoggedIn) {
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
