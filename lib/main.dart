import 'package:askdev/dependency_injection/injection.dart';

import 'package:askdev/myapp.dart';

import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await configureDependencies();
  runApp(const MyApp());
}
