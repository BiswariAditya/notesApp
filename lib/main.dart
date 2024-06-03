import 'package:flutter/material.dart';
import 'package:sql_project/screen/home_screen.dart';

import 'db_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DbHelper().initDatabase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'My Notes',
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
