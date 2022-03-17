import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
// import 'dart:convert';
import 'dart:io';
// import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'main.dart';

class InAppWebViewExampleScreen extends StatefulWidget {
  const InAppWebViewExampleScreen({Key? key}) : super(key: key);

  @override
  _InAppWebViewExampleScreenState createState() =>
      _InAppWebViewExampleScreenState();
}

class _InAppWebViewExampleScreenState extends State<InAppWebViewExampleScreen> {
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  late PullToRefreshController pullToRefreshController;
  late ContextMenu contextMenu;
  String url = "";
  double progress = 0;
  final urlController = TextEditingController();
 

  @override
  void initState() {
    super.initState();

    contextMenu = ContextMenu(
        menuItems: [
          ContextMenuItem(
              androidId: 1,
              iosId: "1",
              title: "Special",
              action: () async {
                print("Menu item Special clicked!");
                print(await webViewController?.getSelectedText());
                await webViewController?.clearFocus();
              })
        ],
        options: ContextMenuOptions(hideDefaultSystemContextMenuItems: false),
        onCreateContextMenu: (hitTestResult) async {
          print("onCreateContextMenu");
          print(hitTestResult.extra);
          print(await webViewController?.getSelectedText());
        },
        onHideContextMenu: () {
          print("onHideContextMenu");
        },
        onContextMenuActionItemClicked: (contextMenuItemClicked) async {
          var id = (Platform.isAndroid)
              ? contextMenuItemClicked.androidId
              : contextMenuItemClicked.iosId;
          print("onContextMenuActionItemClicked: " +
              id.toString() +
              " " +
              contextMenuItemClicked.title);
        });

    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          webViewController?.reload();
        } else if (Platform.isIOS) {
          webViewController?.loadUrl(
              urlRequest: URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  // final Completer<WebViewController> _controller =
  //     Completer<WebViewController>();

  // @override
  // void initState() {
  //   super.initState();
  //   if (Platform.isAndroid) {
  //     WebView.platform = SurfaceAndroidWebView();
  //   }
  // }

  @override
  Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(body: Builder(
//         builder: (BuildContext context) {
//           return InAppWebView(
//   initialFile: "assets/index.html",
//   initialHeaders: {},
//   initialOptions: InAppWebViewWidgetOptions(
//     inAppWebViewOptions: InAppWebViewOptions(
//         debuggingEnabled: true,
//     )
//   ),
//   onWebViewCreated: (InAppWebViewController controller) {
//     webView = controller;

//     controller.addJavaScriptHandler(handlerName: "mySum", callback: (args) {
//       // Here you receive all the arguments from the JavaScript side
//       // that is a List<dynamic>
//       print("From the JavaScript side:");
//       print(args);
//       return args.reduce((curr, next) => curr + next);
//     });
//   },
//   onLoadStart: (InAppWebViewController controller, String url) {

//   },
//   onLoadStop: (InAppWebViewController controller, String url) {

//   },
//   onConsoleMessage: (InAppWebViewController controller, ConsoleMessage consoleMessage) {
//     print("console message: ${consoleMessage.message}");
//   },
// );
//         },
//       )),
//     );
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: <Widget>[
            Expanded(
              child: Stack(
                children: [
                  InAppWebView(
                    key: webViewKey,
                    // contextMenu: contextMenu,
                    initialUrlRequest: URLRequest(
                        url: Uri.parse(
                            "https://9424-59-99-1-29.ngrok.io/src/iframe.html")),
                    // initialFile: "assets/index.html",
                    initialUserScripts: UnmodifiableListView<UserScript>([]),
                    initialOptions: options,
                    pullToRefreshController: pullToRefreshController,
                    onWebViewCreated: (controller) {
                      webViewController = controller;
                      // webViewController?.addJavaScriptHandler(
                      //     handlerName: 'message',
                      //     callback: (args) {
                      //       log(args.toString());
                      //       // json.decode(args);
                      //       // log(json.decode(args).toString());
                      //       return {
                      //         'target': 'readyplayerme',
                      //         'type': 'subscribe',
                      //         'eventName': 'v1.**'
                      //       };
                      //     });
                    },
                    onLoadStart: (controller, url) {
                      setState(() {
                        this.url = url.toString();
                        urlController.text = this.url;
                      });
                    },
                    androidOnPermissionRequest:
                        (controller, origin, resources) async {
                      return PermissionRequestResponse(
                          resources: resources,
                          action: PermissionRequestResponseAction.GRANT);
                    },

                    onLoadStop: (controller, url) async {
                      //           var result = await controller.evaluateJavascript(
                      //               source: """
                      //          window.removeEventListener('message', subscribe);
                      //     window.addEventListener('message', subscribe);

                      //     function subscribe(event) {

                      //         // post message v1, this will be deprecated
                      //         if(event.data.endsWith('.glb')) {
                      //             document.querySelector(".content").remove();
                      //             WebView.receiveData(event.data)
                      //         }
                      //         // post message v2
                      //         else {
                      //             const json = parse(event);
                      //             const source = json.source;

                      //             if (source !== 'readyplayerme') {
                      //               return;
                      //             }

                      //             document.querySelector(".content").remove();
                      //             WebView.receiveData(event.data)
                      //         }
                      //     }
                      //     function parse(event) {
                      //         try {
                      //             return JSON.parse(event.data);
                      //         } catch (error) {
                      //             return null;
                      //         }
                      //     }

                      //     window.postMessage(
                      //         JSON.stringify({
                      //             target: 'readyplayerme',
                      //             type: 'subscribe',
                      //             eventName: 'v1.**'
                      //         }),
                      //         '*'
                      //     );

                      // """
                      //                   .trim());

                      // log(result.toString());
                      pullToRefreshController.endRefreshing();
                      setState(() {
                        this.url = url.toString();
                        urlController.text = this.url;
                      });
                    },
                    onLoadError: (controller, url, code, message) {
                      pullToRefreshController.endRefreshing();
                    },
                    onProgressChanged: (controller, progress) {
                      if (progress == 100) {
                        pullToRefreshController.endRefreshing();
                      }
                      setState(() {
                        this.progress = progress / 100;
                        urlController.text = this.url;
                      });
                    },
                    onUpdateVisitedHistory: (controller, url, androidIsReload) {
                      setState(() {
                        this.url = url.toString();
                        urlController.text = this.url;
                      });
                    },

                    onConsoleMessage: (controller, consoleMessage) {
                      log(consoleMessage.message
                          .contains('Avatar URL')
                          .toString());
                      if (consoleMessage.message.contains('Avatar URL')) {
                        log(consoleMessage.message.split(':')[1]);
                        Navigator.of(context).pushNamed('/InAppBrowser');
                      }
                      // log(consoleMessage.message.toString());

                      // print(consoleMessage.message);
                      // print(consoleMessage.message);
                      // log(consoleMessage.messageLevel.toString());
                      // if (consoleMessage.message == 'true') {
                      //   showDialog<bool>(
                      //     context: context,
                      //     barrierDismissible: false,
                      //     builder: (BuildContext context) {
                      //       return AlertDialog(
                      //         contentPadding: EdgeInsets.all(0),
                      //         content: Container(
                      //           height:
                      //               MediaQuery.of(context).size.height * 0.25,
                      //           width: MediaQuery.of(context).size.width * 0.60,
                      //           decoration: BoxDecoration(
                      //             color: Colors.transparent,
                      //           ),
                      //           padding: EdgeInsets.symmetric(
                      //             horizontal: 10.0,
                      //             vertical: 20.0,
                      //           ),
                      //           child: Column(
                      //             mainAxisAlignment:
                      //                 MainAxisAlignment.spaceBetween,
                      //             children: [
                      //               Text('Well done'),
                      //             ],
                      //           ),
                      //         ),
                      //       );
                      //     },
                      //   );
                      // }
                    },
                  ),
                  progress < 1.0
                      ? LinearProgressIndicator(value: progress)
                      : Container(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
