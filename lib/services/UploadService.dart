import 'package:carspace/constants/GlobalConstants.dart';
import 'package:chopper/chopper.dart';

abstract class UploadService extends ChopperService {
  Future<Response> uploadItemImage(
    String image,
  );

  static UploadService create() {
    final client = ChopperClient(
        baseUrl: StringConstants.kApiUrl,
        services: [
          _$UploadService(),
        ],
        converter: JsonConverter());
    return _$UploadService(client);
  }
}

class _$UploadService extends UploadService {
  _$UploadService([ChopperClient client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final definitionType = UploadService;

  @override
  Future<Response<dynamic>> uploadItemImage(image) {
    final $url = 'upload/image';
    List<dynamic> $parts;
    $parts = <PartValue>[
      PartValueFile<String>('media', image),
    ];
    final $request =
        Request('POST', $url, client.baseUrl, parts: $parts, multipart: true);
    return client.send<dynamic, dynamic>($request);
  }
}
