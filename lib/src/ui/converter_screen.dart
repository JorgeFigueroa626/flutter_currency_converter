import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_simple_calculator/flutter_simple_calculator.dart';
import 'package:my_app_calculadora/src/bloc/converter_cubit.dart';
import 'package:my_app_calculadora/src/bloc/navigation_cubit.dart';
import 'package:my_app_calculadora/src/extensions/context_extension.dart';
import 'package:my_app_calculadora/src/model/currency.dart';
import 'package:my_app_calculadora/src/repository/currency_repository.dart';
import 'package:my_app_calculadora/src/ui/bottom_bar.dart';
import 'package:my_app_calculadora/src/utils/currency_symbol.dart';

class ConverterScreen extends StatelessWidget {
  static Widget create(BuildContext context) {
    return BlocProvider(
      create: (_) => ConverterCubit(context.read<CurrencyRepositoryBase>()),
      child: ConverterScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _AppBar(),
      bottomNavigationBar: BottomNavBar(context.watch<NavigationCubit>().state),
      body: BlocBuilder<ConverterCubit, ConverterState>(
        builder: (context, state) {
          if (state is ConverterReadyState) {
            return Column(
              children: [
                _SelectedRow(state.amountConverting, state.selected),
                //LISTA DE LAS MONEDAS SELECIONAS POR DEFECTO
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => context.read<ConverterCubit>().refresh(),
                    child: ReorderableListView(
                      onReorder: (int oldIndex, int newIndex) {
                        context
                            .read<ConverterCubit>()
                            .reOrder(oldIndex, newIndex);
                      },
                      children: state.currencies
                          .map((it) => _CurrencyRow(it))
                          .toList(),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

//DISEÑO DEL FRACMENTO DE CONVERTIDOR - FECHA HORA
class _AppBar extends StatelessWidget with PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Currency Converter'),
          const SizedBox(height: 4),
          BlocBuilder<ConverterCubit, ConverterState>(
              builder: (context, state) {
            return Text(
              state is ConverterReadyState ? state.timestamp : 'Updating...',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w300,
              ),
            );
          }),
        ],
      ),
    );
  }
}

//CALCULADORA DE LA MONEDA
class _SelectedRow extends StatelessWidget {
  final num _amountConverting;
  final Currency _selected;

  const _SelectedRow(
    this._amountConverting,
    this._selected,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      // ignore: deprecated_member_use
      color: Theme.of(context).accentColor,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          children: [
            Image.asset('assets/flags/${_selected.key}.png'),
            SizedBox(width: 8),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _selected.key,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (_) {
                                return SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.75,
                                  child: SimpleCalculator(
                                    value: _amountConverting.toDouble(),
                                    hideExpression: false,
                                    hideSurroundingBorder: true,
                                    onChanged: (key, value, expression) =>
                                        context
                                            .read<ConverterCubit>()
                                            .setAmount(value ?? 0),
                                  ),
                                );
                              });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.black,
                              width: 1,
                            ),
                          ),
                          height: 40,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: Text(
                                context.formatCurrency(
                                   _amountConverting,
                                  getCurrencySymbol(_selected.key),
                                ),
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                Container(height: 4),
                Text(_selected.name),
              ],
            ))
          ],
        ),
      ),
    );
  }
}

//DISEÑO DE LAS MONEDAS SELECIONADAS POR DEFECTO
class _CurrencyRow extends StatelessWidget {
  final WrapperCurrency currency;

  _CurrencyRow(this.currency) : super(key: Key(currency.key));

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        //selecionar la moneda
        onTap: () => context.read<ConverterCubit>().setSelected(currency.key),
        leading: Image.asset('assets/flags/${currency.key}.png'),
        title: Text(currency.key),
        subtitle: Text(currency.name),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              context.formatCurrency(
                currency.resultSelectedTo,
                getCurrencySymbol(currency.key),
              ),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '1 ${currency.key} = ${context.format(currency.resultOneToSelected)} ${currency.selectedKey}',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 10,
              ),
            )
          ],
        ),
      ),
    );
  }
}
