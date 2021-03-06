// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ApiService.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// ignore_for_file: always_put_control_body_on_new_line, always_specify_types, prefer_const_declarations
class _$ApiService extends ApiService {
  _$ApiService([ChopperClient client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final definitionType = ApiService;

  @override
  Future<Response<dynamic>> requestInitData({String hash}) {
    final $url = '/resource/init/$hash';
    final $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getVehicleAddDetails(String code) {
    final $url = '/vehicle/vehicle-add-details/$code';
    final $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getVehicles({String uid}) {
    final $url = '/user/vehicles/$uid';
    final $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getVehicleAddAuthDetails(
      {String uid, String code}) {
    final $url = '/vehicle/owner/authorization/details/$uid/$code';
    final $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> addVehicle(dynamic uid, Map<String, dynamic> body) {
    final $url = '/user/addVehicle/$uid';
    final $body = body;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> generateShareCode(
      dynamic vehicleId, dynamic ownerId) {
    final $url = '/vehicle/generate-share-code/$vehicleId/$ownerId';
    final $request = Request('PATCH', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> addVehicleFromCode(
      dynamic newUserUid, dynamic code) {
    final $url = '/vehicle/add-from-code/$newUserUid/$code';
    final $request = Request('PATCH', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> authorizeVehicleAddition(
      dynamic ownerUid, dynamic code) {
    final $url = '/vehicle/authorize-vehicle-addition/$ownerUid/$code';
    final $request = Request('PATCH', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getWalletStatus({String uid}) {
    final $url = '/user/wallet-status/$uid';
    final $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> walletCashIn({Map<String, dynamic> data}) {
    final $url = '/admin/wallet/cash-in';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> walletCashOut({Map<String, dynamic> data}) {
    final $url = '/admin/wallet/cash-out';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getUserData({String uid}) {
    final $url = '/user/$uid';
    final $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getVerificationStatus({String uid}) {
    final $url = '/user/check-permissions/$uid';
    final $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getAllUser() {
    final $url = '/user/all';
    final $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getReservation({String reservationId}) {
    final $url = '/user/reservation/$reservationId';
    final $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getUserReservation({String uid}) {
    final $url = '/user/userReservations/$uid';
    final $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> registerUser(Map<String, dynamic> body) {
    final $url = '/user/register/true';
    final $body = body;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> bookLot(Map<String, dynamic> body) {
    final $url = '/user/book/';
    final $body = body;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> reserveLot(
      dynamic type, Map<String, dynamic> body) {
    final $url = '/user/reserve/$type';
    final $body = body;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getUserEmails(Map<String, dynamic> body) {
    final $url = '/user/find';
    final $body = body;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> payCredit(Map<String, dynamic> body) {
    final $url = '/user/payCredit/';
    final $body = body;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> rateLot(Map<String, dynamic> body) {
    final $url = '/user/rate-lot/';
    final $body = body;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> requestUserInfo(
      String jwt, Map<String, dynamic> body) {
    final $url = '/user/requestUserInfo';
    final $headers = {'firebase_auth_jwt': jwt};
    final $body = body;
    final $request =
        Request('POST', $url, client.baseUrl, body: $body, headers: $headers);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> checkExistence({String uid}) {
    final $url = '/user/google/$uid';
    final $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getNotifications({String uid}) {
    final $url = '/user/notifications/$uid';
    final $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> setNotificationAsSeen(
      {String uid, String notificationUid}) {
    final $url = '/user/notifications/$uid/$notificationUid';
    final $request = Request('PATCH', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> checkEmailUsage({String email}) {
    final $url = '/user/exists/$email';
    final $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> registerViaGoogle({String uid}) {
    final $url = '/user/register/google/$uid';
    final $request = Request('PATCH', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> registerDevice({String uid, String token}) {
    final $url = '/user/device/$uid/$token';
    final $request = Request('PATCH', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> unregisterDevice({String uid, String token}) {
    final $url = '/user/remove-device/$uid/$token';
    final $request = Request('PATCH', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> generateCode({String uid, String phoneNumber}) {
    final $url = '/user/generatecode/$uid/$phoneNumber';
    final $request = Request('PATCH', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> confirmCode({String uid, String code}) {
    final $url = '/user/confirmcode/$uid/$code';
    final $request = Request('PATCH', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> notifyOnTheWay(Map<String, dynamic> body) {
    final $url = '/user/notifications/notify-ontheway';
    final $body = body;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> notifyArrived(Map<String, dynamic> body) {
    final $url = '/user/notifications/notify-arrived';
    final $body = body;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getLotsInRadius(Map<String, dynamic> body) {
    final $url = '/partner/getLotsInRadius';
    final $body = body;
    final $request = Request('GET', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getLotFromAlgo(Map<String, dynamic> body) {
    final $url = '/partner/getLotFromAlgo';
    final $body = body;
    final $request = Request('GET', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getPartnerReservations({String uid}) {
    final $url = '/partner/partnerReservations/$uid';
    final $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getLot({String uid}) {
    final $url = '/partner/lot/$uid';
    final $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> markAsComplete(Map<String, dynamic> body) {
    final $url = '/partner/markAsComplete/';
    final $body = body;
    final $request = Request('GET', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> markAsCompleteV2(Map<String, dynamic> body) {
    final $url = '/partner/markAsCompleteV2/';
    final $body = body;
    final $request = Request('GET', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> findLotsFromRadius(Map<String, dynamic> body) {
    final $url = '/resource/lot/from-radius';
    final $body = body;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> rateDriver(Map<String, dynamic> body) {
    final $url = '/partner/rate-driver/';
    final $body = body;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> deleteImage(Map<String, dynamic> body) {
    final $url = '/upload/remove';
    final $body = body;
    final $request = Request('PUT', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }
}
