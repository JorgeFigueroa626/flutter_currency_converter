
import 'package:my_app_calculadora/src/model/currency.dart';

abstract class CurrencyRepositoryBase{
  Stream<List<Currency>> getCurrencies();

  Future<Currency> getCurrency(String key);

  Future<Currency> getSelectedCurrency();

  Future<void> setSelectedCurrency(String key);

  Future<void> enableCurrency(String key, int position);

  Future<void> disableCurrency(String key);

  Future<int> getEnabledCurrencyCount();
}