import 'dart:math';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

/// 检查数据是否为空或无效
bool isNotData(dynamic value) {
  return value == null || value.toString().isEmpty;
}

/// 分割数字，添加千位分隔符
String formatNumber(num number, [int precision = 0]) {
  if (number == double.infinity || number.isNaN) return '-';

  // 处理精度
  number = (number * pow(10, precision)).floor() / pow(10, precision);

  // 将数字转换为字符串
  String numStr = number.toStringAsFixed(precision);

  // 处理小数点
  List<String> parts = numStr.split('.');
  String integerPart = parts[0];
  String decimalPart = parts.length > 1 ? '.${parts[1]}' : '';

  // 添加千位分隔符
  String result = '';
  int count = 0;
  for (int i = integerPart.length - 1; i >= 0; i--) {
    if (count != 0 && count % 3 == 0) {
      result = ',' + result;
    }
    result = integerPart[i] + result;
    count++;
  }

  return result + decimalPart;
}

/// 数字转换---保留1位多余舍去
String getNumberFloorShow(num? n, [int precision = 1]) {
  if (n == null || n.isNaN) {
    return '-';
  }

  if (isNotData(n)) {
    return '-';
  }

  if (n < 0) {
    return '-${getNumberFloorShow(-n, precision)}';
  }

  if (n < 10000) {
    return splitNumber(n, precision);
  } else if (n < 100000000) {
    final w = n / 10000;
    return '${splitNumber((w * 10).floor() / 10, precision)}w';
  } else {
    final y = n / 100000000;
    return '${splitNumber((y * 100).floor() / 100, precision)}亿';
  }
}

/// 将分转换为元并格式化显示
/// [pennyNum] 分为单位的数值
/// [precision] 保留小数位数，默认为2位
String formatPenny(num? pennyNum, [int precision = 2]) {
  if (pennyNum == null || pennyNum == 0) {
    return '-';
  }
  return formatNumber(pennyNum / 100, precision);
}

/// 抖音商品数据模型
class DyItem {
  final int? jxStatus; // 精选状态
  final int? price; // 原价（分）
  final int? activityPrice; // 活动价格（分）
  final int? cosRatio; // 佣金率（分）
  final int? activityCosRatio; // 活动佣金率（分）
  final int? cosFee; // 佣金（分）
  final int? activityCosFee; // 活动佣金（分）

  DyItem({
    this.jxStatus,
    this.price,
    this.activityPrice,
    this.cosRatio,
    this.activityCosRatio,
    this.cosFee,
    this.activityCosFee,
  });
}

Future<String> downloadToLocal(String url, String filename) async {
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$filename');
  if (await file.exists()) return file.path;
  final response = await http.get(Uri.parse(url));
  await file.writeAsBytes(response.bodyBytes);
  return file.path;
}

/// 抖音价格显示（Map版本）
/// [goods] 商品信息Map
/// [isHas100] 是否需要除以100，默认为true
String getJxPriceFromMap(Map<String, dynamic> goods, [bool isHas100 = false]) {
  if (goods['jx_status'] == 2) {
    return isHas100
        ? formatPenny(goods['activity_price'], 1)
        : getNumberFloorShow(goods['activity_price'], 1);
  }
  return isHas100
      ? formatPenny(goods['price'], 1)
      : getNumberFloorShow(goods['price'], 1);
}

/// 抖音佣金率显示
/// [item] 商品信息
/// [isHas100] 是否需要除以100，默认为true
String getJxRatioFromMap(Map<String, dynamic> item, [bool isHas100 = false]) {
  if (item['jx_status'] == 2) {
    final ratio = item['activity_cos_ratio'];
    return isHas100 ? formatPenny(ratio, 0) : getNumberFloorShow(ratio, 0);
  }
  final ratio = item['cos_ratio'];
  return isHas100 ? formatPenny(ratio, 0) : getNumberFloorShow(ratio, 0);
}

/// 抖音赚多少显示
/// [item] 商品信息
/// [isHas100] 是否需要除以100，默认为true
String getJxFeeFromMap(Map<String, dynamic> item, [bool isHas100 = false]) {
  if (item['jx_status'] == 2) {
    final fee = item['activity_cos_fee'];
    return getNumberFloorShow(isHas100 ? (fee ?? 0) / 100 : fee, 2);
  }
  final fee = item['cos_fee'];
  return getNumberFloorShow(isHas100 ? (fee ?? 0) / 100 : fee, 2);
}

/// 分割数字，添加千位分隔符
/// [n] 要分割的数字
/// [precision] 保留小数位数，默认为1位
String splitNumber(num n, [int precision = 1]) {
  if (n < 1000) {
    // 处理小数位数，使用floor实现多余舍去
    if (precision > 0) {
      num factor = pow(10, precision);
      num truncated = (n * factor).floor() / factor;
      
      // 去除末尾的零
      return truncated.toString().replaceAll(RegExp(r'\.0+$'), '')
          .replaceAll(RegExp(r'(\.\d*?)0+$'), r'$1');
    }
    return n.toString();
  } else {
    // 处理小数位数，使用floor实现多余舍去
    num factor = pow(10, precision);
    num truncated = (n * factor).floor() / factor;

    // 分割整数和小数部分
    String numStr = truncated.toString();
    
    // 去除末尾的零
    numStr = numStr.replaceAll(RegExp(r'\.0+$'), '')
          .replaceAll(RegExp(r'(\.\d*?)0+$'), r'$1');
    
    List<String> parts = numStr.split('.');
    String integerPart = parts[0];
    String decimalPart = parts.length > 1 ? '.${parts[1]}' : '';

    // 对整数部分添加千位分隔符
    String formattedInteger = integerPart.replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');

    return formattedInteger + decimalPart;
  }
}

/// 根据宽度调整CDN (OSS) 图片URL的尺寸。
/// [w] 目标宽度。实际应用到URL上的宽度将是 `2 * w`。
/// [url] 原始图片的URL。
/// 如果原始URL为null或为空，则直接返回原始URL。
/// 否则，它会向URL追加OSS图片处理参数以调整尺寸。
/// 例如：`x-oss-process=image/resize,w_<calculated_width>`
String? solveCdnImgUrlResize(int w, String? url) {
  // 如果URL为空或无效，则直接返回
  if (url == null || url.isEmpty) {
    return url;
  }

  // 判断URL中是否已存在查询参数，以决定使用 '?' 还是 '&' 连接符
  final String separator = url.contains('?') ? '&' : '?';

  // 构建并返回新的URL，包含OSS图片缩放指令
  // 注意：根据原始JavaScript逻辑，宽度参数为 2 * w
  return '$url${separator}x-oss-process=image/resize,w_${2 * w}';
}

/// 防抖工具类
/// 用于处理频繁触发的事件，确保在指定时间内只执行一次
/// 使用示例：
/// ```dart
/// final debouncer = CxDebouncer(milliseconds: 500);
/// 
/// // 在需要防抖的地方调用
/// debouncer.run(() {
///   // 你的代码
/// });
/// 
/// // 在不需要时释放资源
/// @override
/// void dispose() {
///   debouncer.dispose();
///   super.dispose();
/// }
/// ```
class CxDebouncer {
  Timer? _timer;
  final int milliseconds;

  CxDebouncer({this.milliseconds = 500});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}

