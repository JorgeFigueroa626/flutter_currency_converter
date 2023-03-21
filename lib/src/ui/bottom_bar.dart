import 'package:equatable/equatable.dart';
// ignore: unnecessary_import
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app_calculadora/src/bloc/navigation_cubit.dart';
import 'package:my_app_calculadora/src/ui/converter_screen.dart';
import 'package:my_app_calculadora/src/ui/favorites_screen.dart';
import 'package:my_app_calculadora/src/ui/settings_screen.dart';

class BottomNavItem extends Equatable {
  static final converter = BottomNavItem._(0, 'Converter', Icons.money);
  static final favorites = BottomNavItem._(1, 'Favorites', Icons.favorite);
  static final settings = BottomNavItem._(2, 'Settings', Icons.settings);

  static List<BottomNavItem> get values => [converter, favorites, settings];

  final int index;
  final String title;
  final IconData icon;

  BottomNavItem._(this.index, this.title, this.icon);

  @override
  List<Object?> get props => [index, title];
}

class BottomBarWidget extends StatelessWidget {
  static Widget create(BuildContext context) {
    return BlocProvider(
      create: (_) => NavigationCubit(),
      child: BottomBarWidget(),
    );
  }

  Map<BottomNavItem, WidgetBuilder> get widgetBuilders {
    return {
      BottomNavItem.converter: (context) => ConverterScreen.create(context),
      BottomNavItem.favorites: (context) => FavoritesScreen.create(context),
      BottomNavItem.settings: (context) => SettingsScreen.create(context),
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, BottomNavItem>(
      builder: (context, state) => widgetBuilders[state]!(context),
    );
  }
}

class BottomNavBar extends StatelessWidget {
  final BottomNavItem currentItem;

  const BottomNavBar(this.currentItem);

  BottomNavigationBarItem getNavigationBarItem(BottomNavItem item) {
    return BottomNavigationBarItem(
      label: item.title,
      icon: Icon(item.icon),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentItem.index,
      onTap: (index) {
        final item = BottomNavItem.values.firstWhere((it) => it.index == index);
        context.read<NavigationCubit>().onChanged(item);
      },
      items: [
        getNavigationBarItem(BottomNavItem.converter),
        getNavigationBarItem(BottomNavItem.favorites),
        getNavigationBarItem(BottomNavItem.settings),
      ],
    );
  }
}
