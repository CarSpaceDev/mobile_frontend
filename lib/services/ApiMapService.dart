import 'package:chopper/chopper.dart';

part 'ApiMapService.chopper.dart';

//flutter packages pub run build_runner build --delete-conflicting-outputs
@ChopperApi(baseUrl: '')
abstract class ApiMapService extends ChopperService {
//  @Get(headers: {'abc':'cba'})
//  @Get(headers: {'Content-Type':'text/plain'})
//  //OR
//  Future<Response> getPosts(
//      @Header('header-name') String headerValue
//      );

//  @Get()
//  Future<Response> getPosts();
//
  @Get(path: 'autocomplete/json?input={input}&language={lang}&components=country:ph&key={apiKey}&sessiontoken={sessionToken}')
  Future<Response> getAutoComplete(
      {@Path('input') String input, @Path('lang') String lang, @Path('apiKey') String apiKey, @Path('sessionToken') String sessionToken});

  static ApiMapService create() {
    final client = ChopperClient(
        baseUrl: "https://maps.googleapis.com/maps/api/place/",
        services: [
          _$ApiMapService(),
        ],
        converter: JsonConverter());
    return _$ApiMapService(client);
  }
//query example
//  Future<Response> getPost(@Path('id') int id, @Query('q') String name);

}
