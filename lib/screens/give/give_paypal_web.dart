import 'package:flutter/material.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui' as ui;
import 'dart:html' as html;

class PayPalDonateButton extends StatelessWidget {
  final String givingType;
  const PayPalDonateButton({super.key, required this.givingType});

  @override
  Widget build(BuildContext context) {
    final url = 'https://www.paypal.com/donate?hosted_button_id=V56HCXFE46U5E&custom=${Uri.encodeComponent(givingType)}';
    final String viewType = 'paypal-donate-iframe-$givingType';
    // Register the view factory for each givingType
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      viewType,
      (int viewId) => html.IFrameElement()
        ..src = url
        ..style.border = 'none'
        ..width = '100%'
        ..height = '600',
    );
    return SizedBox(
      width: 400,
      height: 600,
      child: HtmlElementView(viewType: viewType),
    );
  }
}
