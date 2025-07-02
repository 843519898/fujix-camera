import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class CustomCameraPage extends StatefulWidget {
  const CustomCameraPage({Key? key}) : super(key: key);

  @override
  State<CustomCameraPage> createState() => _CustomCameraPageState();
}

class _CustomCameraPageState extends State<CustomCameraPage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  
  // 相机控制器
  CameraController? _cameraController;
  
  // 可用相机列表
  List<CameraDescription> _cameras = [];
  
  // 当前相机索引
  int _currentCameraIndex = 0;
  
  // 闪光灯模式
  FlashMode _flashMode = FlashMode.off;
  
  // 缩放级别
  double _minZoomLevel = 1.0;
  double _maxZoomLevel = 1.0;
  double _currentZoomLevel = 1.0;
  
  // 是否正在拍照
  bool _isTakingPicture = false;
  
  // 初始化状态
  bool _isInitialized = false;
  
  // 错误信息
  String? _errorMessage;
  
  // 动画控制器
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // 初始化动画控制器
    _animationController = AnimationController(
      duration: Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _cameraController;

    // 应用非活跃状态时停止相机
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  /// 初始化相机
  Future<void> _initializeCamera() async {
    try {
      // 获取可用相机列表
      _cameras = await availableCameras();
      
      if (_cameras.isEmpty) {
        setState(() {
          _errorMessage = '未找到可用相机';
        });
        return;
      }

      // 选择后置相机作为默认相机
      _currentCameraIndex = 0;
      for (int i = 0; i < _cameras.length; i++) {
        if (_cameras[i].lensDirection == CameraLensDirection.back) {
          _currentCameraIndex = i;
          break;
        }
      }

      await _initializeCameraController();
    } catch (e) {
      print('初始化相机失败: $e');
      setState(() {
        _errorMessage = '初始化相机失败: $e';
      });
    }
  }

  /// 初始化相机控制器
  Future<void> _initializeCameraController() async {
    try {
      _cameraController = CameraController(
        _cameras[_currentCameraIndex],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      
      // 获取缩放范围
      _minZoomLevel = await _cameraController!.getMinZoomLevel();
      _maxZoomLevel = await _cameraController!.getMaxZoomLevel();
      _currentZoomLevel = _minZoomLevel;

      setState(() {
        _isInitialized = true;
        _errorMessage = null;
      });
    } catch (e) {
      print('初始化相机控制器失败: $e');
      setState(() {
        _errorMessage = '初始化相机控制器失败: $e';
      });
    }
  }

  /// 切换相机
  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;

    try {
      setState(() {
        _isInitialized = false;
      });

      await _cameraController?.dispose();
      
      _currentCameraIndex = (_currentCameraIndex + 1) % _cameras.length;
      
      await _initializeCameraController();
    } catch (e) {
      print('切换相机失败: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('切换相机失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// 切换闪光灯模式
  Future<void> _toggleFlashMode() async {
    if (_cameraController == null) return;

    try {
      FlashMode newMode;
      switch (_flashMode) {
        case FlashMode.off:
          newMode = FlashMode.auto;
          break;
        case FlashMode.auto:
          newMode = FlashMode.always;
          break;
        case FlashMode.always:
          newMode = FlashMode.off;
          break;
        default:
          newMode = FlashMode.off;
      }

      await _cameraController!.setFlashMode(newMode);
      setState(() {
        _flashMode = newMode;
      });
    } catch (e) {
      print('切换闪光灯失败: $e');
    }
  }

  /// 设置缩放级别
  Future<void> _setZoomLevel(double zoom) async {
    if (_cameraController == null) return;

    try {
      zoom = zoom.clamp(_minZoomLevel, _maxZoomLevel);
      await _cameraController!.setZoomLevel(zoom);
      setState(() {
        _currentZoomLevel = zoom;
      });
    } catch (e) {
      print('设置缩放失败: $e');
    }
  }

  /// 拍照
  Future<void> _takePicture() async {
    if (!_isInitialized || _isTakingPicture || _cameraController == null) {
      return;
    }

    try {
      setState(() {
        _isTakingPicture = true;
      });

      // 播放拍照动画
      _animationController.forward().then((_) {
        _animationController.reverse();
      });

      // 拍照
      final XFile imageFile = await _cameraController!.takePicture();
      
      // 保存到相册
      final File file = File(imageFile.path);
      final result = await ImageGallerySaver.saveFile(file.path);
      
      if (result['isSuccess'] == true) {
        // 显示成功提示
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('照片已保存到相册'),
            backgroundColor: Colors.green,
          ),
        );
        
        // 震动反馈
        HapticFeedback.lightImpact();
        
        // 返回图片路径
        Navigator.of(context).pop(imageFile.path);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存失败'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('拍照失败: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('拍照失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isTakingPicture = false;
      });
    }
  }

  /// 获取闪光灯图标
  IconData _getFlashIcon() {
    switch (_flashMode) {
      case FlashMode.off:
        return Icons.flash_off;
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.always:
        return Icons.flash_on;
      default:
        return Icons.flash_off;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // 相机预览
            _buildCameraPreview(),
            
            // 顶部控制栏
            _buildTopControls(),
            
            // 底部控制栏
            _buildBottomControls(),
            
            // 缩放控制
            _buildZoomControls(),
          ],
        ),
      ),
    );
  }

  /// 构建相机预览
  Widget _buildCameraPreview() {
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.sp,
              color: Colors.white,
            ),
            SizedBox(height: 16.h),
            Text(
              _errorMessage!,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: _initializeCamera,
              child: Text('重试'),
            ),
          ],
        ),
      );
    }

    if (!_isInitialized) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    return GestureDetector(
      onScaleUpdate: (ScaleUpdateDetails details) {
        // 缩放手势
        final double newZoom = _currentZoomLevel * details.scale;
        _setZoomLevel(newZoom);
      },
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: CameraPreview(_cameraController!),
      ),
    );
  }

  /// 构建顶部控制栏
  Widget _buildTopControls() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 返回按钮
            _buildControlButton(
              icon: Icons.arrow_back,
              onTap: () => Navigator.of(context).pop(),
            ),
            
            // 闪光灯控制
            _buildControlButton(
              icon: _getFlashIcon(),
              onTap: _toggleFlashMode,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建底部控制栏
  Widget _buildBottomControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // 空白占位
            SizedBox(width: 64.w),
            
            // 拍照按钮
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: GestureDetector(
                    onTap: _takePicture,
                    child: Container(
                      width: 80.w,
                      height: 80.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 4.w,
                        ),
                      ),
                      child: _isTakingPicture
                          ? Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.blue,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.camera_alt,
                              size: 40.sp,
                              color: Colors.blue,
                            ),
                    ),
                  ),
                );
              },
            ),
            
            // 切换相机按钮
            _buildControlButton(
              icon: Icons.flip_camera_ios,
              onTap: _cameras.length > 1 ? _switchCamera : null,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建缩放控制
  Widget _buildZoomControls() {
    if (!_isInitialized) return SizedBox();
    
    return Positioned(
      right: 20.w,
      top: 100.h,
      bottom: 200.h,
      child: Container(
        width: 40.w,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          children: [
            // 放大按钮
            _buildZoomButton(
              icon: Icons.add,
              onTap: () {
                final newZoom = min(_currentZoomLevel + 0.5, _maxZoomLevel);
                _setZoomLevel(newZoom);
              },
            ),
            
            // 缩放级别显示
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 10.h),
                child: RotatedBox(
                  quarterTurns: 3,
                  child: Slider(
                    value: _currentZoomLevel,
                    min: _minZoomLevel,
                    max: _maxZoomLevel,
                    onChanged: _setZoomLevel,
                    activeColor: Colors.white,
                    inactiveColor: Colors.grey,
                  ),
                ),
              ),
            ),
            
            // 缩小按钮
            _buildZoomButton(
              icon: Icons.remove,
              onTap: () {
                final newZoom = max(_currentZoomLevel - 0.5, _minZoomLevel);
                _setZoomLevel(newZoom);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 构建控制按钮
  Widget _buildControlButton({
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return Container(
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withOpacity(0.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24.r),
          onTap: onTap,
          child: Icon(
            icon,
            color: Colors.white,
            size: 24.sp,
          ),
        ),
      ),
    );
  }

  /// 构建缩放按钮
  Widget _buildZoomButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 40.w,
      height: 40.w,
      margin: EdgeInsets.symmetric(vertical: 5.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20.r),
          onTap: onTap,
          child: Icon(
            icon,
            color: Colors.white,
            size: 20.sp,
          ),
        ),
      ),
    );
  }
} 