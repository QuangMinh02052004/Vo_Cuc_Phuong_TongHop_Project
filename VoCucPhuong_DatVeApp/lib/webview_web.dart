import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

class WebViewWidget extends StatefulWidget {
  final String url;
  final Color color;

  const WebViewWidget({
    super.key,
    required this.url,
    required this.color,
  });

  @override
  State<WebViewWidget> createState() => _WebViewWidgetState();
}

class _WebViewWidgetState extends State<WebViewWidget> {
  late String _viewId;

  @override
  void initState() {
    super.initState();
    _viewId = 'webview-${widget.url.hashCode}';

    // Register the iframe element
    ui_web.platformViewRegistry.registerViewFactory(
      _viewId,
      (int viewId) {
        final iframe = html.IFrameElement()
          ..src = widget.url
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%'
          ..allow = 'fullscreen';
        return iframe;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewId);
  }
}
