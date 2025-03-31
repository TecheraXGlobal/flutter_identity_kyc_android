// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';

// class IdentityKYCWebView extends StatelessWidget {
//   final String merchantKey;
//   final String email;
//   final String? firstName;
//   final String? lastName;
//   final String? userRef;
//   final String config;
//   final Function onCancel;
//   final Function onVerified;
//   final Function onError;

//   IdentityKYCWebView({
//     required this.merchantKey,
//     required this.email,
//     required this.config,
//     this.firstName,
//     this.lastName,
//     this.userRef,
//     required this.onCancel,
//     required this.onVerified,
//     required this.onError,
//   });

//   @override
//   Widget build(BuildContext context) {
//     InAppWebViewController _webViewController;
//     final GlobalKey<NavigatorState> navigatorKey =
//         GlobalKey<NavigatorState>();

//     return new WillPopScope(
//       onWillPop: () async => false,
//       child: Material(
//         type: MaterialType.transparency,
//         child: SafeArea(
//           child: Navigator(
//             key: navigatorKey,
//             onGenerateRoute: (settings) {
//               return MaterialPageRoute(
//                 builder: (context) => InAppWebView(
//                   initialUrlRequest: URLRequest(
//                     url: Uri.parse(
//                       "https://mobile.prembly.com/?merchantKey=" +
//                           merchantKey +
//                           "&firstName=" +
//                           firstName! +
//                           "&lastName=" +
//                           lastName! +
//                           "&email=" +
//                           email +
//                           "&config_id=" +
//                           config +
//                           "&user_ref=" +
//                           userRef! +
//                           "&isTest=false",
//                     ),
//                   ),
//                   initialOptions: InAppWebViewGroupOptions(
//                     crossPlatform: InAppWebViewOptions(
//                       mediaPlaybackRequiresUserGesture: false,
//                     ),
//                     ios: IOSInAppWebViewOptions(
//                       allowsInlineMediaPlayback: true,
//                     ),
//                   ),
//                   gestureRecognizers: {}..add(
//                     Factory<LongPressGestureRecognizer>(
//                       () => LongPressGestureRecognizer(),
//                     ),
//                   ),
//                   onWebViewCreated: (InAppWebViewController controller) {
//                     _webViewController = controller;
//                     _webViewController.addJavaScriptHandler(
//                       handlerName: 'message',
//                       callback: (args) {
//                         try {
//                           Map response = json.decode(args[0]);
//                           if (response.containsKey("event")) {
//                             switch (response["event"]) {
//                               case "closed":
//                                 onCancel({"status": "closed"});
//                                 break;
//                               case "error":
//                                 onError({
//                                   "status": "error",
//                                   "message": response['message'],
//                                 });
//                                 break;
//                               case "verified":
//                                 onVerified({
//                                   "status": "success",
//                                   "data": response,
//                                 });
//                                 break;
//                               default:
//                                 break;
//                             }
//                           }
//                         } catch (e) {
//                           print(e);
//                         }
//                       },
//                     );
//                   },
//                   androidOnPermissionRequest: (
//                     InAppWebViewController controller,
//                     String origin,
//                     List<String> resources,
//                   ) async {
//                     return PermissionRequestResponse(
//                       resources: resources,
//                       action: PermissionRequestResponseAction.GRANT,
//                     );
//                   },
//                   onLoadStop: (controller, url) async {
//                     await controller.evaluateJavascript(
//                       source: """
//                         window.addEventListener("message", (event) => {
//                           window.flutter_inappwebview
//                               .callHandler('message',event.data);
//                         }, false);
//                       """,
//                     );
//                   },
//                   onConsoleMessage: (
//                     InAppWebViewController controller,
//                     ConsoleMessage consoleMessage,
//                   ) {},
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class IdentityKYCWebView extends StatefulWidget {
  final String merchantKey;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? userRef;
  final String config;
  final Function onCancel;
  final Function onVerified;
  final Function onError;

  IdentityKYCWebView({
    required this.merchantKey,
    required this.email,
    required this.config,
    this.firstName,
    this.lastName,
    this.userRef,
    required this.onCancel,
    required this.onVerified,
    required this.onError,
  });

  @override
  _IdentityKYCWebViewState createState() => _IdentityKYCWebViewState();
}

class _IdentityKYCWebViewState extends State<IdentityKYCWebView> {
  late final WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (String url) async {
          // Inject JavaScript handler for message passing
          await _webViewController.runJavaScript("""
            window.addEventListener("message", (event) => {
              if (window.flutter_inappwebview) {
                window.flutter_inappwebview.postMessage(event.data);
              }
            }, false);
          """);
        },
      ))
      ..addJavaScriptChannel(
        'flutter_inappwebview',
        onMessageReceived: (JavaScriptMessage message) {
          try {
            Map response = json.decode(message.message);
            if (response.containsKey("event")) {
              switch (response["event"]) {
                case "closed":
                  widget.onCancel({"status": "closed"});
                  break;
                case "error":
                  widget.onError({
                    "status": "error",
                    "message": response['message'],
                  });
                  break;
                case "verified":
                  widget.onVerified({
                    "status": "success",
                    "data": response,
                  });
                  break;
                default:
                  break;
              }
            }
          } catch (e) {
            print(e);
          }
        },
      )
      ..loadRequest(Uri.parse(
        "https://mobile.prembly.com/?merchantKey=${widget.merchantKey}"
        "&firstName=${widget.firstName ?? ''}"
        "&lastName=${widget.lastName ?? ''}"
        "&email=${widget.email}"
        "&config_id=${widget.config}"
        "&user_ref=${widget.userRef ?? ''}"
        "&isTest=false",
      ));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Material(
        type: MaterialType.transparency,
        child: SafeArea(
          child: WebViewWidget(controller: _webViewController),
        ),
      ),
    );
  }
}
