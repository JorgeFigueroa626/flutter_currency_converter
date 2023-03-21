import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app_calculadora/src/bloc/settings_cubit.dart';

extension BuildContextExtension on BuildContext {
  String formatCurrency(num item, String currencySymbol) =>
      watch<SettingsCubit>().formatCurrency(item, currencySymbol);

  String format(num item) => watch<SettingsCubit>().format(item);
}
