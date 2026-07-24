import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrPassport extends StatelessWidget {
  final String data;

  const QrPassport({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: QrImageView(
        data: data,
        version: QrVersions.auto,
        size: 200.0,
        backgroundColor: Colors.white,
        errorCorrectionLevel: QrErrorCorrectLevel.L, // Keep it simple and scannable
      ),
    );
  }
}
