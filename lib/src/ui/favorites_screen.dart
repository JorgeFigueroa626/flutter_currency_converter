import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app_calculadora/src/bloc/favorites_cubit.dart';
import 'package:my_app_calculadora/src/bloc/navigation_cubit.dart';
import 'package:my_app_calculadora/src/model/currency.dart';
import 'package:my_app_calculadora/src/repository/currency_repository.dart';
import 'package:my_app_calculadora/src/ui/bottom_bar.dart';

class FavoritesScreen extends StatelessWidget {
  static Widget create(BuildContext context) {
    return BlocProvider(
      create: (_) => FavoritesCubit(context.read<CurrencyRepositoryBase>()),
      child: FavoritesScreen(),
    );
  }

//SELECIONAR O ARASTRAR MONEDA
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites currencies'),
      ),
      bottomNavigationBar: BottomNavBar(context.watch<NavigationCubit>().state),
      //MESAGE DE ERROR - NO PUEDE DESABILTAR LA MONEDA POR DEFECTO
      body: BlocListener<FavoritesCubit, FavoriteState>(
        listener: (context, state) {
          if (state is FavoriteWarningState) {
            final snackBar = SnackBar(content: Text(state.message));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        },
        child: BlocBuilder<FavoritesCubit, FavoriteState>(
          builder: (context, state) {
            if (state is FavoriteReadyState) {
              return Column(
                children: [
                  _SearchInputWidget(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: state.currencies.length + 1,
                      itemBuilder: (context, int index) {
                        if (index == 0) {
                          return SelectedCurrencyRow(state.selected);
                        } else {
                          return CurrencyRow(state.currencies[index - 1]);
                        }
                      },
                    ),
                  ),
                ],
              );
            }
            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}

///LISTADO DE LAS MONEDAS SELECCIONADAS - CHECKBOX
class CurrencyRow extends StatelessWidget {
  final Currency currency;

  const CurrencyRow(this.currency);

  //CLIC - HABILITA Y DESABILITA
  Future<void> setEnabled(BuildContext context, Currency currency) => context
      .read<FavoritesCubit>()
      .setEnabled(currency.key, !currency.isEnabled);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: () async => setEnabled(context, currency),
        title: Text(currency.key),
        subtitle: Text(currency.name),
        leading: Image.asset('assets/flags/${currency.key}.png'),
        trailing: Checkbox(
          key: Key(currency.key),
          value: currency.isEnabled,
          onChanged: (bool? value) async => await setEnabled(context, currency),
        ),
      ),
    );
  }
}

///MONEDAD SELECCIONADAD
class SelectedCurrencyRow extends StatelessWidget {
  final Currency currency;

  const SelectedCurrencyRow(this.currency);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text('${currency.key} (Selected currency)'),
        subtitle: Text(currency.name),
        leading: Image.asset('assets/flags/${currency.key}.png'),
      ),
    );
  }
}

class _SearchInputWidget extends StatefulWidget {
  @override
  State<_SearchInputWidget> createState() => __SearchInputWidgetState();
}

class __SearchInputWidgetState extends State<_SearchInputWidget> {
  final _controller = TextEditingController();

  @override
  // ignore: must_call_super
  void initState() {
    _controller.addListener(() {
      context.read<FavoritesCubit>().filterCurrencies(_controller.text);
    });
  }

//CONTROLADOR - BUSCADOR DEL TIPO DE MONEDA
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: TextFormField(
        controller: _controller,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search),
          labelText: 'Search currency',
          suffixIcon: _controller.text.isEmpty
              ? null
              : IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () => _controller.clear(),
                ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
