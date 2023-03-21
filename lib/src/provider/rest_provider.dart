import 'dart:convert';

import 'package:my_app_calculadora/src/provider/response/api_response.dart';
import 'package:http/http.dart' as http;
import 'package:tuple/tuple.dart';

class RestProvider{
  static const String _accessKey = 'HhmDf4snfksgDyjMBapY5KI1edFFSVoI';

  static const String _baseUrl = 'data.fixer.io';
  static const String _latest = '/api/latest';
  static const String _symbols = '/api/symbols';

  final http.Client _httpClient;

  RestProvider({http.Client? httpClient}) : _httpClient = httpClient ?? http.Client();

  Future<Tuple2<Map<String, num>, int>> latest() async {
    final result = await _callGetApi(
      endpoint: _latest,
      params: {
        'base' : 'EUR',
        'access_key' : _accessKey,

      },
    );
    return Tuple2(result.rates!, result.timestamp!);
  }

  Future<Map<String, String>> symbols() async {
    final result =await _callGetApi(
      endpoint: _symbols,
      params: {
        'access_key': _accessKey,
      },
    );
    return result.symbols!;
  }


  Future<ApiResponse> _callGetApi({
    required String endpoint,
    Map<String, String>? params,
  })async{
    final uri = Uri.http(_baseUrl, endpoint, params);

    final response = await _httpClient.get(uri);
    print(response.body);
    final result = ApiResponse.fromJson((json.decode(response.body)));

    if(!result.success){
      switch(result.error!.code){
        case 101:
          throw InvalidApiKeyException();
        case 104:
          throw RequestReachedException();
        case 201:
          throw InvalidBaseCurrency();
        default:
          throw Exception();
      }
    }
    return result;
  }
}

class InvalidApiKeyException implements Exception{
  final String message = 'No API Key was specified or an invalid API Key was specified.';
}

class RequestReachedException implements Exception{
  final String message = 'The maximum allowed API amount of monthly API requests has been reached.';
}

class InvalidBaseCurrency implements Exception{
  final String message = 'An invalid base currency has been entered.';
}