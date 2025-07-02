import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../routes/route_name.dart';
import '../../utils/permission_helper.dart';
import '../../utils/debug_helper.dart';

class Home extends StatefulWidget {
  const Home({Key? key, this.params}) : super(key: key);
  final dynamic params;

  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> {
  
  // 权限状态
  bool _hasCameraPermission = false;
  bool _hasStoragePermission = false;
  bool _isCheckingPermissions = true;

  @override
  void initState() {
    super.initState();
    _checkAllPermissions();
  }
  
  /// 检查所有权限状态
  Future<void> _checkAllPermissions() async {
    try {
      setState(() {
        _isCheckingPermissions = true;
      });
      
      bool cameraPermission = await PermissionHelper.hasCameraPermission();
      bool storagePermission = await PermissionHelper.hasStoragePermission();
      
      setState(() {
        _hasCameraPermission = cameraPermission;
        _hasStoragePermission = storagePermission;
        _isCheckingPermissions = false;
      });
      
      print('权限检查完成 - 相机权限: $cameraPermission, 存储权限: $storagePermission');
    } catch (e) {
      print('检查权限时发生错误: $e');
      setState(() {
        _isCheckingPermissions = false;
      });
    }
  }
  
  /// 请求相机权限
  Future<bool> _requestCameraPermission() async {
    try {
      print('开始请求拍照权限...');
      
      // 首先检查相机权限状态
      bool isPermanentlyDenied = await PermissionHelper.isCameraPermissionPermanentlyDenied();
      
      if (isPermanentlyDenied) {
        print('相机权限已被永久拒绝，显示设置引导对话框');
        // 权限被永久拒绝，显示专门的设置引导对话框
        return await _showPermanentlyDeniedDialog();
      }
      
      // 使用权限管理工具类请求权限
      bool hasPermission = await PermissionHelper.requestCameraAndStoragePermissions();

      if (!hasPermission) {
        // 检查是否是刚刚被永久拒绝的
        bool isNowPermanentlyDenied = await PermissionHelper.isCameraPermissionPermanentlyDenied();

        if (isNowPermanentlyDenied) {
          print('权限刚刚被永久拒绝，显示设置引导对话框');
          return await _showPermanentlyDeniedDialog();
        } else {
          // 普通拒绝，显示权限说明对话框
          bool userWantsToOpenSettings = await _showPermissionExplanationDialog();

          if (userWantsToOpenSettings) {
            // 用户选择去设置，再次检查权限
            await Future.delayed(Duration(seconds: 1)); // 给用户一些时间去设置
            return await PermissionHelper.hasCameraPermission();
          }
        }

        return false;
      }
      
      return true;
    } catch (e) {
      print('请求相机权限时发生错误: $e');
      PermissionHelper.showPermissionSnackBar(
        context, 
        '权限请求失败: $e',
        isError: true,
      );
      return false;
    }
  }
  
  /// 显示权限说明对话框
  Future<bool> _showPermissionExplanationDialog() async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.camera_alt, color: Colors.blue),
              SizedBox(width: 8.w),
              Text('需要相机权限'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '为了使用拍照功能，需要您授权以下权限：',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12.h),
              _buildPermissionItem(Icons.camera_alt, '相机权限', '用于拍照和实时预览'),
              _buildPermissionItem(Icons.photo_library, '存储权限', '用于保存照片到相册'),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.security, color: Colors.blue, size: 20.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        '我们严格保护您的隐私，不会上传或分享您的照片',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('取消'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: Text('去设置', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    ) ?? false;
  }
  
  /// 显示权限被永久拒绝的对话框
  Future<bool> _showPermanentlyDeniedDialog() async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8.w),
              Text('权限被拒绝'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '相机权限已被拒绝，需要手动开启',
                  style: TextStyle(
                    fontSize: 16.sp, 
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade700,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  '请按以下步骤开启相机权限：',
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 12.h),
                _buildStepItem('1', '点击下方"去设置"按钮'),
                _buildStepItem('2', '找到"相机"权限选项'),
                _buildStepItem('3', '打开相机权限开关'),
                _buildStepItem('4', '返回应用重新尝试'),
                SizedBox(height: 16.h),
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange, size: 20.sp),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          '如果找不到权限设置，可以尝试卸载后重新安装应用',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('取消'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(true);
                // 打开设置页面
                bool opened = await openAppSettings();
                if (opened) {
                  // 给用户一些时间去设置
                  await Future.delayed(Duration(seconds: 2));
                  // 用户可能从设置页面返回，检查权限
                  await _checkPermissionAfterSettings();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: Text('去设置', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    ) ?? false;
  }
  
  /// 用户从设置页面返回后检查权限
  Future<void> _checkPermissionAfterSettings() async {
    // 等待一段时间，让用户有时间在设置中修改权限
    await Future.delayed(Duration(seconds: 1));
    
    // 重新检查所有权限状态
    await _checkAllPermissions();
    
    bool hasPermission = await PermissionHelper.hasCameraPermission();
    
    if (hasPermission) {
      PermissionHelper.showPermissionSnackBar(
        context, 
        '太棒了！相机权限已开启，现在可以正常使用拍照功能了！',
        isError: false,
      );
    } else {
      PermissionHelper.showPermissionSnackBar(
        context, 
        '相机权限仍未开启，请确保在设置中已打开相机权限',
        isError: true,
      );
    }
  }
  
  /// 构建步骤说明项
  Widget _buildStepItem(String stepNumber, String description) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24.w,
            height: 24.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue,
            ),
            child: Center(
              child: Text(
                stepNumber,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              description,
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }
  
  /// 构建权限项目说明
  Widget _buildPermissionItem(IconData icon, String title, String description) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Icon(icon, size: 20.sp, color: Colors.grey.shade600),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建权限状态项
  Widget _buildPermissionStatusItem(IconData icon, String title, bool isGranted) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Icon(icon, size: 18.sp, color: Colors.grey.shade600),
          SizedBox(width: 8.w),
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade700,
            ),
          ),
          Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: isGranted ? Colors.green.shade100 : Colors.red.shade100,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isGranted ? Icons.check : Icons.close,
                  size: 12.sp,
                  color: isGranted ? Colors.green.shade700 : Colors.red.shade700,
                ),
                SizedBox(width: 4.w),
                Text(
                  isGranted ? '已开启' : '未开启',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isGranted ? Colors.green.shade700 : Colors.red.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// 打开自定义拍照页面
  Future<void> _openCustomCamera() async {
    try {
      print('用户点击了拍照按钮');
      
      // 显示加载指示器
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16.h),
                Text('正在检查权限...'),
              ],
            ),
          ),
        ),
      );
      
      // 请求权限
      // bool hasPermission = await _requestCameraPermission();
      
      // 关闭加载指示器
      Navigator.of(context).pop();
      //
      // if (!hasPermission) {
      //   PermissionHelper.showPermissionSnackBar(
      //     context,
      //     '无法获取相机权限，请在设置中手动开启权限',
      //     isError: true,
      //   );
      //   // 更新权限状态显示
      //   _checkAllPermissions();
      //   return;
      // }
      
      print('权限检查通过，准备打开相机页面');
      
      // 权限获取成功，更新状态
      _checkAllPermissions();
      
      // 权限获取成功，跳转到拍照页面
      final result = await Navigator.pushNamed(
        context, 
        RouteName.camera,
      );
      
      // 处理拍照返回的结果
      if (result != null && result.toString().isNotEmpty) {
        print('拍照完成，图片路径: $result');
        PermissionHelper.showPermissionSnackBar(
          context, 
          '拍照成功！照片已保存到相册',
          isError: false,
        );
        
        // 震动反馈
        HapticFeedback.lightImpact();
      } else {
        print('用户取消了拍照或拍照失败');
      }
    } catch (e) {
      print('打开相机时发生错误: $e');
      
      // 如果加载指示器还在显示，先关闭它
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
      
      PermissionHelper.showPermissionSnackBar(
        context, 
        '打开相机失败: $e',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('首页'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.bug_report),
            onPressed: () => DebugHelper.showDebugDialog(context),
            tooltip: '调试信息',
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 拍照按钮
            Container(
              width: double.infinity,
              height: 120.h,
              margin: EdgeInsets.only(bottom: 30.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.blue.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    offset: Offset(0, 5),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(15.r),
                  onTap: _openCustomCamera,
                  child: Container(
                    padding: EdgeInsets.all(20.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt,
                          size: 40.sp,
                          color: Colors.white,
                        ),
                        SizedBox(width: 15.w),
                        Text(
                          '自定义拍照',
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            // 功能说明
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue,
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '拍照功能说明',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    '• 支持前后摄像头切换\n'
                    '• 支持闪光灯控制\n'
                    '• 支持缩放功能\n'
                    '• 自动保存到相册\n'
                    '• 实时预览和拍照',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}