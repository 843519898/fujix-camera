import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io' show Platform;
import '../routes/route_name.dart';

class UrlLauncherUtil {
  /// 使用系统浏览器打开URL
  static Future<bool> launchInBrowser(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(
          uri,
          mode: LaunchMode.externalApplication, // 使用系统浏览器打开
        );
      } else {
        Fluttertoast.showToast(
          msg: "无法打开链接: $url",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
        return false;
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "打开链接出错: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
      return false;
    }
  }

  /// 使用内置浏览器在应用内打开URL（内嵌系统浏览器）
  static Future<bool> launchInAppBrowser(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(
          uri,
          mode: LaunchMode.inAppWebView, // 使用内置浏览器在应用内打开
          webViewConfiguration: const WebViewConfiguration(
            enableJavaScript: true,
            enableDomStorage: true,
          ),
        );
      } else {
        Fluttertoast.showToast(
          msg: "无法打开链接: $url",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
        return false;
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "打开链接出错: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
      return false;
    }
  }

  /// 尝试使用系统浏览器打开抖音视频链接
  static Future<bool> openDouyinVideo(String awemeIdOri) async {
    final String url = 'https://m.douyin.com/share/video/$awemeIdOri';
    return await launchInBrowser(url);
  }

  /// 尝试使用内置浏览器在应用内打开抖音视频链接
  static Future<bool> openDouyinVideoInApp(String awemeIdOri, context) async {
    if (Platform.isIOS) {
      final String url = 'https://m.douyin.com/share/video/$awemeIdOri';
      await launchInAppBrowser(url);
    } else if (Platform.isAndroid) {
      // Navigator.pushNamed(
      //   context,
      //   RouteName.webView,
      //   arguments: {
      //     'url': 'https://m.douyin.com/share/video/$awemeIdOri',
      //     'title': '抖音视频',
      //   },
      // );
    }
    return true;
  }

  static Future<bool> openOutlink(String url, String title, context) async {
    if (Platform.isIOS) {
      await launchInAppBrowser(url);
    } else if (Platform.isAndroid) {
      // Navigator.pushNamed(
      //   context,
      //   RouteName.webView,
      //   arguments: {'url': url, 'title': title},
      // );
    }
    return true;
  }
}
