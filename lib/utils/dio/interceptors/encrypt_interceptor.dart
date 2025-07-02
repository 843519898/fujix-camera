import 'package:dio/dio.dart';
import '../../crypto_utils.dart';
import 'dart:convert';

/*
 * 加解密拦截器
 */
class EncryptInterceptor extends Interceptor {
  // 请求拦截
  @override
  onRequest(RequestOptions options, handler) async {
    // 检查是否需要加密
    if (options.extra['encrypt'] == true) {
      try {
        // 获取请求数据
        final data = options.extra['originalQueryParameters'];
        if (data != null && data.isNotEmpty) {
          // 将 Map 转换为 URL 查询字符串
          String dataStr = data.entries
              .map((entry) => '${entry.key}=${entry.value}')
              .join('&');
          // 加密数据
          print('加密数据:$dataStr');
          String encryptedData = CryptoUtils.aesEncrypt(dataStr);

          // 将加密后的数据作为 encode 参数，并添加 encrypt: 1
          options.queryParameters = {
            'encode': encryptedData,
            'encrypt': 1,
          };
        }
      } catch (e) {
        print('加密失败: $e');
        return handler.reject(
          DioException(
            requestOptions: options,
            error: '加密失败',
          ),
        );
      }
    }
    return handler.next(options);
  }

  // 响应拦截
  @override
  onResponse(response, handler) async {
    // 检查是否需要解密
    if (response.requestOptions.extra['encrypt'] == true) {
      try {
        // 获取响应数据
        final data = response.data;
        final Map dataMap = json.decode(data);
        if (data != null && data is String && dataMap['code'] == 0) {
          // 解密数据
          String decryptedData = CryptoUtils.aesDecrypt(data);
          // 更新响应数据
          response.data = decryptedData;
        }
      } catch (e) {
        print('解密失败: $e');
        return handler.reject(
          DioException(
            requestOptions: response.requestOptions,
            error: '解密失败',
          ),
        );
      }
    }
    return handler.next(response);
  }

  // 请求失败拦截
  @override
  onError(err, handler) async {
    return handler.next(err);
  }
}
