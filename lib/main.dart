import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/add_missing_person_screen.dart';
import 'screens/missing_person_detail_screen.dart';
import 'screens/missing_persons_list_screen.dart';
import 'ui/app_theme.dart';

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
    return MaterialApp(
      title: 'Missing Persons TZ',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      initialRoute: '/',
      routes: {
        '/': (context) => MissingPersonsListScreen(),
        '/add': (context) => const AddMissingPersonScreen(),
        '/details': (context) {
          final id = ModalRoute.of(context)!.settings.arguments as String;
          return MissingPersonDetailScreen(personId: id);
        },
      },
    );
  }
}
