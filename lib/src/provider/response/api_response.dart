import 'package:json_annotation/json_annotation.dart';

part 'api_response.g.dart';

@JsonSerializable()
class ApiResponse{
  late final bool success;
  late final int? timestamp;
  late final Map<String, num>? rates;
  late final  Map<String, String>? symbols;
  late final ApiResponseError? error;

  ApiResponse();

  factory ApiResponse.fromJson(Map<String, dynamic> json) => _$ApiResponseFromJson(json);

}
@JsonSerializable()
class ApiResponseError{
  late final int code;

  ApiResponseError();

  factory ApiResponseError.fromJson(Map<String, dynamic> json) => _$ApiResponseErrorFromJson(json);

}