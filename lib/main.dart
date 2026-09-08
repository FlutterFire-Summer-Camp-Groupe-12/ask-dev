import 'package:askdev/dependency_injection/injection.dart';
import 'package:askdev/myapp.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  runApp(const MyApp());
}
