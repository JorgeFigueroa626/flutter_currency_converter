
import 'package:my_app_calculadora/src/model/currency.dart';
import 'package:my_app_calculadora/src/repository/currency_repository.dart';
import 'package:my_app_calculadora/src/extensions/list_extension.dart';

class MockCurrencyRepository extends CurrencyRepositoryBase{
  late List<Currency> _currencies;
  late Currency _selected;

  MockCurrencyRepository(){
    final timestamp = 500;
    final eur = Currency('EUR', 'Euro', 1, timestamp, isEnabled: true, position: 0);
    final cny = Currency('CNY', 'China', 7.32, timestamp, isEnabled: true, position: 0);
    final usd = Currency('USD', 'USA', 1.07, timestamp, isEnabled: true, position: 0);
    final jpy = Currency('JPY', 'Japan', 143.73, timestamp, isEnabled: true, position: 0);
    final mxn = Currency('MXN', 'Mexico', 19.69, timestamp, isEnabled: true, position: 0);
    final bob = Currency('BOB', 'Bolivia', 7.38, timestamp, isEnabled: true, position: 0);
    _selected = eur;
    _currencies = [eur, cny, usd, jpy, mxn, bob];
  }


  @override
  Stream<List<Currency>> getCurrencies() async* {
    yield _currencies;
  }

  @override
  Future<Currency> getCurrency(String key) async =>
      _currencies.firstWhere((it) => it.key == key);

  @override
  Future<Currency> getSelectedCurrency() async => _selected;

  @override
  Future<void> setSelectedCurrency(String key) async {
    _selected = await getCurrency(key);
  }

  ///FUNCION DE HABILITAR O DESABILITAR LA MONEDAS
  Future<void> _setEnabled(String key, bool isEnabled, {int position = -1}) async {
    final result = await getCurrency(key);
    final copy = Currency(
        key,
        result.name,
        result.value,
        result.timestamp,
        isEnabled: isEnabled,
      position: position,
    );
   _currencies.replaceWhere((it) => it.key == key,copy);
  }

  @override
  Future<void> disableCurrency(String key) => _setEnabled(key, false);

  @override
  Future<void> enableCurrency(String key, int position) => _setEnabled(key, true, position: position);

  @override
  Future<int> getEnabledCurrencyCount() async => _currencies.where((it) => it.isEnabled).length;

}