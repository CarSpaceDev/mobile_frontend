import 'package:carspace/constants/GlobalConstants.dart';
import 'package:chopper/chopper.dart';

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
  Future<Response> requestUserInfo(@Header('firebase_auth_jwt') String jwt, @Body() Map<String, dynamic> body);

  @Get(path: '/resource/init/{hash}')
  Future<Response> requestInitData({@Path('hash') String hash});

  @Get(path: '/user/google/{uid}')
  Future<Response> checkExistence({@Path('uid') String uid});

  @Get(path: '/user/vehicles/{uid}')
  Future<Response> getVehicles({@Path('uid') String uid});

  @Get(path: '/user/exists/{email}')
  Future<Response> checkEmailUsage({@Path('email') String email});

  @Patch(path: '/user/register/google/{uid}')
  Future<Response> registerViaGoogle({@Path('uid') String uid});

  @Patch(path: '/user/device/{uid}/{token}')
  Future<Response> registerDevice({@Path('uid') String uid, @Path('token') String token});

  @Patch(path: '/user/generatecode/{uid}/{phoneNumber}')
  Future<Response> generateCode({@Path('uid') String uid, @Path('phoneNumber') String phoneNumber});

  @Patch(path: '/user/confirmcode/{uid}/{code}')
  Future<Response> confirmCode({@Path('uid') String uid, @Path('code') String code});

  @Post(path: '/user/addVehicle/{uid}')
  Future<Response> addVehicle(@Path('uid') uid, @Body() Map<String, dynamic> body);

  @Patch(path: '/vehicle/generate-share-code/{vehicleId}/{ownerId}')
  Future<Response> generateShareCode(@Path('vehicleId') vehicleId, @Path('ownerId') ownerId);

  @Get(path: '/user/all')
  Future<Response> getAllUser();

  @Get(path: '/partner/radius/{latitude}/{longitude}/{radiusInKm}')
  Future<Response> getLotsInRadius({@Path('latitude') double latitude, @Path('longitude') double longitude, @Path('radiusInKm') double kmRadius});

  @Post(path: '/user/register/true')
  Future<Response> registerUser(@Body() Map<String, dynamic> body);

  @Post(path: '/user/find')
  Future<Response> getUserEmails(@Body() Map<String, dynamic> body);

  @Post(path: '/resource/lot/from-radius')
  Future<Response> findLotsFromRadius(@Body() Map<String, dynamic> body);

  @Put(path: '/upload/remove')
  Future<Response> deleteImage(@Body() Map<String, dynamic> body);

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
