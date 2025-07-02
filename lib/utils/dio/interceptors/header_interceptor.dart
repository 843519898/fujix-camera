import 'package:dio/dio.dart';
import '../../../utils/storage_util.dart';
import 'package:uuid/uuid.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_module/pages/vip/buy_vip_sheet.dart';
// import 'package:flutter_module/pages/chandou_center/buy_chandou_sheet.dart';
// import 'package:flutter_module/utils/native_bridge.dart';
// import 'package:flutter_module/utils/event_bus.dart';
// import 'package:flutter_module/models/vip_event.dart';

class HeaderInterceptors extends InterceptorsWrapper {
  String generateClientId() {
    final uuid = Uuid().v4(); // 生成UUID
    // 取UUID的哈希值并转换为10位数字
    final hash = uuid.hashCode.abs();
    return (hash % 9000000000 + 1000000000).toString();
  }

  // 请求拦截
  @override
  onRequest(RequestOptions options, handler) async {
    // options.baseUrl = ''; // 不要覆盖在 _initDio 中设置的 baseUrl
    // 添加固定请求头
    options.headers['x-platform-id'] = '10055';
    options.headers['x-client-id'] = generateClientId();
    options.headers['User-Agent'] = Platform.isIOS ? 'chankuaijian-ios' : 'chankuaijian-android';
    // options.headers['content-type'] = 'application/json';

    String token = '';
    print(options.extra);
    final Map userInfo = await StorageUtil.getUserInfo();
    token = userInfo['token'] ?? '';
    final String strogeToken = await StorageUtil.getToken();
    print('token-authorization:$token');
    // Fluttertoast.showToast(
    //     msg: token,
    //     toastLength: Toast.LENGTH_SHORT,
    //     gravity: ToastGravity.CENTER,
    //     timeInSecForIosWeb: 1,
    //     fontSize: 16.0
    // );
    // 从用户信息中获取token并设置到请求头
    // options.headers['accept-encoding'] = 'gzip';
    final t = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcHBpZCI6IjEwMDA5IiwiZXhwIjoxNzUyMzg4MDkzLCJpYXQiOjE3NDk3OTYwOTMsImlkIjoxMDg4MzI5Mywia2lkIjoiVVNFUi1DTU0tMTA4ODMyOTMifQ.l9v2D1naVWfI3DhkfbGTexeTOlYSzO9oI3lomd2CRf4';
    // options.headers['x-authorization-cx'] = token != '' ? token : strogeToken;
    // if (Platform.isIOS || Platform.isAndroid) {
    //
    // }
    options.headers['x-authorization-cx'] = t;

    options.headers['x-channel-id'] = Platform.isIOS ? 2 : 1;

    return handler.next(options);
  }

  // 响应拦截
  // @override
  // onResponse(response, handler) {
  //   // Do something with response data
  //   return handler.next(jsonDecode(jsonEncode(response))); // continue
  // }
  //
  // // 请求失败拦截
  @override
  onError(err, handler) async {
    // final context = NativeBridge.navigatorKey.currentContext;
    // if (context == null) {
    //   print('Context is null from native call');
    //   return;
    // }
    print('1111111111111${err.response}');
    Response<dynamic> response = err.response!;
    final res = jsonDecode(response.data);
    print('2222222222${res}');
    // EventBus().emit('vip_purchase', VipEvent(success: true));
    Future.delayed(Duration(milliseconds: 300), () async {
      if (res['code'] == '4001') {
        // await BuyVipSheet.show(
        //   context,
        //   onClose: () {
        //     print('关闭会员弹窗');
        //   },
        //   onOk: () {
        //     print('打开会员弹窗成功');
        //   },
        // );
      } else if (res['code'] == '4002') {
        // BuyChandouSheet.show(context, onClose: () {}, onOk: () {});
      } else if (err.response?.statusCode != 200) {
        Response<dynamic> response = err.response!;
        // 直接尝试获取响应中的msg
        String errorMsg = '';
        final res = jsonDecode(response.data);
        try {
          if (response.data != null) {
            // 尝试直接从响应中获取msg
            errorMsg = res['msg'];
          } else {
            errorMsg = 'Server Error';
          }
        } catch (e) {
          errorMsg = 'Server Error';
        }
        Fluttertoast.showToast(
          msg: errorMsg,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          fontSize: 16.0,
        );
      }
    });
    return handler.next(err); //continue
  }
}
