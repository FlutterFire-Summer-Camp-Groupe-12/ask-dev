import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Réglages applicatifs. Pour l'instant : le thème, qui suit le système par
/// défaut.
class SettingsCubit extends Cubit<ThemeMode> {
  SettingsCubit() : super(ThemeMode.system);

  void setThemeMode(ThemeMode mode) => emit(mode);
}
