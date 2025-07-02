import 'dart:io';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'permission_helper.dart';

/// 调试工具类
/// 帮助排查权限和设备相关问题
class DebugHelper {
  
  /// 获取设备详细信息
  static Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      Map<String, dynamic> info = {};
      
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        info = {
          'platform': 'Android',
          'model': androidInfo.model,
          'brand': androidInfo.brand,
          'version': androidInfo.version.release,
          'sdkInt': androidInfo.version.sdkInt,
          'manufacturer': androidInfo.manufacturer,
          'device': androidInfo.device,
        };
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        info = {
          'platform': 'iOS',
          'model': iosInfo.model,
          'name': iosInfo.name,
          'systemVersion': iosInfo.systemVersion,
          'localizedModel': iosInfo.localizedModel,
          'identifierForVendor': iosInfo.identifierForVendor,
        };
      }
      
      return info;
    } catch (e) {
      print('获取设备信息失败: $e');
      return {'error': e.toString()};
    }
  }
  
  /// 获取所有权限状态
  static Future<Map<String, String>> getAllPermissionStatus() async {
    try {
      Map<String, String> permissions = {};
      
      // 检查相机权限
      PermissionStatus cameraStatus = await Permission.camera.status;
      permissions['相机权限'] = _getPermissionStatusText(cameraStatus);
      
      // 检查存储权限
      Permission storagePermission = Platform.isAndroid 
          ? Permission.storage 
          : Permission.photos;
      PermissionStatus storageStatus = await storagePermission.status;
      permissions['存储权限'] = _getPermissionStatusText(storageStatus);
      
      // 检查麦克风权限（某些情况下相机需要）
      PermissionStatus microphoneStatus = await Permission.microphone.status;
      permissions['麦克风权限'] = _getPermissionStatusText(microphoneStatus);
      
      return permissions;
    } catch (e) {
      print('获取权限状态失败: $e');
      return {'错误': e.toString()};
    }
  }
  
  /// 转换权限状态为中文描述
  static String _getPermissionStatusText(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return '已授权 ✅';
      case PermissionStatus.denied:
        return '已拒绝 ❌';
      case PermissionStatus.restricted:
        return '受限制 ⚠️';
      case PermissionStatus.permanentlyDenied:
        return '永久拒绝 🚫';
      case PermissionStatus.provisional:
        return '临时授权 ⏳';
      default:
        return '未知状态 ❓';
    }
  }
  
  /// 显示调试信息对话框
  static Future<void> showDebugDialog(BuildContext context) async {
    // 获取设备信息和权限状态
    Map<String, dynamic> deviceInfo = await getDeviceInfo();
    Map<String, String> permissions = await getAllPermissionStatus();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('调试信息'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '设备信息',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 8),
                ...deviceInfo.entries.map((entry) => 
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 2),
                    child: Text('${entry.key}: ${entry.value}'),
                  )
                ).toList(),
                
                SizedBox(height: 16),
                Text(
                  '权限状态',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                SizedBox(height: 8),
                ...permissions.entries.map((entry) => 
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 2),
                    child: Text('${entry.key}: ${entry.value}'),
                  )
                ).toList(),
                
                SizedBox(height: 16),
                _buildTroubleshootingGuide(deviceInfo),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('关闭'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // 强制触发权限请求
                await PermissionHelper.forceTriggerPermissionRequest();
                // 然后打开设置
                await openAppSettings();
              },
              child: Text('触发权限'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.orange,
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await openAppSettings();
              },
              child: Text('去设置'),
            ),
          ],
        );
      },
    );
  }
  
  /// 构建故障排除指南
  static Widget _buildTroubleshootingGuide(Map<String, dynamic> deviceInfo) {
    String platform = deviceInfo['platform'] ?? 'Unknown';
    
    if (platform == 'iOS') {
      return _buildIOSTroubleshooting(deviceInfo);
    } else if (platform == 'Android') {
      return _buildAndroidTroubleshooting(deviceInfo);
    } else {
      return Text('未知平台');
    }
  }
  
  /// iOS 故障排除指南
  static Widget _buildIOSTroubleshooting(Map<String, dynamic> deviceInfo) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'iOS 权限设置指南',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '如果找不到相机权限选项：\n\n'
            '1. 打开"设置" → "隐私与安全"\n'
            '2. 选择"相机"\n'
            '3. 找到"FujiBoom"或应用名称\n'
            '4. 开启相机权限开关\n\n'
            '如果列表中没有应用：\n'
            '• 可能应用从未请求过权限\n'
            '• 尝试重新安装应用\n'
            '• 检查应用是否正确安装',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
  
  /// Android 故障排除指南
  static Widget _buildAndroidTroubleshooting(Map<String, dynamic> deviceInfo) {
    int sdkInt = deviceInfo['sdkInt'] ?? 30;
    
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Android 权限设置指南',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Android ${deviceInfo['version']} (API ${sdkInt})\n\n'
            '权限设置路径：\n'
            '1. 设置 → 应用管理/应用\n'
            '2. 找到"FujiBoom"或应用名称\n'
            '3. 点击"权限"或"应用权限"\n'
            '4. 开启"相机"权限\n\n'
            '或者：\n'
            '1. 设置 → 隐私/权限管理\n'
            '2. 选择"相机"\n'
            '3. 找到应用并开启权限\n\n'
            '${sdkInt >= 30 ? "Android 11+: 可能需要在权限管理中单独设置" : ""}',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
  
  /// 生成调试报告
  static Future<String> generateDebugReport() async {
    Map<String, dynamic> deviceInfo = await getDeviceInfo();
    Map<String, String> permissions = await getAllPermissionStatus();
    
    StringBuffer report = StringBuffer();
    report.writeln('=== 调试报告 ===');
    report.writeln('生成时间: ${DateTime.now().toString()}');
    report.writeln('');
    
    report.writeln('设备信息:');
    deviceInfo.forEach((key, value) {
      report.writeln('  $key: $value');
    });
    report.writeln('');
    
    report.writeln('权限状态:');
    permissions.forEach((key, value) {
      report.writeln('  $key: $value');
    });
    
    return report.toString();
  }
} 