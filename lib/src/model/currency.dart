
import 'package:equatable/equatable.dart';

class Currency extends Equatable{
  final String key;
  final String name;
  final num value;
  final int timestamp;

  final bool isEnabled;
  final int position;

  Currency(this.key, this.name, this.value, this.timestamp, {this.position = -1,this.isEnabled=false});

  bool get isBase => key == 'EUR';

  @override
  List<Object?> get props => [key, value, timestamp, isEnabled];

  Map<String, dynamic> toMapDB(){
    return <String, dynamic>{
      'key': key,
      'name': name,
      'value': value,
      'timestamp': timestamp,
    };
  }

  Currency.fromMapDB(Map<String, dynamic> dbData):
        key = dbData['key'],
        name = dbData['name'],
        value = dbData['value'],
        timestamp = dbData['timestamp'],
        isEnabled = dbData['isEnabled'] == 1,
        position = dbData['position'];
}