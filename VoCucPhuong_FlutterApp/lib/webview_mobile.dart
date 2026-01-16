import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart' as wv;

class WebViewWidget extends StatefulWidget {
  final String url;
  final Color color;
  final String? title;

  const WebViewWidget({
    super.key,
    required this.url,
    required this.color,
    this.title,
  });

  @override
  State<WebViewWidget> createState() => _WebViewWidgetState();
}

class _WebViewWidgetState extends State<WebViewWidget>
    with AutomaticKeepAliveClientMixin {
  late final wv.WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;
  int _loadingProgress = 0;
  bool _canGoBack = false;
  bool _canGoForward = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _controller = wv.WebViewController()
      ..setJavaScriptMode(wv.JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..enableZoom(true)
      ..setNavigationDelegate(
        wv.NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
                _hasError = false;
                _loadingProgress = 0;
              });
            }
          },
          onProgress: (int progress) {
            if (mounted) {
              setState(() {
                _loadingProgress = progress;
              });
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              _updateNavigationState();
              setState(() {
                _isLoading = false;
              });
              // Inject mobile optimization CSS
              _injectMobileOptimizations();
            }
          },
          onWebResourceError: (wv.WebResourceError error) {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _hasError = true;
              });
            }
          },
          onNavigationRequest: (wv.NavigationRequest request) {
            // Cho phép tất cả navigation
            return wv.NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  Future<void> _updateNavigationState() async {
    final canGoBack = await _controller.canGoBack();
    final canGoForward = await _controller.canGoForward();
    if (mounted) {
      setState(() {
        _canGoBack = canGoBack;
        _canGoForward = canGoForward;
      });
    }
  }

  Future<void> _injectMobileOptimizations() async {
    // Inject CSS để tối ưu cho mobile
    await _controller.runJavaScript('''
      (function() {
        var style = document.createElement('style');
        style.textContent = `
          /* Tăng kích thước touch target - tối thiểu 44px */
          a, button, input, select, textarea, [role="button"] {
            min-height: 44px !important;
          }

          /* Cải thiện scroll */
          * {
            -webkit-overflow-scrolling: touch !important;
          }

          /* Disable double-tap zoom trên các nút */
          button, a, input[type="button"], input[type="submit"] {
            touch-action: manipulation;
          }

          /* Cải thiện font rendering */
          body {
            -webkit-font-smoothing: antialiased;
            text-rendering: optimizeLegibility;
          }
        `;
        document.head.appendChild(style);
      })();
    ''');
  }

  void _reload() {
    setState(() {
      _hasError = false;
      _isLoading = true;
    });
    _controller.reload();
  }

  Future<void> _goBack() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
      _updateNavigationState();
    }
  }

  Future<void> _goForward() async {
    if (await _controller.canGoForward()) {
      await _controller.goForward();
      _updateNavigationState();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    if (_hasError) {
      return _buildErrorWidget();
    }

    return Stack(
      children: [
        // WebView
        Positioned.fill(
          child: wv.WebViewWidget(controller: _controller),
        ),

        // Loading overlay
        if (_isLoading) _buildLoadingWidget(),

        // Progress bar at top
        if (_isLoading)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              value: _loadingProgress / 100,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(widget.color),
              minHeight: 3,
            ),
          ),

        // Navigation controls - floating buttons
        Positioned(
          bottom: isLandscape ? 16 : 80 + bottomPadding,
          right: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Refresh button
              _buildFloatingButton(
                icon: Icons.refresh,
                onPressed: _reload,
                tooltip: 'Tải lại',
              ),
              const SizedBox(height: 8),
              // Forward button (chỉ hiện khi có thể forward)
              if (_canGoForward)
                _buildFloatingButton(
                  icon: Icons.arrow_forward,
                  onPressed: _goForward,
                  tooltip: 'Tiến',
                ),
              if (_canGoForward) const SizedBox(height: 8),
              // Back button (chỉ hiện khi có thể back)
              if (_canGoBack)
                _buildFloatingButton(
                  icon: Icons.arrow_back,
                  onPressed: _goBack,
                  tooltip: 'Quay lại',
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(22),
      color: widget.color.withOpacity(0.9),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(22),
        child: Tooltip(
          message: tooltip,
          child: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            child: Icon(
              icon,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Logo
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: widget.color.withAlpha(25),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.directions_bus_rounded,
                size: 45,
                color: widget.color,
              ),
            ),
            const SizedBox(height: 24),
            // Progress indicator
            SizedBox(
              width: 200,
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: _loadingProgress / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(widget.color),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Đang tải${widget.title != null ? ' ${widget.title}' : ''}... $_loadingProgress%',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Icons.wifi_off_rounded,
                  size: 50,
                  color: Colors.red[400],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Không thể kết nối',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Vui lòng kiểm tra kết nối mạng\nvà thử lại',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _reload,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
