import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app_calculadora/src/extensions/string_extension.dart';
import 'package:my_app_calculadora/src/model/currency.dart';
import 'package:my_app_calculadora/src/repository/currency_repository.dart';
import 'package:my_app_calculadora/src/extensions/list_extension.dart';

class FavoritesCubit extends Cubit<FavoriteState> {
  final CurrencyRepositoryBase _repository;
  late final StreamSubscription subscription;
  List<Currency> _currencies = [];

  late Currency _selected;

  String filter = '';

  FavoritesCubit(this._repository) : super(FavoriteLoadingState()) {
    _init();
  }

  Future<void> _init() async {
    subscription = _repository.getCurrencies().listen((it) async {
      if (it.isNotEmpty) {
        _currencies = it;
        _selected = await _repository.getSelectedCurrency();
        _updateState();
      }
    });
  }

  ///BUSCA EL TIPO DE MONEDAD
  void filterCurrencies(String filter) {
    this.filter = filter;
    _updateState();
  }

  ///HABILITAR O DESABILITAR LAS MONEDAS
  Future<void> setEnabled(String key, bool isEnabled) async {
    if (_selected.key == key) {
      setWarning('Cannot disable selected currency');
    } else if (!isEnabled && _totalEnabledCurrencies <= 2) {
      setWarning('Cannot disable all the currencies');
    } else {
      if (isEnabled) {
        await _repository.enableCurrency(key, 9999);
      } else {
        await _repository.disableCurrency(key);
      }
      final edited = await _repository.getCurrency(key);
      _currencies = List.from(_currencies)
        ..replaceWhere((it) => it.key == key, edited);
      _updateState();
    }
  }

  Future<void> setWarning(String message) async {
    emit(FavoriteWarningState(message));
    await Future.delayed(Duration(milliseconds: 100));
    _updateState();
  }

  //TOTAL DE MONEDAS
  int get _totalEnabledCurrencies =>
      _currencies.where((it) => it.isEnabled).length;

  void _updateState() {
    if (filter.isEmpty) {
      emit(FavoriteReadyState(_currencies, _selected));
    } else {
      final result = _currencies.where((it) {
        return it.key.containsIgnoreCase(filter) ||
            it.name.containsIgnoreCase(filter);
      }).toList();
      emit(FavoriteReadyState(result, _selected));
    }
  }

  @override
  Future<void> close() {
    subscription.cancel();
    return super.close();
  }
}

class FavoriteState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FavoriteLoadingState extends FavoriteState {}

class FavoriteReadyState extends FavoriteState {
  final List<Currency> currencies;
  final Currency selected;

  FavoriteReadyState(this.currencies, this.selected);

  @override
  List<Object?> get props => [currencies];
}

class FavoriteWarningState extends FavoriteState {
  final String message;

  FavoriteWarningState(this.message);

  @override
  List<Object?> get props => [message];
}
