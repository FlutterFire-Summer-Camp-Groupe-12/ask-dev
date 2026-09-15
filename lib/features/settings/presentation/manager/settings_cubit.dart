import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Réglages applicatifs. Pour l'instant : thème clair/sombre.
class SettingsCubit extends Cubit<ThemeMode> {
  SettingsCubit() : super(ThemeMode.light);

  void toggleDark({required bool enabled}) =>
      emit(enabled ? ThemeMode.dark : ThemeMode.light);
}
