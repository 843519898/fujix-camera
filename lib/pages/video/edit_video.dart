import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_module/utils/native_bridge.dart';
import 'package:flutter_module/utils/tool/cx_tools.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class EditVideoPage extends StatefulWidget {
  const EditVideoPage({super.key, required this.videoUrl});
  
  final videoUrl;

  @override
  State<EditVideoPage> createState() => _EditVideoPageState();
}

class _EditVideoPageState extends State<EditVideoPage> {
  VideoPlayerController? _controller;
  bool _isPlaying = false;
  bool _showControls = true;
  bool _isInitialized = false;
  bool _hasError = false;
  String? _errorMessage;
  String url = '';

  @override
  void initState() {
    super.initState();
    print('widget.videoUrl${widget.videoUrl}');
    url = widget.videoUrl['videoUrl'];
    _initializeVideo();
    // 注释掉全屏和横屏设置，保持正常竖屏模式
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.landscapeLeft,
    //   DeviceOrientation.landscapeRight,
    // ]);
  }

  @override
  void dispose() {
    _controller?.dispose();
    // 移除状态栏和屏幕方向的恢复代码，因为我们没有修改过
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.portraitUp,
    //   DeviceOrientation.portraitDown,
    //   DeviceOrientation.landscapeLeft,
    //   DeviceOrientation.landscapeRight,
    // ]);
    super.dispose();
  }

  Future<void> _initializeVideo() async {
    try {
      // 检查文件是否存在
      final file = File(url);
      if (!await file.exists()) {
        setState(() {
          _hasError = true;
          _errorMessage = '视频文件不存在';
        });
        return;
      }

      _controller = VideoPlayerController.file(file);
      await _controller!.initialize();
      
      setState(() {
        _isInitialized = true;
      });
      
      // 自动开始播放
      _controller!.play();
      setState(() {
        _isPlaying = true;
      });

      // 监听播放状态变化
      _controller!.addListener(() {
        if (mounted) {
          setState(() {
            _isPlaying = _controller!.value.isPlaying;
          });
        }
      });
      
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = '视频加载失败: $e';
      });
    }
  }

  void _togglePlayPause() {
    if (_controller != null && _isInitialized) {
      if (_isPlaying) {
        _controller!.pause();
      } else {
        _controller!.play();
      }
    }
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  void _seekTo(Duration position) {
    _controller?.seekTo(position);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  // 修改保存视频到本地的方法，适配iOS平台
  Future<void> _saveVideoToLocal(String sourcePath) async {
    try {
      // 检查源文件是否存在
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        _showMessage('源文件不存在');
        return;
      }

      // 根据平台选择不同的保存方式
      if (Platform.isIOS || Platform.isMacOS) {
        // iOS/macOS: 保存到相册
        await _saveToGallery(sourcePath);
      } else {
        // Android: 保存到外部存储
        await _saveToExternalStorage(sourcePath);
      }
    } catch (e) {
      _showMessage('保存失败: $e');
      print('保存视频失败: $e');
    }
  }

  // 保存到相册 (iOS/macOS)
  Future<void> _saveToGallery(String sourcePath) async {
    try {
      // 请求相册权限
      var status = await Permission.photos.status;
      // if (!status.isGranted) {
      //   status = await Permission.photos.request();
      //   if (!status.isGranted) {
      //     _showMessage('需要相册权限才能保存视频');
      //     return;
      //   }
      // }

      // 保存到相册
      final result = await ImageGallerySaver.saveFile(
        sourcePath,
        isReturnPathOfIOS: true,
      );

      if (result['isSuccess'] == true) {
        _showMessage('视频已保存到相册');
        print('视频保存成功到相册');
      } else {
        _showMessage('保存到相册失败');
      }
    } catch (e) {
      _showMessage('保存到相册失败: $e');
      print('保存到相册失败: $e');
    }
  }

  // 保存到外部存储 (Android)
  Future<void> _saveToExternalStorage(String sourcePath) async {
    try {
      // 请求存储权限
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
        if (!status.isGranted) {
          _showMessage('需要存储权限才能保存视频');
          return;
        }
      }

      // 获取外部存储目录
      Directory? externalDir = await getExternalStorageDirectory();
      if (externalDir == null) {
        _showMessage('无法访问外部存储');
        return;
      }

      // 创建保存目录
      final saveDir = Directory('${externalDir.path}/Videos');
      if (!await saveDir.exists()) {
        await saveDir.create(recursive: true);
      }

      // 生成文件名
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'processed_video_$timestamp.mp4';
      final savePath = '${saveDir.path}/$fileName';

      // 复制文件
      final sourceFile = File(sourcePath);
      await sourceFile.copy(savePath);
      _showMessage('视频已保存到: $savePath');
      print('视频保存成功: $savePath');
    } catch (e) {
      _showMessage('保存失败: $e');
      print('保存视频失败: $e');
    }
  }

  // 显示消息提示
  void _showMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(child:
              GestureDetector(
                onTap: _toggleControls,
                child: Stack(
                  children: [
                    // 视频播放器
                    Center(
                      child: _hasError
                          ? _buildErrorWidget()
                          : _isInitialized
                          ? AspectRatio(
                        aspectRatio: _controller!.value.aspectRatio,
                        child: VideoPlayer(_controller!),
                      )
                          : _buildLoadingWidget(),
                    ),

                    // 控制层
                    if (_showControls && _isInitialized && !_hasError)
                      _buildControlsOverlay(),

                    // 返回按钮
                    if (_showControls)
                      Positioned(
                        top: 40,
                        left: 20,
                        child: SafeArea(
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              ),
              GestureDetector(
                  onTap: () async {
                    final dir = await getTemporaryDirectory();
                    final fgPath = await downloadToLocal('https://todobar.oss-cn-shenzhen.aliyuncs.com/video/front1.mp4', 'front1.mp4');
                    print('前景视频下载完成: ' + fgPath);
                    final outputPath = '${dir.path}/output_front_gpuimage.mp4';
                    final result = await NativeBridge.navigateDuplicateRemovalp(url, fgPath, outputPath);
                    print('result${result}');
                    
                    // 保存处理后的视频到本地
                    if (result != null && result.toString().isNotEmpty) {
                      await _saveVideoToLocal(result.toString());
                    } else {
                      _showMessage('视频处理失败，无法保存');
                    }
                  },
                  child: Container(
                    width: 100.w,
                    height: 50.h,
                    decoration: BoxDecoration(
                        color: Color(0xFFB4B9C6)
                    ),
                    child: Text('开始去重', style: TextStyle(color: Colors.black, fontSize: 14.sp)),
                  )
              ),
            ],
          )
        ]
      )
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 16),
          Text(
            '加载视频中...',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? '视频加载失败',
            style: const TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _hasError = false;
                _errorMessage = null;
              });
              _initializeVideo();
            },
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  Widget _buildControlsOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withOpacity(0.7),
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
      ),
      child: Column(
        children: [
          const Spacer(),
          // 底部控制栏
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                // 进度条
                VideoProgressIndicator(
                  _controller!,
                  allowScrubbing: true,
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  colors: VideoProgressColors(
                    playedColor: Colors.white,
                    bufferedColor: Colors.white.withOpacity(0.3),
                    backgroundColor: Colors.white.withOpacity(0.1),
                  ),
                ),
                const SizedBox(height: 10),
                // 控制按钮和时间
                Row(
                  children: [
                    // 播放/暂停按钮
                    IconButton(
                      onPressed: _togglePlayPause,
                      icon: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // 当前时间
                    Text(
                      _formatDuration(_controller!.value.position),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const Text(
                      ' / ',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    // 总时长
                    Text(
                      _formatDuration(_controller!.value.duration),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const Spacer(),
                    // 全屏按钮（装饰性，已经是全屏了）
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.fullscreen,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
