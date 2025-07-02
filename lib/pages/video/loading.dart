import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_module/services/video.dart';
import 'package:flutter_module/utils/native_bridge.dart';
import 'package:flutter_module/utils/tool/cx_tools.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_session.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:video_player/video_player.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import '../../../routes/route_name.dart';

// 加载页面
class Loading extends StatefulWidget {
  const Loading({super.key, this.params, this.title, this.loadingText});
  final dynamic params;

  /// 页面标题
  final String? title;

  /// 加载文本
  final String? loadingText;

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading>
    with TickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _rotationAnimation;
  Animation<double>? _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController!);

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.4),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.4, end: 1.2),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0),
        weight: 40,
      ),
    ]).animate(_animationController!);

    _animationController?.repeat();

    _getVideoApi();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  void _getVideoApi() async {
    final res = await getVideoAndMaterial({
      'aweme_id': '7513128746962914571',
      'product_id': '3620553568169403454'
    });
    res as Map;
    if (res['code'] != 0 && res['code'] != 90009) {
      Navigator.pop(context);
      return;
    }
    if (res['code'] == 0) {
      _downFile(res);
    } else {
      await Future.delayed(const Duration(seconds: 2));
      _getVideoApi();
    }
  }

  void _downFile(res) async {
    List arr = res['data']['material'];
    List arrPath = [];
    for (int i = 0; i < arr.length; i++) {
      int timestampMs = DateTime.now().millisecondsSinceEpoch;
      final fgPath = await downloadToLocal(arr[i]['video_url'], '${timestampMs}_${i}.mp4');
      arrPath.add(fgPath);
    }
    print(arrPath);
    // final result = await NativeBridge.navigateToVideoClip(arrPath);
    // 创建文件列表
    final directory = await getTemporaryDirectory();

    final txtPath = '${directory.path}/videos.txt';
    final txtFile = File(txtPath);
    String fileContent = '';
    for (String path in arrPath) {
      fileContent += "file '$path'\n";
    }
    await txtFile.writeAsString(fileContent);

    // 合并视频
    final outputPath = '${directory.path}/merged_video.mp4';
    final session = await FFmpegKit.execute(
      '-f concat -safe 0 -i $txtPath -c copy -y $outputPath'
    );

    final returnCode = await session.getReturnCode();

    if (returnCode?.isValueSuccess() ?? false) {
      print('result: ${outputPath}');

      Navigator.pushNamed(context, RouteName.editVideo,
        arguments: {'videoUrl': outputPath},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_animationController == null || _rotationAnimation == null || _scaleAnimation == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AnimatedBuilder(
              animation: _animationController!,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationAnimation!.value * 2 * 3.14159,
                  child: Transform.scale(
                    scale: _scaleAnimation!.value,
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: Stack(
                        children: [
                          // 第4层 - 最模糊
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF15a0f7),
                                  Color(0xFF45f780),
                                  Color(0xFFff7424),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                              child: Container(),
                            ),
                          ),
                          // 第3层
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF15a0f7),
                                  Color(0xFF45f780),
                                  Color(0xFFff7424),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 12.5, sigmaY: 12.5),
                              child: Container(),
                            ),
                          ),
                          // 第2层
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF15a0f7),
                                  Color(0xFF45f780),
                                  Color(0xFFff7424),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: Container(),
                            ),
                          ),
                          // 第1层 - 最清晰
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFee280e),
                                  Color(0xFF15a0f7),
                                  Color(0xFF6ed15a),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
                              child: Container(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Text(
              widget.loadingText ?? '加载中...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
