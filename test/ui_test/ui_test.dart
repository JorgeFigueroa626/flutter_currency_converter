import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app_calculadora/src/bloc/navigation_cubit.dart';
import 'package:my_app_calculadora/src/repository/currency_repository.dart';
import 'package:my_app_calculadora/src/ui/bottom_bar.dart';
import 'package:my_app_calculadora/src/ui/converter_screen.dart';
import 'package:my_app_calculadora/src/ui/favorites_screen.dart';

import '../mocks/mock_currency_repository.dart';

void main() {
  late MockCurrencyRepository currencyRepository;

  setUp(() async {
    currencyRepository = MockCurrencyRepository();
  });

  Widget getApp({required Widget child}) {
    return RepositoryProvider<CurrencyRepositoryBase>(
      create: (_) => currencyRepository,
      child: BlocProvider(
        create: (_) => NavigationCubit(),
        child: MaterialApp(
          home: child,
        ),
      ),
    );
  }

  testWidgets('Test bottom widget navigate correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      getApp(
        child: Builder(
          builder: (context) => BottomBarWidget.create(context),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ConverterScreen), findsOneWidget);
    expect(find.byType(FavoritesScreen), findsNothing);

    await tester.tap(find.text(BottomNavItem.favorites.title));
    await tester.pumpAndSettle();
    
    expect(find.byType(ConverterScreen), findsNothing);
    expect(find.byType(FavoritesScreen), findsOneWidget);

  });

  testWidgets('Favorite Screen: Tapping a currency will disable/enable it',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      getApp(
        child: Builder(
          builder: (context) => FavoritesScreen.create(context),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(await currencyRepository.getEnabledCurrencyCount(), 6);

    await tester.tap(find.byKey(Key('USD')));
    await tester.pump();

    expect(await currencyRepository.getEnabledCurrencyCount(), 5);
  });

  testWidgets('Filter random text will only show selected currency',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      getApp(
        child: Builder(
          builder: (context) => FavoritesScreen.create(context),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ListTile), findsNWidgets(7));

    await tester.enterText(find.byType(TextFormField), 'a%kdQ2');
    await tester.pumpAndSettle();

    expect(find.byType(ListTile), findsNWidgets(1));
    expect(find.text('EUR (Selected currency)'), findsOneWidget);
  });

  testWidgets('Favorites screen will show defaults',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      getApp(
        child: Builder(
          builder: (context) => FavoritesScreen.create(context),
        ),
      ),
    );
    await tester.pumpAndSettle();

    Checkbox getCheckBox(String key) =>
        tester.firstWidget(find.byKey(Key(key)));

    expect(getCheckBox('EUR').value, true);
    expect(getCheckBox('CNY').value, true);
    expect(getCheckBox('USD').value, true);
    expect(getCheckBox('JPY').value, true);
    expect(getCheckBox('MXN').value, true);
    expect(getCheckBox('BOB').value, true);
  });

  testWidgets('Disabled currencies will in the convertor screen',
      (WidgetTester tester) async {
    await currencyRepository.disableCurrency('CNY');
    await currencyRepository.disableCurrency('USD');

    await tester.pumpWidget(
      getApp(
        child: Builder(
          builder: (context) => ConverterScreen.create(context),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('EUR'), findsOneWidget);
    expect(find.text('CNY'), findsNothing);
    expect(find.text('USD'), findsNothing);
    expect(find.text('JPY'), findsOneWidget);
    expect(find.text('MXN'), findsOneWidget);
    expect(find.text('BOB'), findsOneWidget);
  });
}
