import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app_calculadora/src/extensions/datetime_extension.dart';
import 'package:my_app_calculadora/src/model/currency.dart';
import 'package:my_app_calculadora/src/repository/currency_repository.dart';
import 'package:my_app_calculadora/src/extensions/list_extension.dart';

class ConverterCubit extends Cubit<ConverterState> {
  final CurrencyRepositoryBase _repository;

   StreamSubscription? subscription;

  late Currency _selected;
  List<Currency> _enabledCurrencies = [];

  num amountToConvert = 1.0;

  ConverterCubit(this._repository) : super(ConverterLoadingState()) {
    refresh();
  }

  Future<void> refresh() async {
    subscription?.cancel();
    subscription = _repository.getCurrencies().listen((it) async {
      if (it.isNotEmpty) {
        _selected = await _repository.getSelectedCurrency();
        _enabledCurrencies = it.where((it) => it.isEnabled).toList();
        _enabledCurrencies.removeWhere((it) => it.key == _selected.key);
        _enabledCurrencies.sort((a, b) => a.position - b.position);
        _updateState();
      }
    });
  }

  //SELECIONA CUAL MONEDA SUBO O BAJO
  Future<void> setSelected(String key) async {
    final newIndex = _enabledCurrencies.indexWhere((it) => it.key == key);

    _enabledCurrencies.removeAt(newIndex);

    await _repository.enableCurrency(key, newIndex);
    _enabledCurrencies.insert(newIndex, _selected);

    await _repository.setSelectedCurrency(key);
    _selected = await _repository.getSelectedCurrency();
    _updateState();
  }

  //CONVIERTE EL EURO A CUALQUIER MONEDA
  void setAmount(num amount) {
    this.amountToConvert = amount;
    _updateState();
  }

  //ORDENAR
  void reOrder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;
    _enabledCurrencies.reOrder(oldIndex, newIndex);
    for (var i = 0; i < _enabledCurrencies.length; i++) {
      _repository.enableCurrency(_enabledCurrencies[i].key, i);
    }
    _updateState();
  }

  void _updateState() {
    final wrapper = _enabledCurrencies.map((it) {
      final resultSelectedTo = (amountToConvert / _selected.value) * it.value;
      final resultOneToSelected = (1 / it.value) * _selected.value;
      return WrapperCurrency(
          it.key,
          it.name,
          _selected.key,
        resultSelectedTo,
        resultOneToSelected,
      );
    }).toList();
    final date = DateTime.fromMillisecondsSinceEpoch(_selected.timestamp * 1000);
    emit(ConverterReadyState(
      wrapper,
      amountToConvert,
      _selected,
      date.prettyDate(),
    ));
  }

  @override
  Future<void> close() {
    subscription?.cancel();
    return super.close();
  }
}

class ConverterState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ConverterLoadingState extends ConverterState {}

class ConverterReadyState extends ConverterState {
  final List<WrapperCurrency> currencies;
  final num amountConverting;
  final Currency selected;
  final String timestamp;

  ConverterReadyState(
    this.currencies,
    this.amountConverting,
    this.selected,
    this.timestamp,
  );

  @override
  List<Object?> get props => [currencies];
}

class WrapperCurrency extends Equatable {
  final String key;
  final String name;
  final String selectedKey;
  final num resultSelectedTo;
  final num resultOneToSelected;

  WrapperCurrency(
    this.key,
    this.name,
    this.selectedKey,
    this.resultSelectedTo,
    this.resultOneToSelected,
  );

  @override
  List<Object?> get props =>
      [key, selectedKey, resultOneToSelected, resultSelectedTo,];
}
