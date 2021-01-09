import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class VehicleTransferCodeScreen extends StatefulWidget {
  final VehicleTransferQrPayLoad payload;
  VehicleTransferCodeScreen({@required this.payload});
  @override
  _VehicleTransferCodeScreenState createState() => _VehicleTransferCodeScreenState(payload);
}

class _VehicleTransferCodeScreenState extends State<VehicleTransferCodeScreen> {
  final VehicleTransferQrPayLoad payload;
  Timer _timer;
  int _remainingTime;
  _VehicleTransferCodeScreenState(this.payload) {
    _remainingTime = int.parse(((payload.expiry - new DateTime.now().millisecondsSinceEpoch) / 1000).toStringAsFixed(0));
    _timer = new Timer.periodic(
      Duration(seconds: 1),
      (Timer timer) {
        if (_remainingTime == 0) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _remainingTime--;
          });
        }
      },
    );
  }
  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Material(
          child: Container(
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _remainingTime != 0
                    ? AspectRatio(aspectRatio: 1, child: payload.generateQR())
                    : AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                            child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.cancel),
                              Text(
                                "Code expired, please generate a new code",
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )),
                      ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [_remainingTime != 0 ? Text(_remainingTime.toString() + " seconds") : Text("")],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class VehicleTransferQrPayLoad {
  String code;
  int expiry;

  VehicleTransferQrPayLoad({@required this.code, @required this.expiry});

  QrImage generateQR() {
    return QrImage(data: this.code, version: QrVersions.auto);
  }
}
