
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app_calculadora/src/ui/bottom_bar.dart';

class NavigationCubit extends Cubit<BottomNavItem> {
  NavigationCubit() : super(BottomNavItem.converter);

  void onChanged(BottomNavItem item) => emit(item);
}
