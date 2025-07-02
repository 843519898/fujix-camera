import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../components/update_app/check_app_version.dart';
import '../../../routes/route_name.dart';
import '../../../config/app_env.dart' show appEnv;
import 'provider/counterStore.p.dart';
// import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
// import 'package:ffmpeg_kit_flutter/ffmpeg_session.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:video_player/video_player.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';

class Home extends StatefulWidget {
  const Home({super.key, this.params});
  final dynamic params;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  late CounterStore _counter;
  FocusNode blankNode = FocusNode();
  List videoList = [
    'https://cdn-material-center.chanxuan.com/material/202506/老管家/整体展示/20250616157072gogmnkeGHQdeGCow_ssc.mp4',
    'https://cdn-material-center.chanxuan.com/material/202506/老管家/细节展示/20250616043514mxoRklccNzXWCYME_ssc.mp4',
    'https://cdn-material-center.chanxuan.com/material/202506/老管家/细节展示/20250616813442TUmWldNgUIpfbzBJ_ssc.mp4',
    'https://cdn-material-center.chanxuan.com/material/202506/老管家/动态展示/20250616819288vOIlZNgcEcaesFUZ_ssc.mp4',
    'https://cdn-material-center.chanxuan.com/material/202506/老管家/动态展示/20250616159945nAHKjfaWxnHLRdfL_ssc.mp4',
    'https://cdn-material-center.chanxuan.com/material/202506/老管家/商品展示/20250616601167jxGhPDOCMZueQITD_ssc.mp4',
    'https://cdn-material-center.chanxuan.com/material/202506/老管家/商品展示/20250616216551DTkpdaAmefWsYMSE_ssc.mp4',
    'https://cdn-material-center.chanxuan.com/material/202506/老管家/整体展示/20250616175419MdSWbCnQCjciAKrE_ssc.mp4'
  ];
  VideoPlayerController? _controller;
  bool _isLoading = false;
  String? _mergedVideoPath;
  String? _chromaKeyedVideoPath;
  VideoPlayerController? _chromaKeyedController;
  String? _mergedWithBgVideoPath;
  VideoPlayerController? _mergedWithBgController;
  String? _pipOutputPath;
  VideoPlayerController? _pipController;

  @override
  void initState() {
    super.initState();
    // _downloadAndMergeVideos();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _chromaKeyedController?.dispose();
    _mergedWithBgController?.dispose();
    _pipController?.dispose();
    super.dispose();
  }

  Future<void> _downloadAndMergeVideos() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final directory = await getTemporaryDirectory();
      List<String> localPaths = [];
      
      // 下载所有视频
      for (int i = 0; i < videoList.length; i++) {
        final response = await http.get(Uri.parse(videoList[i]));
        final localPath = '${directory.path}/video_$i.mp4';
        await File(localPath).writeAsBytes(response.bodyBytes);
        localPaths.add(localPath);
      }

      // 创建文件列表
      final txtPath = '${directory.path}/videos.txt';
      final txtFile = File(txtPath);
      String fileContent = '';
      for (String path in localPaths) {
        fileContent += "file '$path'\n";
      }
      await txtFile.writeAsString(fileContent);

      // 合并视频
      final outputPath = '${directory.path}/merged_video.mp4';
      // final session = await FFmpegKit.execute(
      //   '-f concat -safe 0 -i $txtPath -c copy $outputPath'
      // );
      //
      // final returnCode = await session.getReturnCode();
      //
      // if (returnCode?.isValueSuccess() ?? false) {
      //   setState(() {
      //     _mergedVideoPath = outputPath;
      //     _initializeVideoPlayer();
      //   });
      // }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _initializeVideoPlayer() async {
    if (_mergedVideoPath != null) {
      _controller = VideoPlayerController.file(File(_mergedVideoPath!))
        ..initialize().then((_) {
          setState(() {});
        });
    }
  }

  Future<void> _pickAndChromaKeyVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result != null && result.files.single.path != null) {
      String inputPath = result.files.single.path!;
      final directory = await getTemporaryDirectory();
      String outputPath = '${directory.path}/chroma_keyed_video.mp4';
      setState(() { _isLoading = true; });
      try {
        // ffmpeg抠图命令，去除白色区域
        // final session = await FFmpegKit.execute(
        //   '-i "$inputPath" -vf "chromakey=0xffffff:0.1:0.2" -c:a copy "$outputPath"'
        // );
        // final returnCode = await session.getReturnCode();
        // if (returnCode?.isValueSuccess() ?? false) {
        //   setState(() {
        //     _chromaKeyedVideoPath = outputPath;
        //   });
        //   _chromaKeyedController = VideoPlayerController.file(File(outputPath));
        //   await _chromaKeyedController!.initialize();
        //   setState(() {});
        // } else {
        //   print('ffmpeg处理失败');
        // }
      } catch (e) {
        print('Error: $e');
      } finally {
        setState(() { _isLoading = false; });
      }
    }
  }

  Future<String?> _downloadBackgroundVideo(String url) async {
    final directory = await getTemporaryDirectory();
    final localPath = '${directory.path}/background.mp4';
    final file = File(localPath);
    if (await file.exists()) return localPath;
    final response = await http.get(Uri.parse(url));
    await file.writeAsBytes(response.bodyBytes);
    return localPath;
  }

  Future<void> _pickChromaKeyAndMergeWithBg() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result != null && result.files.single.path != null) {
      String inputPath = result.files.single.path!;
      final directory = await getTemporaryDirectory();
      String chromaPath = '${directory.path}/chroma_keyed.mov';
      String outputPath = '${directory.path}/merged_with_bg.mp4';
      setState(() { _isLoading = true; });
      try {
        // 1. 抠图，生成带透明通道的mov，只抠掉纯白色（使用colorkey滤镜）
        // final chromaSession = await FFmpegKit.execute(
        //   '-y -i "$inputPath" -vf "colorkey=0xffffff:0.21:0.0,format=yuva420p" -c:v qtrle -an "$chromaPath"'
        // );
        // final chromaCode = await chromaSession.getReturnCode();
        // if (!(chromaCode?.isValueSuccess() ?? false)) {
        //   print('抠图失败');
        //   setState(() { _isLoading = false; });
        //   return;
        // }
        // 2. 下载背景视频
        String? bgPath = await _downloadBackgroundVideo('https://cdn-material-center.chanxuan.com/material/202506/老管家/整体展示/20250616157072gogmnkeGHQdeGCow_ssc.mp4');
        if (bgPath == null) {
          print('背景视频下载失败');
          setState(() { _isLoading = false; });
          return;
        }
        // 3. 合成，前景等比缩放填充背景宽度并居中（修正scale2ref参数）
        // final mergeSession = await FFmpegKit.execute(
        //   '-y -i "$bgPath" -i "$chromaPath" -filter_complex "[1:v][0:v]scale2ref=w=main_w:h=trunc(main_w/iw*ih/2)*2[fg][bg];[bg][fg]overlay=x=(W-w)/2:y=(H-h)/2:format=auto" -c:a copy "$outputPath"'
        // );
        // final mergeCode = await mergeSession.getReturnCode();
        // if (mergeCode?.isValueSuccess() ?? false) {
        //   _mergedWithBgVideoPath = outputPath;
        //   _mergedWithBgController = VideoPlayerController.file(File(outputPath));
        //   await _mergedWithBgController!.initialize();
        //   setState(() {});
        // } else {
        //   print('合成失败');
        // }
      } catch (e) {
        print('Error: $e');
      } finally {
        setState(() { _isLoading = false; });
      }
    }
  }

  Future<String> _downloadToLocal(String url, String filename) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    if (await file.exists()) return file.path;
    final response = await http.get(Uri.parse(url));
    await file.writeAsBytes(response.bodyBytes);
    return file.path;
  }

  Future<String?> gpuImagePip(String bgPath, String fgPath, String outputPath) async {
    const platform = MethodChannel('gpuimage_pip');
    try {
      final result = await platform.invokeMethod('pip', {
        'bgPath': bgPath,
        'fgPath': fgPath,
        'outputPath': outputPath,
      });
      print('文件是否存在: ${File(result).existsSync()}');
      print('文件大小: ${File(result).lengthSync()}');
      return result as String?;
    } catch (e) {
      print('GPUImage pip error: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _counter = Provider.of<CounterStore>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('home页面'),
        automaticallyImplyLeading: false,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(blankNode);
        },
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(child: contextWidget()),
              ],
            ),
      ),
    );
  }

  Widget contextWidget() {
    return ListView(
      children: List.generate(1, (index) {
        return Column(
          children: <Widget>[
            _button(
              '测试抠图颜色',
              onPressed: () {
                _pickChromaKeyAndMergeWithBg();
              },
            ),
            Text('状态管理值：${context.watch<CounterStore>().value}'),
            _button(
              '测试画中画',
              onPressed: () async {
                setState(() { _isLoading = true; });
                try {
                  // 选择本地背景视频
                  FilePickerResult? bgResult = await FilePicker.platform.pickFiles(type: FileType.video);
                  if (bgResult == null || bgResult.files.single.path == null) {
                    print('未选择背景视频');
                    setState(() { _isLoading = false; });
                    return;
                  }
                  final bgPath = bgResult.files.single.path!;
                  print('背景视频选择完成: ' + bgPath);
                  // 下载前景视频
                  final fgPath = await _downloadToLocal('https://todobar.oss-cn-shenzhen.aliyuncs.com/video/front1.mp4', 'front1.mp4');
                  print('前景视频下载完成: ' + fgPath);
                  final dir = await getTemporaryDirectory();
                  final outputPath = '${dir.path}/output_front_gpuimage.mp4';

                  final resultPath = await gpuImagePip(bgPath, fgPath, outputPath);
                  print(resultPath);
                  if (resultPath != null) {
                    _pipOutputPath = resultPath;
                    _pipController = VideoPlayerController.file(File(resultPath));
                    await _pipController!.initialize();
                    _pipController!.play();
                    setState(() {});
                  }
                } catch (e) {
                  print('GPUImage pip error: $e');
                } finally {
                  setState(() { _isLoading = false; });
                }
              },
            ),
            _button(
              '加+',
              onPressed: () {
                _counter.increment();
              },
            ),
            _button(
              '减-',
              onPressed: () {
                _counter.decrement();
              },
            ),
            _button(
              '强制更新App',
              onPressed: () {
                checkAppVersion(forceUpdate: true);
              },
            ),
            if (_controller != null && _controller!.value.isInitialized)
              AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    VideoPlayer(_controller!),
                    FloatingActionButton(
                      onPressed: () {
                        setState(() {
                          _controller!.value.isPlaying
                              ? _controller!.pause()
                              : _controller!.play();
                        });
                      },
                      child: Icon(
                        _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                      ),
                    ),
                  ],
                ),
              ),
            if (_chromaKeyedController != null && _chromaKeyedController!.value.isInitialized)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: AspectRatio(
                  aspectRatio: _chromaKeyedController!.value.aspectRatio,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      VideoPlayer(_chromaKeyedController!),
                      FloatingActionButton(
                        onPressed: () {
                          setState(() {
                            _chromaKeyedController!.value.isPlaying
                                ? _chromaKeyedController!.pause()
                                : _chromaKeyedController!.play();
                          });
                        },
                        child: Icon(
                          _chromaKeyedController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (_mergedWithBgController != null && _mergedWithBgController!.value.isInitialized)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: AspectRatio(
                  aspectRatio: _mergedWithBgController!.value.aspectRatio,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      VideoPlayer(_mergedWithBgController!),
                      FloatingActionButton(
                        onPressed: () {
                          setState(() {
                            _mergedWithBgController!.value.isPlaying
                                ? _mergedWithBgController!.pause()
                                : _mergedWithBgController!.play();
                          });
                        },
                        child: Icon(
                          _mergedWithBgController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (_pipController != null && _pipController!.value.isInitialized)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: AspectRatio(
                  aspectRatio: _pipController!.value.aspectRatio,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      VideoPlayer(_pipController!),
                      FloatingActionButton(
                        onPressed: () {
                          setState(() {
                            _pipController!.value.isPlaying
                                ? _pipController!.pause()
                                : _pipController!.play();
                          });
                        },
                        child: Icon(
                          _pipController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _button(String text, {VoidCallback? onPressed}) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(fontSize: 22.sp),
        ),
      ),
    );
  }
}
