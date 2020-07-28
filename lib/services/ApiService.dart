import 'package:chopper/chopper.dart';
import 'package:carspace/constants/GlobalConstants.dart';

part 'ApiService.chopper.dart';

//flutter packages pub run build_runner build --delete-conflicting-outputs
@ChopperApi(baseUrl: '')
abstract class ApiService extends ChopperService {
//  @Get(headers: {'abc':'cba'})
//  @Get(headers: {'Content-Type':'text/plain'})
//  //OR
//  Future<Response> getPosts(
//      @Header('header-name') String headerValue
//      );

//  @Get()
//  Future<Response> getPosts();
//
//  @Get(path: '{id}')
//  Future<Response> getPost(@Path('id') int id);

  @Post(path: '/user/requestUserInfo')
  Future<Response> requestUserInfo(@Header('firebase_auth_jwt') String jwt,
      @Body() Map<String, dynamic> body);

  @Get(path: '/resource/init')
  Future<Response> requestInitData();

  @Get(path: '/user/all')
  Future<Response> getAllUser();

  @Post(path: '/user/register')
  Future<Response> registerUser(@Body() Map<String, dynamic> body);

  @Post(path: '/user/find')
  Future<Response> getUserEmails(@Body() Map<String, dynamic> body);

  @Post(path: '/resource/lot/from-radius')
  Future<Response> findLotsFromRadius(@Body() Map<String, dynamic> body);


  static ApiService create() {
    final client = ChopperClient(
        baseUrl: StringConstants.kApiUrl,
        services: [
          _$ApiService(),
        ],
        converter: JsonConverter());
    return _$ApiService(client);
  }
//query example
//  Future<Response> getPost(@Path('id') int id, @Query('q') String name);

}
