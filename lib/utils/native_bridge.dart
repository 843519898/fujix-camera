import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_module/config/app_env.dart';
import 'package:flutter_module/pages/vip/buy_vip_sheet.dart';
import 'package:flutter_module/utils/storage_util.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../services/common_service.dart'; // 接口
import 'dart:io';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_module/main.dart';  // 请确保这是你的根应用组件
import 'package:fluttertoast/fluttertoast.dart';

/// 原生通信桥接类
/// 用于处理 Flutter 与原生平台之间的通信
class NativeBridge {
  // 添加一个全局 key 用于获取 context
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // 定义一个静态的 MethodChannel 实例，用于与原生平台通信
  // 通道名称应该与原生端保持一致
  static const MethodChannel _channel = MethodChannel(
    'com.cx.flutter.native/channel',
  );

  /// 获取当前路由名称
  static Future<String?> getCurrentRoute() async {
    try {
      final context = navigatorKey.currentContext;
      if (context == null) return null;

      final route = ModalRoute.of(context);
      return route?.settings.name;
    } catch (e) {
      print('获取当前路由失败: $e');
      return null;
    }
  }

  static Future<bool> navigateToVideoClip(List arrPath) async {
    try {
      // 构建发送给原生的参数
      final Map<String, dynamic> arguments = {'arrPath': arrPath};

      // 调用原生方法并获取结果
      final bool result = await _channel.invokeMethod(
        'navigateToVideoClip',
        arguments,
      );
      return result;
    } on PlatformException catch (e) {
      print('跳转到原生页面失败: ${e.message}');
      return false;
    } catch (e) {
      print('跳转到原生页面出现异常: $e');
      return false;
    }
  }

  static Future<String> navigateDuplicateRemovalp(String path, String fgPath, String outputPath) async {
    try {
      // 构建发送给原生的参数
      final Map<String, dynamic> arguments = {'bgPath': path, 'fgPath': fgPath, 'outputPath': outputPath};

      // 调用原生方法并获取结果
      final String result = await _channel.invokeMethod(
        'navigateDuplicateRemovalp',
        arguments,
      );
      return result;
    } on PlatformException catch (e) {
      print('跳转到原生页面失败: ${e.message}');
      return '';
    } catch (e) {
      print('跳转到原生页面出现异常: $e');
      return '';
    }
  }

  /// 跳转到原生页面
  ///
  /// [pageName] - 要跳转的原生页面名称
  /// [params] - 传递给原生页面的参数
  ///
  /// 返回一个 Future<bool>，表示跳转是否成功
  static Future<bool> navigateToNativePage(String url) async {
    try {
      // 构建发送给原生的参数
      final Map<String, dynamic> arguments = {'url': url};

      // 调用原生方法并获取结果
      final bool result = await _channel.invokeMethod(
        'navigateToNativePage',
        arguments,
      );
      return result;
    } on PlatformException catch (e) {
      print('跳转到原生页面失败: ${e.message}');
      return false;
    } catch (e) {
      print('跳转到原生页面出现异常: $e');
      return false;
    }
  }

  // 关闭原生容器，ios需要用到
  static Future<bool> backNativePage() async {
    try {
      // 调用原生方法并获取结果
      final bool result = await _channel.invokeMethod(
        'backNativePage',
      );
      return result;
    } on PlatformException catch (e) {
      print('返回到原生页面失败: ${e.message}');
      return false;
    } catch (e) {
      print('返回到原生页面出现异常: $e');
      return false;
    }
  }
  // 显示带输入框的对话框
  static Future<void> testLogin() async {
    final context = navigatorKey.currentContext;
    if (context == null) return;
    TextEditingController nameController = TextEditingController();
    nameController.text = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcHBpZCI6IjEwMDA5IiwiZXhwIjoxNzUyMzg4MDkzLCJpYXQiOjE3NDk3OTYwOTMsImlkIjoxMDg4MzI5Mywia2lkIjoiVVNFUi1DTU0tMTA4ODMyOTMifQ.l9v2D1naVWfI3DhkfbGTexeTOlYSzO9oI3lomd2CRf4';
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // 用户必须点击按钮才能关闭对话框
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('请输入您的Token'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: '请输入您的Token'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('确定'),
              onPressed: () {
                String token = nameController.text;
                Map userInfo = {
                  'id': '10883293',
                  'token': token,
                  'nickname': '你很差',
                  'avatar':
                      'https://cdn-static.chanmama.com/sub-module/static-file/8/e/caaa4dc2fe',
                };
                StorageUtil.saveUserInfo(userInfo);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
