import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'core/themes/app_theme.dart';
import 'core/themes/colors.dart';
import 'features/assessments/screens/assessments_screen.dart';
import 'core/screens/splash_screen.dart';
import 'core/providers/auth_provider.dart';
import 'core/router/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: AuthWrapper(
          authenticatedRoute: const AssessmentScreen(),
          unauthenticatedRoute: const SplashScreen(),
        ),
        builder: (context, child) {
          return Container(
            color: AppColors.background,
            child: MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(1.0)),
              child: Theme(
                data: Theme.of(context).copyWith(
                  textTheme: Theme.of(context).textTheme.apply(
                        fontFamily: 'Poppins',
                      ),
                ),
                child: child!,
              ),
            ),
          );
        },
      ),
    );
  }
}
