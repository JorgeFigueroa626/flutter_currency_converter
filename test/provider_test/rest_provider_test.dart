import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:my_app_calculadora/src/provider/rest_provider.dart';

void main() {

  test('Latest api will return correctly', () async {
    final provider = _getProvider('test/provider_test/latest.json');
    final result = await provider.latest();
    final currency = result.item1;
    final timestamp = result.item2;

    expect(currency.length, 2);
    expect(currency['AED'], 4.338252);
    expect(currency['AFN'], 91.224956);
    expect(timestamp, 1519296206);
  });

  test('Symbols api will return correctly', () async {
    final provider = _getProvider('test/provider_test/symbols.json');
    final result = await provider.symbols();

    expect(result.length, 2);
    expect(result['AED'], 'United Arab Emirates Dirham');
    expect(result['AFN'], 'Afghan Afghani');

  });

  test('Access key invalid exception is thrown correctly', () async {
    final provider = _getProvider('test/provider_test/access_key_invalid.json');

    expect(provider.latest(), throwsA(predicate((exception) => exception is InvalidApiKeyException)));
  });

}

RestProvider _getProvider(String filePath) => RestProvider(httpClient: _getMockProvider(filePath));

MockClient _getMockProvider(String filePath) =>
    MockClient((_) async => Response(await File(filePath).readAsString(), 200, headers: headers));

final headers = {HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'};