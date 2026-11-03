import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../data_sources/remote/payment_remote_data_source.dart';

/// What came back from Flutterwave's redirect. [transactionId] is what the backend needs to
/// verify the payment; [cancelled] is true when the user closed the page or Flutterwave
/// reported `status=cancelled`.
class CheckoutResult {
  final String? transactionId;
  final String? status;
  bool get cancelled => transactionId == null || status == 'cancelled';
  CheckoutResult({this.transactionId, this.status});
}

/// Hosted Flutterwave checkout in a WebView. The card/bank/USSD details are entered on
/// Flutterwave's page, never in this app. When Flutterwave redirects to the backend-chosen
/// callback URL (`<frontend>/payment/flutterwave/callback?...&transaction_id=..&status=..`),
/// the redirect is intercepted, the page closes, and the result is returned to the caller,
/// which then asks the backend to verify it.
class FlutterwaveCheckoutScreen extends StatefulWidget {
  final CheckoutSession session;
  const FlutterwaveCheckoutScreen({super.key, required this.session});

  static Future<CheckoutResult> open(BuildContext context, CheckoutSession session) async {
    final result = await Navigator.of(context).push<CheckoutResult>(
      MaterialPageRoute(builder: (_) => FlutterwaveCheckoutScreen(session: session), fullscreenDialog: true),
    );
    return result ?? CheckoutResult();
  }

  @override
  State<FlutterwaveCheckoutScreen> createState() => _FlutterwaveCheckoutScreenState();
}

class _FlutterwaveCheckoutScreenState extends State<FlutterwaveCheckoutScreen> {
  late final WebViewController _controller;
  int _progress = 0;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onProgress: (p) => mounted ? setState(() => _progress = p) : null,
        onNavigationRequest: (request) {
          final uri = Uri.tryParse(request.url);
          if (uri != null && uri.path.endsWith(widget.session.callbackPath)) {
            _finish(CheckoutResult(
              transactionId: uri.queryParameters['transaction_id'],
              status: uri.queryParameters['status'],
            ));
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse(widget.session.link));
  }

  void _finish(CheckoutResult result) {
    if (_finished || !mounted) return;
    _finished = true;
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Secure payment'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Cancel payment',
          onPressed: () => _finish(CheckoutResult(status: 'cancelled')),
        ),
        bottom: _progress < 100
            ? PreferredSize(
                preferredSize: const Size.fromHeight(2),
                child: LinearProgressIndicator(value: _progress / 100),
              )
            : null,
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
