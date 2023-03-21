import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app_calculadora/src/bloc/converter_cubit.dart';

import '../mocks/mock_currency_repository.dart';

void main() {
  late MockCurrencyRepository currencyRepository;

  setUp(() {
    currencyRepository = MockCurrencyRepository();
  });

  blocTest<ConverterCubit, ConverterState>(
    'Converter cubit initialize correctly',
    build: () => ConverterCubit(currencyRepository),
    verify: (cubit) {
      expect(cubit.state is ConverterReadyState, true);

      final state = cubit.state as ConverterReadyState;

      expect(state.currencies.length, 5);
      expect(state.currencies[0].key, 'CNY');
      expect(state.currencies[1].key, 'USD');
      expect(state.currencies[2].key, 'JPY');
      expect(state.currencies[3].key, 'MXN');
      expect(state.currencies[4].key, 'BOB');

      expect(state.selected.key, 'EUR');
    },
  );

  blocTest<ConverterCubit, ConverterState>(
    'One EUR to other currency is converted correctly',
    build: () => ConverterCubit(currencyRepository),
    verify: (cubit) {
      final state = cubit.state as ConverterReadyState;

      expect(state.currencies[0].resultSelectedTo, 7.32);
      expect(state.currencies[1].resultSelectedTo, 1.07);
      expect(state.currencies[2].resultSelectedTo, 143.73);
      expect(state.currencies[3].resultSelectedTo, 19.69);
      expect(state.currencies[4].resultSelectedTo, 7.38);
    },
  );

  blocTest<ConverterCubit, ConverterState>(
    'Set different amount will convert correctly',
    build: () => ConverterCubit(currencyRepository),
    act: (cubit) async {
      await Future.delayed(Duration(milliseconds: 1));
      cubit.setAmount(3.5);
    },
    verify: (cubit) {
      final state = cubit.state as ConverterReadyState;

      expect(state.currencies[0].resultSelectedTo, 25.62);
      expect(state.currencies[1].resultSelectedTo, 3.745);
      expect(state.currencies[2].resultSelectedTo, 503.05499999999995);
      expect(state.currencies[3].resultSelectedTo, 68.915);
      expect(state.currencies[4].resultSelectedTo, 25.83);
    },
  );

  blocTest<ConverterCubit, ConverterState>(
    'Select another currency works correctly',
    build: () => ConverterCubit(currencyRepository),
    act: (cubit) async {
      await Future.delayed(Duration(milliseconds: 1));
      cubit.setSelected('USD');
    },
    verify: (cubit) {
      final state = cubit.state as ConverterReadyState;
      expect(state.selected.key, 'USD');
    },
  );

  blocTest<ConverterCubit, ConverterState>(
    'Select another currency works correctly',
    build: () => ConverterCubit(currencyRepository),
    act: (cubit) async {
      await Future.delayed(Duration(milliseconds: 1));
      cubit.setSelected('USD');
      cubit.setAmount(10);
    },
    verify: (cubit) {
      final state = cubit.state as ConverterReadyState;

      expect(state.currencies[0].resultSelectedTo, 68.41121495327103);
      expect(state.currencies[1].resultSelectedTo, 9.345794392523365);
      expect(state.currencies[2].resultSelectedTo, 1343.271028037383);
      expect(state.currencies[3].resultSelectedTo, 184.01869158878506);
      expect(state.currencies[4].resultSelectedTo, 68.97196261682242);
    },
  );
}
