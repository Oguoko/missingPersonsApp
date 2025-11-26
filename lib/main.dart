import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'screens/missing_persons_list_screen.dart';
import 'screens/add_missing_person_screen.dart';
import 'screens/missing_person_detail_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Missing Persons TZ',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => MissingPersonsListScreen(),
        '/add': (context) => AddMissingPersonScreen(),
        // NEW — Step 10.2
        '/details': (context) {
          final id = ModalRoute.of(context)!.settings.arguments as String;
          return MissingPersonDetailScreen(personId: id);
        },
      },
    );
  }
}
