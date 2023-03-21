import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  String prettyDate() => DateFormat('dd/MMM/yyyy hh:mm a').format(this);
}
