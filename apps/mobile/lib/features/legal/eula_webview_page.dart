import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

class EulaWebViewPage extends StatefulWidget {
  const EulaWebViewPage({super.key});

  @override
  State<EulaWebViewPage> createState() => _EulaWebViewPageState();
}

class _EulaWebViewPageState extends State<EulaWebViewPage> {
  static const String _eulaUrl =
      'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/';

  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) {
              setState(() {
                _isLoading = true;
              });
            }
          },
          onPageFinished: (_) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onWebResourceError: (_) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(_eulaUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08111F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF08111F),
        foregroundColor: Colors.white,
        title: const Text(
          'Terms of Use (EULA)',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: kIsWeb
            ? _buildWebFallback(context)
            : Stack(
                children: [
                  WebViewWidget(controller: _controller),
                  if (_isLoading)
                    const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _buildWebFallback(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.open_in_browser,
              color: Colors.white,
              size: 44,
            ),
            const SizedBox(height: 16),
            const Text(
              'The EULA opens on supported mobile platforms.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 12),
            SelectableText(
              _eulaUrl,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}
