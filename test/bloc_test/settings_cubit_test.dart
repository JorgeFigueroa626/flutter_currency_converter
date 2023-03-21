import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app_calculadora/src/bloc/settings_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SettingsCubit settingsCubit;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    settingsCubit = await SettingsCubit().init();
  });

  blocTest<SettingsCubit, SettingsState>(
    'Settings cubit defaults value are correct',
    build: () => settingsCubit,
    verify: (cubit) {
      expect(cubit.numberOfDecimals, 3);
      expect(cubit.decimalSeparator, '.');
      expect(cubit.isSymbolAtStart, true);
      expect(cubit.isGroupSeparatorEnabled, true);
    },
  );

  blocTest<SettingsCubit, SettingsState>(
    'Set number of decimals works correctly',
    build: () => settingsCubit,
    act: (cubit) =>cubit.setNumberOfDecimals(5),
    verify: (cubit) {
      expect(cubit.format(10), '10.00000');
      expect(cubit.formatCurrency(10, '\$'), '\$ 10.00000');
    },
  );

  blocTest<SettingsCubit, SettingsState>(
    'Disable group separator works correctly',
    build: () => settingsCubit,
    act: (cubit) =>cubit.setGroupSeparator(false),
    verify: (cubit) {
      expect(cubit.format(100000), '100 000.000');
      expect(cubit.formatCurrency(100000, '\$'), '\$ 100 000.000');
    },
  );

  blocTest<SettingsCubit, SettingsState>(
    'Symbol at end works correctly',
    build: () => settingsCubit,
    act: (cubit) =>cubit.setSymbolPosition(false),
    verify: (cubit) {
      expect(cubit.formatCurrency(10, '\$'), '10.000 \$');
    },
  );

}
