// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ApiMapService.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// ignore_for_file: always_put_control_body_on_new_line, always_specify_types, prefer_const_declarations
class _$ApiMapService extends ApiMapService {
  _$ApiMapService([ChopperClient client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final definitionType = ApiMapService;

  @override
  Future<Response<dynamic>> getAutoComplete(
      {String input, String lang, String apiKey, String sessionToken}) {
    final $url =
        'autocomplete/json?input=$input&language=$lang&components=country:ph&key=$apiKey&sessiontoken=$sessionToken';
    final $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }
}
