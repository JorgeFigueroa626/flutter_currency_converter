
import 'package:my_app_calculadora/src/model/currency.dart';
import 'package:my_app_calculadora/src/provider/db_provider.dart';
import 'package:my_app_calculadora/src/provider/rest_provider.dart';
import 'package:my_app_calculadora/src/repository/currency_repository.dart';

class CurrencyRepository extends CurrencyRepositoryBase{
  final RestProvider _provider;
  final DbProvider _dbProvider;

  CurrencyRepository(this._provider, this._dbProvider);

  @override
  Stream<List<Currency>> getCurrencies() async* {

    yield await _dbProvider.getCurrencies();

    final result = await _provider.latest();
    final currency = result.item1;
    final timestamp = result.item2;
    final symbols = await _provider.symbols();

    final currenciesList = currency.entries.map((it) {
     final name = symbols[it.key]!;
     return Currency(it.key, name, it.value, timestamp);
    }).toList();

    await Future.forEach<Currency>(currenciesList, (it) async => await _dbProvider.insert(it));

    yield await _dbProvider.getCurrencies();
  }

  @override
  Future<Currency> getCurrency(String key) => _dbProvider.getCurrency(key);

  @override
  Future<Currency> getSelectedCurrency() => _dbProvider.getSelectedCurrency();

  @override
  Future<void> setSelectedCurrency(String key) => _dbProvider.setSelectedCurrency(key);

  @override
  Future<void> disableCurrency(String key) => _dbProvider.disableCurrency(key);

  @override
  Future<void> enableCurrency(String key, int position) => _dbProvider.enableCurrency(key, position);

  @override
  Future<int> getEnabledCurrencyCount() => _dbProvider.getEnabledCurrencyCount();
}