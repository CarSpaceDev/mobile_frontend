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

  @Get(path: '/resource/init/{hash}')
  Future<Response> requestInitData({@Path('hash') String hash});

  //Vehicle Operations

  @Get(path: '/vehicle/vehicle-add-details/{code}')
  Future<Response> getVehicleAddDetails(@Path('code') String code);

  @Get(path: '/user/vehicles/{uid}')
  Future<Response> getVehicles({@Path('uid') String uid});

  @Get(path: '/vehicle/owner/authorization/details/{uid}/{code}')
  Future<Response> getVehicleAddAuthDetails(
      {@Path('uid') String uid, @Path('code') String code});

  @Post(path: '/user/addVehicle/{uid}')
  Future<Response> addVehicle(
      @Path('uid') uid, @Body() Map<String, dynamic> body);

  @Patch(path: '/vehicle/generate-share-code/{vehicleId}/{ownerId}')
  Future<Response> generateShareCode(
      @Path('vehicleId') vehicleId, @Path('ownerId') ownerId);

  @Patch(path: '/vehicle/add-from-code/{uid}/{code}')
  Future<Response> addVehicleFromCode(
      @Path('uid') newUserUid, @Path('code') code);

  @Patch(path: '/vehicle/authorize-vehicle-addition/{uid}/{code}')
  Future<Response> authorizeVehicleAddition(
      @Path('uid') ownerUid, @Path('code') code);
  //User Operations

  @Get(path: '/user/wallet-status/{uid}')
  Future<Response> getWalletStatus({@Path('uid') String uid});

  @Get(path: '/user/{uid}')
  Future<Response> getUserData({@Path('uid') String uid});

  @Get(path: '/user/check-permissions/{uid}')
  Future<Response> getVerificationStatus({@Path('uid') String uid});

  @Get(path: '/user/all')
  Future<Response> getAllUser();

  @Get(path: '/user/reservation/{reservationId}')
  Future<Response> getReservation(
      {@Path('reservationId') String reservationId});

  @Get(path: '/user/userReservations/{uid}')
  Future<Response> getUserReservation({@Path('uid') String uid});

  @Post(path: '/user/register/true')
  Future<Response> registerUser(@Body() Map<String, dynamic> body);

  @Post(path: '/user/book/')
  Future<Response> bookLot(@Body() Map<String, dynamic> body);

  @Post(path: '/user/reserve/{type}')
  Future<Response> reserveLot(
      @Path('type') uid, @Body() Map<String, dynamic> body);

  @Post(path: '/user/find')
  Future<Response> getUserEmails(@Body() Map<String, dynamic> body);

  @Post(path: '/user/requestUserInfo')
  Future<Response> requestUserInfo(@Header('firebase_auth_jwt') String jwt,
      @Body() Map<String, dynamic> body);

  @Get(path: '/user/google/{uid}')
  Future<Response> checkExistence({@Path('uid') String uid});

  @Get(path: '/user/notifications/{uid}')
  Future<Response> getNotifications({@Path('uid') String uid});

  @Patch(path: '/user/notifications/{uid}/{nUid}')
  Future<Response> setNotificationAsSeen(
      {@Path('uid') String uid, @Path('nUid') String notificationUid});

  @Get(path: '/user/exists/{email}')
  Future<Response> checkEmailUsage({@Path('email') String email});

  @Patch(path: '/user/register/google/{uid}')
  Future<Response> registerViaGoogle({@Path('uid') String uid});

  @Patch(path: '/user/device/{uid}/{token}')
  Future<Response> registerDevice(
      {@Path('uid') String uid, @Path('token') String token});

  @Patch(path: '/user/remove-device/{uid}/{token}')
  Future<Response> unregisterDevice(
      {@Path('uid') String uid, @Path('token') String token});

  @Patch(path: '/user/generatecode/{uid}/{phoneNumber}')
  Future<Response> generateCode(
      {@Path('uid') String uid, @Path('phoneNumber') String phoneNumber});

  @Patch(path: '/user/confirmcode/{uid}/{code}')
  Future<Response> confirmCode(
      {@Path('uid') String uid, @Path('code') String code});

  @Post(path: '/user/notifications/notify-ontheway')
  Future<Response> notifyOnTheWay(@Body() Map<String, dynamic> body);

  @Post(path: '/user/notifications/notify-arrived')
  Future<Response> notifyArrived(@Body() Map<String, dynamic> body);

  //Partner Operations

  @Get(path: '/partner/getLotsInRadius')
  Future<Response> getLotsInRadius(@Body() Map<String, dynamic> body);

  @Get(path: '/partner/getLotFromAlgo')
  Future<Response> getLotFromAlgo(@Body() Map<String, dynamic> body);

  @Get(path: '/partner/partnerReservations/{uid}')
  Future<Response> getPartnerReservations({@Path('uid') String uid});

  @Get(path: '/partner/lot/{uid}')
  Future<Response> getLot({@Path('uid') String uid});

  @Get(path: '/partner/markAsComplete/')
  Future<Response> markAsComplete(@Body() Map<String, dynamic> body);

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
