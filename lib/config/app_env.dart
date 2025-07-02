import 'dart:io';

import 'package:flutter/foundation.dart';

import '../utils/index.dart' show LogUtil;
import 'app_config.dart';

/// 环境类型
enum ENV {
  DEV,
  TEST,
  PRE,
  PROD,
}

// dio请求前缀
final Map<ENV, String> _baseUrl = {
  ENV.DEV: 'https://fastcut-dev.chanxuan.com/api',
  ENV.TEST: 'https://fastcut-dev.chanxuan.com/api',
  ENV.PRE: 'https://fastcut-stage.chanxuan.com/api',
  ENV.PROD: 'https://fastcut.chanxuan.com/api',
};

class AppEnv {
  /// 当前环境变量
  ENV currentEnv = ENV.DEV;

  /// 安卓渠道名称
  String _androidChannel = '';

  static String checkEnvironment() {
    if (kReleaseMode) {
      return 'release';
      // 配置生产环境 API 等
    } else if (kDebugMode) {
      return 'debug';
    } else if (kProfileMode) {
      return 'profile';
      // 配置预发布环境 API
    }
    return '默认环境';
  }

  void init() {
    const envStr = String.fromEnvironment("INIT_ENV", defaultValue: "prod");
    if (!kIsWeb && Platform.isAndroid) {
      _androidChannel =
          const String.fromEnvironment("ANDROID_CHANNEL", defaultValue: "");
    }
    switch (envStr) {
      case "dev":
        currentEnv = ENV.DEV;
        break;
      case "test":
        currentEnv = ENV.TEST;
        break;
      case "pre":
        currentEnv = ENV.PRE;
        break;
      case "prod":
        currentEnv = ENV.PROD;
        break;
      default:
        currentEnv = ENV.PROD;
    }
    LogUtil.d('当前环境$currentEnv');
  }

  /// 获取app渠道名称
  String getAppChannel() => _androidChannel;

  /// 设置当前环境
  set setEnv(ENV env) {
    currentEnv = env;
    AppConfig.host = _baseUrl[currentEnv] ?? '';
  }

  /// 获取url前缀
  String get baseUrl {
    return _baseUrl[currentEnv] ?? '';
  }
}

AppEnv appEnv = AppEnv();
