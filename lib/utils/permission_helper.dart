import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// 权限管理工具类
/// 统一管理应用中的所有权限请求和处理
class PermissionHelper {
  
  /// 请求相机权限
  /// 返回值：true表示权限已获取，false表示权限被拒绝
  static Future<bool> requestCameraPermission() async {
    try {
      print('开始请求相机权限...');
      
      // 检查当前权限状态
      PermissionStatus cameraStatus = await Permission.camera.status;
      print('当前相机权限状态: $cameraStatus');
      
      // 如果权限已经被授予，直接返回true
      if (cameraStatus.isGranted) {
        print('相机权限已授予');
        return true;
      }
      
      // 如果权限被永久拒绝，引导用户到设置页面
      if (cameraStatus.isPermanentlyDenied) {
        print('相机权限被永久拒绝，引导用户到设置页面');
        return await _handlePermanentlyDenied('相机');
      }
      
      // 请求相机权限
      print('正在请求相机权限...');
      PermissionStatus result = await Permission.camera.request();
      print('相机权限请求结果: $result');
      
      if (result.isGranted) {
        print('相机权限授予成功');
        return true;
      } else if (result.isPermanentlyDenied) {
        print('相机权限被永久拒绝');
        return await _handlePermanentlyDenied('相机');
      } else {
        print('相机权限被拒绝');
        return false;
      }
    } catch (e) {
      print('请求相机权限时发生错误: $e');
      return false;
    }
  }
  
  /// 请求存储权限
  /// 用于保存照片到相册
  static Future<bool> requestStoragePermission() async {
    try {
      print('开始请求存储权限...');
      
      // Android 13 (API 33) 以上版本不需要存储权限来保存媒体文件
      if (Platform.isAndroid) {
        final androidInfo = await _getAndroidVersion();
        if (androidInfo >= 33) {
          print('Android 13+ 系统，不需要存储权限');
          return true;
        }
      }
      
      Permission permission;
      if (Platform.isAndroid) {
        permission = Permission.storage;
      } else {
        permission = Permission.photos;
      }
      
      PermissionStatus status = await permission.status;
      print('当前存储权限状态: $status');
      
      if (status.isGranted) {
        print('存储权限已授予');
        return true;
      }
      
      if (status.isPermanentlyDenied) {
        print('存储权限被永久拒绝');
        return await _handlePermanentlyDenied('存储');
      }
      
      print('正在请求存储权限...');
      PermissionStatus result = await permission.request();
      print('存储权限请求结果: $result');
      
      if (result.isGranted) {
        print('存储权限授予成功');
        return true;
      } else if (result.isPermanentlyDenied) {
        print('存储权限被永久拒绝');
        return await _handlePermanentlyDenied('存储');
      } else {
        print('存储权限被拒绝');
        return false;
      }
    } catch (e) {
      print('请求存储权限时发生错误: $e');
      return false;
    }
  }
  
  /// 一次性请求拍照所需的所有权限
  /// 包括相机权限和存储权限
  static Future<bool> requestCameraAndStoragePermissions() async {
    try {
      print('开始请求拍照相关权限...');
      
      // 首先请求相机权限
      bool cameraGranted = await requestCameraPermission();
      if (!cameraGranted) {
        print('相机权限获取失败');
        return false;
      }
      
      // 然后请求存储权限
      bool storageGranted = await requestStoragePermission();
      if (!storageGranted) {
        print('存储权限获取失败');
        return false;
      }
      
      print('所有拍照权限获取成功');
      return true;
    } catch (e) {
      print('请求拍照权限时发生错误: $e');
      return false;
    }
  }
  
  /// 检查是否有相机权限
  static Future<bool> hasCameraPermission() async {
    try {
      PermissionStatus status = await Permission.camera.status;
      return status.isGranted;
    } catch (e) {
      print('检查相机权限时发生错误: $e');
      return false;
    }
  }
  
  /// 检查相机权限状态
  /// 返回权限状态的详细信息
  static Future<PermissionStatus> getCameraPermissionStatus() async {
    try {
      return await Permission.camera.status;
    } catch (e) {
      print('获取相机权限状态时发生错误: $e');
      return PermissionStatus.denied;
    }
  }
  
  /// 检查权限是否被永久拒绝
  static Future<bool> isCameraPermissionPermanentlyDenied() async {
    try {
      PermissionStatus status = await Permission.camera.status;
      return status.isPermanentlyDenied;
    } catch (e) {
      print('检查相机权限永久拒绝状态时发生错误: $e');
      return false;
    }
  }
  
  /// 检查是否有存储权限
  static Future<bool> hasStoragePermission() async {
    try {
      // Android 13+ 不需要存储权限
      if (Platform.isAndroid) {
        final androidVersion = await _getAndroidVersion();
        if (androidVersion >= 33) {
          return true;
        }
      }
      
      Permission permission = Platform.isAndroid 
          ? Permission.storage 
          : Permission.photos;
      
      PermissionStatus status = await permission.status;
      return status.isGranted;
    } catch (e) {
      print('检查存储权限时发生错误: $e');
      return false;
    }
  }
  
  /// 处理权限被永久拒绝的情况
  static Future<bool> _handlePermanentlyDenied(String permissionName) async {
    try {
      print('处理${permissionName}权限被永久拒绝的情况，需要用户手动在设置中开启');
      
      // 直接返回 false，让调用方显示用户引导对话框
      // 不在这里打开设置页面，而是让用户主动选择
      return false;
    } catch (e) {
      print('处理永久拒绝权限时发生错误: $e');
      return false;
    }
  }
  
  /// 获取Android系统版本
  static Future<int> _getAndroidVersion() async {
    try {
      // 这里应该使用 device_info_plus 插件来获取系统版本
      // 为了简化，这里返回默认值
      return 30; // 假设是 Android 11
    } catch (e) {
      print('获取Android版本时发生错误: $e');
      return 30;
    }
  }
  
  /// 显示权限请求对话框
  static Future<bool> showPermissionDialog(
    BuildContext context, 
    String permissionName,
    String description,
  ) async {
    try {
      bool? result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('需要${permissionName}权限'),
            content: Text(description),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('拒绝'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('去设置'),
              ),
            ],
          );
        },
      );
      
      if (result == true) {
        return await openAppSettings();
      }
      
      return false;
    } catch (e) {
      print('显示权限对话框时发生错误: $e');
      return false;
    }
  }
  
  /// 显示权限提示消息
  static void showPermissionSnackBar(
    BuildContext context, 
    String message, {
    bool isError = true,
  }) {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
          duration: Duration(seconds: 3),
          action: SnackBarAction(
            label: '确定',
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    } catch (e) {
      print('显示权限提示消息时发生错误: $e');
    }
  }
  
  /// 强制触发权限请求
  /// 即使权限已被永久拒绝，也要让系统知道应用需要这个权限
  /// 这样权限选项就会出现在系统设置中
  static Future<bool> forceTriggerPermissionRequest() async {
    try {
      print('强制触发权限请求，确保权限选项出现在系统设置中');
      
      // 强制请求相机权限，不管当前状态如何
      PermissionStatus cameraResult = await Permission.camera.request();
      print('强制请求相机权限结果: $cameraResult');
      
      // 强制请求存储权限
      Permission storagePermission = Platform.isAndroid 
          ? Permission.storage 
          : Permission.photos;
      PermissionStatus storageResult = await storagePermission.request();
      print('强制请求存储权限结果: $storageResult');
      
      // 如果是Android，还可以尝试请求麦克风权限（某些设备相机功能需要）
      if (Platform.isAndroid) {
        PermissionStatus micResult = await Permission.microphone.request();
        print('强制请求麦克风权限结果: $micResult');
      }
      
      // 检查最终状态
      bool cameraGranted = cameraResult.isGranted;
      bool storageGranted = storageResult.isGranted;
      
      print('强制触发完成 - 相机权限: $cameraGranted, 存储权限: $storageGranted');
      
      return cameraGranted && storageGranted;
    } catch (e) {
      print('强制触发权限请求时发生错误: $e');
      return false;
    }
  }
  
  /// 重置权限状态（用于测试）
  /// 注意：这个方法只能在开发模式下使用
  static Future<void> resetPermissionStatus() async {
    try {
      print('重置权限状态（仅用于测试）');
      
      // 在生产环境中，无法真正重置权限
      // 这里只是提示用户需要手动操作
      print('提示：要重置权限，请卸载并重新安装应用');
    } catch (e) {
      print('重置权限状态时发生错误: $e');
    }
  }
} 