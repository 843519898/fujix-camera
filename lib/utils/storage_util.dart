import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// 本地存储工具类
class StorageUtil {
  static const String USER_INFO_KEY = 'user_info';
  static const String ACTIVITY_DIALOG_SHOWN_KEY = 'activity_dialog_shown';
  static const String TOKEN = '';
  static const String NAVI = '';

  static Future<bool> saveTokenKey(String token) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(token);
    return await prefs.setString(TOKEN, jsonString);
  }

  static Future<bool> saveNaviKey(String navi) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(navi);
    return await prefs.setString(NAVI, jsonString);
  }

  static Future<String> getNaviKey() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(NAVI);

    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        return json.decode(jsonString) as String;
      } catch (e) {
        return '';
      }
    }
    return '';
  }

  static Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(TOKEN);

    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        return json.decode(jsonString) as String;
      } catch (e) {
        return '';
      }
    }

    return '';
  }

  /// 保存用户信息到本地存储
  static Future<bool> saveUserInfo(Map userInfo) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(userInfo);
    return await prefs.setString(USER_INFO_KEY, jsonString);
  }

  /// 从本地存储获取用户信息
  static Future<Map> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(USER_INFO_KEY);

    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        return json.decode(jsonString) as Map;
      } catch (e) {
        print('解析用户信息失败: $e');
        return {};
      }
    }

    return {};
  }

  /// 清除用户信息
  static Future<bool> clearUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove(USER_INFO_KEY);
  }

  /// 检查活动弹窗是否已显示过
  static Future<bool> hasActivityDialogShown() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(ACTIVITY_DIALOG_SHOWN_KEY) ?? false;
  }

  /// 标记活动弹窗已显示
  static Future<bool> markActivityDialogAsShown() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(ACTIVITY_DIALOG_SHOWN_KEY, true);
  }
}
