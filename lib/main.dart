import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app_calculadora/src/bloc/settings_cubit.dart';
import 'package:my_app_calculadora/src/localization/supported_locales.dart';
import 'package:my_app_calculadora/src/model/currency.dart';
import 'package:my_app_calculadora/src/provider/db_provider.dart';
import 'package:my_app_calculadora/src/provider/rest_provider.dart';
import 'package:my_app_calculadora/src/repository/currency_repository.dart';
import 'package:my_app_calculadora/src/repository/implementation/currency_repository.dart';
import 'package:my_app_calculadora/src/ui/bottom_bar.dart';
import 'package:my_app_calculadora/src/ui/converter_screen.dart';
import 'package:my_app_calculadora/src/ui/favorites_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final restProvider = RestProvider();
  final dbProvider = await DbProvider().init();

  final settingsCubit = await SettingsCubit().init();
  final currencyRepo = CurrencyRepository(restProvider, dbProvider);



  runApp(
    RepositoryProvider<CurrencyRepositoryBase>(
      create: (_) => currencyRepo,
      child: BlocProvider(
          create: (_) => settingsCubit,
              child: MyApp(),
          ),
      ),
  );
}

class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Currency Convertor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BottomBarWidget.create(context),
    );
  }
}
