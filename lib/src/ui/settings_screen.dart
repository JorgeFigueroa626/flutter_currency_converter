

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app_calculadora/src/bloc/navigation_cubit.dart';
import 'package:my_app_calculadora/src/bloc/settings_cubit.dart';
import 'package:my_app_calculadora/src/extensions/context_extension.dart';
import 'package:my_app_calculadora/src/ui/bottom_bar.dart';

class SettingsScreen extends StatelessWidget {
  static Widget create(BuildContext context)=> SettingsScreen();

  //LINEA DIVISORA
  Widget getDivisor(){
    return Column(
      children: [
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 1,
          color: Colors.black,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      bottomNavigationBar: BottomNavBar(context.watch<NavigationCubit>().state),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            getDivisor(),
            SizedBox(height: 16),
            Center(
              child: Text(
                context.formatCurrency(1000000, '\$'),
                style: TextStyle(fontSize: 23),
              ),
            ),
            getDivisor(),
            NumberOfDecimals(),
            getDivisor(),
            GroupSeparator(),
            getDivisor(),
            DecimalSeparator(),
            getDivisor(),
            CurrencySymbol(),
          ],
        ),
      ),
    );
  }
}

class NumberOfDecimals extends StatelessWidget {

  List<DropdownMenuItem<int>> dropDownItems(){
    return [1,2,3,4,5,6,7,8,9,10].map((it) =>
        DropdownMenuItem<int>(
        child: Text('$it'),
        value: it,),).toList();
  }

  @override
  Widget build(BuildContext context) {
    final settingsCubit = context.watch<SettingsCubit>();

    return  Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            Text(
              'Decimals',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Number of decimals to display'),
          ],
        ),
        //NUMERO DE DECIMALES
        DropdownButton(
        items: dropDownItems(), 
        value: settingsCubit.numberOfDecimals,
        onChanged: (int? value)=>settingsCubit.setNumberOfDecimals(value ?? 3),
        ),
      ],
    );
  }
}

class GroupSeparator extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final settingsCubit = context.watch<SettingsCubit>();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        Text(
          'Group separator',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            Checkbox(
              value: settingsCubit.isGroupSeparatorEnabled,
              onChanged: (bool? value) => settingsCubit.setGroupSeparator(value!),
            ),
            Text('Enable symbol used for thousands separator')
          ],
        )
      ],
    );
  }
}

class DecimalSeparator extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final settingsCubit = context.watch<SettingsCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        Text(
          'Decimal separator',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            Radio(
                value: true,
                groupValue: settingsCubit.decimalSeparator == '.',
                onChanged: (bool? value) => settingsCubit.setDecimalSeparator(value!)
            ),
            Text('Decimal Point'),
          ],
        ),
        Row(
          children: [
            Radio(
                value: false,
                groupValue: settingsCubit.decimalSeparator == '.',
                onChanged: (bool? value) => settingsCubit.setDecimalSeparator(value!)
            ),
            Text('Decimal comma'),
          ],
        ),
      ],
    );
  }
}

class CurrencySymbol extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final settingsCubit = context.watch<SettingsCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        Text(
          'Currency Symbol',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text('Choose where to display the currency symbol'),
        Row(
          children: [
            Radio(
                value: true,
                groupValue: settingsCubit.isSymbolAtStart,
                onChanged: (bool? value) => settingsCubit.setSymbolPosition(value!),
            ),
            Text('Start'),
            SizedBox(width: 50),
            Radio(
              value: false,
              groupValue: settingsCubit.isSymbolAtStart,
              onChanged: (bool? value) => settingsCubit.setSymbolPosition(value!),
            ),
            Text('End')
          ],
        )
      ],
    );
  }
}

