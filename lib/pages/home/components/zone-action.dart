import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/gestures.dart'; // 导入 gestures 以使用 Tolerance
import '../../../../routes/route_name.dart';
// import '../../../utils/native_bridge.dart';
import '../../../config/app_env.dart';
// import '../../../providers/user_provider.dart';
import 'package:provider/provider.dart';
import '../../../services/vip.dart';
import 'package:flutter_module/pages/vip/buy_vip_sheet.dart';
import '../../../utils/storage_util.dart';
import 'package:flutter_module/utils/track_event.dart';

class ZoneAction extends StatefulWidget {
  final Function(int) handleTabChange;
  final Function() onReset;

  const ZoneAction({
    Key? key,
    required this.handleTabChange,
    required this.onReset,
  }) : super(key: key);

  @override
  State<ZoneAction> createState() => _ZoneActionState();
}

class _ZoneActionState extends State<ZoneAction> {
  final ScrollController _scrollController = ScrollController();
  double _scrollProgress = 0.0;
  bool _showIndicator = false;

  @override
  void initState() {
    super.initState();
    // 监听器现在是状态更新的主要来源
    _scrollController.addListener(_updateScrollIndicator);
    // 仍然在第一帧后检查一次初始状态
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkIfScrollable());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollIndicator);
    _scrollController.dispose();
    super.dispose();
  }

  // 检查是否可滚动（主要用于初始状态）
  void _checkIfScrollable() {
    if (!mounted || !_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final shouldShow = maxScroll > (0.0 + Tolerance.defaultTolerance.distance);

    // 仅在初始状态与计算结果不同时更新一次
    if (shouldShow != _showIndicator) {
      // 直接调用 setState，因为这是在 postFrameCallback 中
      if (mounted) {
        setState(() {
          _showIndicator = shouldShow;
          // 如果变为可见，立即计算一次进度
          if (shouldShow) {
            _calculateAndUpdateProgress();
          }
        });
      }
    }
  }

  // 监听器回调，更新指示器状态
  void _updateScrollIndicator() {
    _calculateAndUpdateProgress();
  }

  // 提取计算和更新进度的逻辑
  void _calculateAndUpdateProgress() {
    if (!mounted || !_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    final shouldShow = maxScroll > (0.0 + Tolerance.defaultTolerance.distance);

    final progress =
        shouldShow ? (currentScroll / maxScroll).clamp(0.0, 1.0) : 0.0;

    // 只要进度或可见性有变化，就更新状态
    if (progress != _scrollProgress || shouldShow != _showIndicator) {
      if (mounted) {
        setState(() {
          _scrollProgress = progress;
          _showIndicator = shouldShow;
        });
      }
    }
  }

  void _onClip1() {
    TrackEvent.report('Home', 'Click', 'CutSame', '', '{}');
    widget.handleTabChange(1);
  }

  void _onClip2() {
    TrackEvent.report('Home', 'Click', 'CutExplosiveGoods', '', '{}');
    widget.handleTabChange(0);
  }

  void _handleJump() {}

  void _onTools() {}

  void _onClipAllVideo() {
    TrackEvent.report('Home', 'Click', 'CutHot', '', '{}');
    widget.handleTabChange(2);
    return;
    // Navigator.pushNamed(context, RouteName.multiClip);
  }

  @override
  Widget build(BuildContext context) {
    // 定义指示器尺寸和颜色
    const double trackWidth = 24.0;
    const double indicatorWidth = 16.0;
    const double indicatorHeight = 4.0;
    const Color indicatorColor = Color(0xFFA1F74A);
    final Color trackColor = Colors.grey[300] ?? Colors.grey;

    final double maxIndicatorOffset = trackWidth - indicatorWidth;
    final double currentIndicatorOffset = _scrollProgress * maxIndicatorOffset;

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _onClip2,
                child: Container(
                  height: 80.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAFAD6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        'https://cdn-static.chanmama.com/sub-module/static-file/8/7/5466dd4a8b',
                        width: 30.w,
                        height: 30.h,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '剪爆品',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: _onClip1,
                child: Container(
                  height: 80.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAFAD6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        'https://cdn-static.chanmama.com/sub-module/static-file/c/5/5badde78b3',
                        width: 30.w,
                        height: 30.h,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '剪同款',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _onGoToGigitalPeople,
                child: Container(
                  height: 75.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAFAD6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        'https://cdn-static.chanmama.com/sub-module/static-file/2/7/df961800d6',
                        width: 26.w,
                        height: 26.h,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '剪数字人',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: _onClipAllVideo,
                child: Container(
                  height: 75.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAFAD6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        'https://cdn-static.chanmama.com/sub-module/static-file/4/0/749e3164e2',
                        width: 26.w,
                        height: 26.h,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '剪热点',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: _onClipVideo,
                child: Container(
                  height: 75.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAFAD6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        'https://cdn-static.chanmama.com/sub-module/static-file/2/a/2e1f1b5eb3',
                        width: 26.w,
                        height: 26.h,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '剪视频',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Column(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              // 移除了 NotificationListener
              child: Consumer(
                builder: (context, userProvider, child) {
                  // if (!userProvider.isRelease) {
                  //   return SizedBox();
                  // }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Container(
                      //   width: 64.w,
                      //   margin: EdgeInsets.only(right: 8.w),
                      //   child: _handleButton(
                      //     'https://cdn-static.chanmama.com/sub-module/static-file/d/6/d6017e4627',
                      //     'AI包装',
                      //     onTapCallback: _onGoToAiDecorate,
                      //   ),
                      // ),
                      // Container(
                      //   width: 64.w,
                      //   margin: EdgeInsets.only(right: 8.w),
                      //   child: _handleButton(
                      //       'https://cdn-static.chanmama.com/sub-module/static-file/8/a/25c11f7ce8',
                      //       '视频去重',
                      //       onTapCallback:
                      //           _onGoToAiVideoDuplicateTool), // 修改点：传入指定的回调
                      // ),
                      // Container(
                      //   width: 64.w,
                      //   margin: EdgeInsets.only(right: 8.w),
                      //   child: _handleButton(
                      //       'https://cdn-static.chanmama.com/sub-module/static-file/0/9/a786fa3d6c',
                      //       '视频分镜', onTapCallback: () async {
                      //     final Map userInfo =
                      //     await StorageUtil.getUserInfo();
                      //     if (userInfo.containsKey('token') &&
                      //         userInfo['token'] != '') {
                      //       Navigator.pushNamed(
                      //         context,
                      //         RouteName.splitScreen,
                      //       );
                      //       return;
                      //     } else {
                      //       NativeBridge.openUserLogin();
                      //     }
                      //   }),
                      // ),
                      Container(
                        width: 64.w,
                        margin: EdgeInsets.only(right: 8.w),
                        child: _handleButton(
                          'https://cdn-static.chanmama.com/sub-module/static-file/e/9/5d396fbf0d',
                          '去水印',
                          onTapCallback: () async {
                            TrackEvent.report('Home', 'Click', 'Removewatermark', '', '{}');
                            final Map userInfo =
                                await StorageUtil.getUserInfo();
                            if (userInfo.containsKey('token') &&
                                userInfo['token'] != '') {
                              // Navigator.pushNamed(
                              //   context,
                              //   RouteName.h5RoutePage,
                              //   arguments: {
                              //     'url':
                              //         '${AppEnv.h5BaseUrl}/h5/kj/remove-watermark',
                              //   },
                              // );
                              return;
                            } else {
                              // NativeBridge.openUserLogin();
                            }
                          },
                        ),
                      ),
                      Container(
                        width: 64.w,
                        margin: EdgeInsets.only(right: 8.w),
                        child: _handleButton(
                          'https://cdn-static.chanmama.com/sub-module/static-file/d/f/97e517c11e',
                          '文案提取',
                          onTapCallback: () async {
                            TrackEvent.report('Home', 'Click', 'CopyExtraction', '', '{}');
                            final Map userInfo =
                                await StorageUtil.getUserInfo();
                            if (userInfo.containsKey('token') &&
                                userInfo['token'] != '') {
                              // Navigator.pushNamed(
                              //   context,
                              //   RouteName.h5RoutePage,
                              //   arguments: {
                              //     'url':
                              //         '${AppEnv.h5BaseUrl}/h5/kj/text-extract',
                              //   },
                              // );
                              return;
                            } else {
                              // NativeBridge.openUserLogin();
                            }
                          },
                        ),
                      ),
                      Container(
                        width: 64.w,
                        margin: EdgeInsets.only(right: 8.w),
                        child: _handleButton(
                          'https://cdn-static.chanmama.com/sub-module/static-file/0/0/5b70d8f057',
                          'AI文案',
                          onTapCallback: () async {
                            TrackEvent.report('Home', 'Click', 'AIWriter', '', '{}');
                            final Map userInfo =
                                await StorageUtil.getUserInfo();
                            if (userInfo.containsKey('token') &&
                                userInfo['token'] != '') {
                              // Navigator.pushNamed(
                              //   context,
                              //   RouteName.h5RoutePage,
                              //   arguments: {
                              //     'url':
                              //         '${AppEnv.h5BaseUrl}/h5/kj/text-generate',
                              //   },
                              // );
                              return;
                            } else {
                              // NativeBridge.openUserLogin();
                            }
                          },
                        ),
                      ),
                      Container(
                        width: 64.w,
                        margin: EdgeInsets.only(right: 8.w),
                        child: _handleButton(
                          'https://cdn-static.chanmama.com/sub-module/static-file/0/8/07bd3630ca',
                          '账号估值',
                          onTapCallback: () async {
                            final Map userInfo =
                                await StorageUtil.getUserInfo();
                            if (userInfo.containsKey('token') &&
                                userInfo['token'] != '') {
                              // NativeBridge.navigateToNativePage(
                              //   'kjapp://wxmini?path=pagesB/valuation/index?id=gh_31dc613661b0',
                              // );
                              return;
                            } else {
                              // NativeBridge.openUserLogin();
                            }
                          },
                        ),
                      ),
                      Container(
                        width: 64.w,
                        padding: EdgeInsets.only(right: 8.w),
                        child: _handleButton(
                          'https://cdn-static.chanmama.com/sub-module/static-file/8/2/96c6932d56',
                          '违禁检测',
                          onTapCallback: () async {
                            final Map userInfo =
                                await StorageUtil.getUserInfo();
                            if (userInfo.containsKey('token') &&
                                userInfo['token'] != '') {
                              // NativeBridge.navigateToNativePage(
                              //   'kjapp://wxmini?path=pages_video_tools/duplication_detection/index?id=gh_31dc613661b0',
                              // );
                              return;
                            } else {
                              // NativeBridge.openUserLogin();
                            }
                          },
                        ),
                      ),
                      Container(
                        width: 64.w,
                        margin: EdgeInsets.only(right: 8.w),
                        child: _handleButton(
                          'https://cdn-static.chanmama.com/sub-module/static-file/2/9/f0cdb10325',
                          '工具箱',
                          onTapCallback: () async {
                            TrackEvent.report('Home', 'Click', 'ToolBox', '', '{}');
                            final Map userInfo =
                            await StorageUtil.getUserInfo();
                            if (userInfo.containsKey('token') &&
                                userInfo['token'] != '') {
                              // Navigator.pushNamed(
                              //   context,
                              //   RouteName.h5RoutePage,
                              //   arguments: {
                              //     'url': '${AppEnv.h5BaseUrl}/h5/kj/toolbox',
                              //   },
                              // );
                              return;
                            } else {
                              // NativeBridge.openUserLogin();
                            }
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            // 动态指示器实现 (保持不变)
            if (_showIndicator)
              Container(
                width: trackWidth.w,
                height: indicatorHeight.h,
                decoration: BoxDecoration(
                  color: trackColor,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                // 使用 Stack 和 Positioned 实现滑块定位，更精确
                child: Stack(
                  children: [
                    Positioned(
                      left: currentIndicatorOffset.w,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: indicatorWidth.w,
                        decoration: BoxDecoration(
                          color: indicatorColor,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              SizedBox(height: indicatorHeight.h), // 保持布局高度一致
            const SizedBox(height: 8),
          ],
        ),
      ],
    );
  }

  Widget _handleButton(icon, title, {VoidCallback? onTapCallback}) {
    // 修改点：增加可选参数 onTapCallback
    return GestureDetector(
      onTap:
          onTapCallback ??
          _handleJump, // 修改点：如果 onTapCallback 不为 null，则使用它，否则使用 _handleJump
      // 给按钮一个最小宽度，避免内容过少时挤在一起
      child: Container(
        constraints: BoxConstraints(minWidth: 60.w), // 设置最小宽度
        height: 80.h,
        padding: EdgeInsets.symmetric(horizontal: 4.w), // 增加水平内边距
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(icon, width: 24.w, height: 24.h),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(color: Colors.black, fontSize: 11.sp)),
          ],
        ),
      ),
    );
  }

  void _onGoToGigitalPeople() async {
    TrackEvent.report('Home', 'Click', 'CutDigitalHuman', '', '{}');
    // final userProvider = Provider.of<UserProvider>(context, listen: false);
    // if (userProvider.isLoggedIn) {
    //   final res = await getUserVip();
    //   res as Map;
    //   if (res.containsKey('free') && res['free']) {
    //     // 无会员，需要购买才能使用
    //     await BuyVipSheet.show(
    //       context,
    //       onClose: () {},
    //       onOk: () {
    //         // Navigator.pushNamed(context, RouteName.h5RoutePage, arguments: {
    //         //   'url': '${AppEnv.h5BaseUrl}/h5/kj/digital-people?is_navi=0',
    //         // });
    //       },
    //     );
    //     widget.onReset();
    //   } else {
    //     Navigator.pushNamed(
    //       context,
    //       RouteName.h5RoutePage,
    //       arguments: {
    //         'url': '${AppEnv.h5BaseUrl}/h5/kj/digital-people?is_navi=0',
    //       },
    //     );
    //   }
    //   // NativeBridge.navigateToNativePage(
    //   //   '${AppEnv.h5BaseUrl}/h5/kj/digital-people?is_navi=0',
    //   // );
    // } else {
    //   NativeBridge.openUserLogin();
    // }
    // Navigator.pushNamed(context, RouteName.digitalPeople);
  }

  void _onClipVideo() async {
    TrackEvent.report('Home', 'Click', 'CutVideo', '', '{}');
    final Map userInfo = await StorageUtil.getUserInfo();
    if (userInfo.containsKey('token') && userInfo['token'] != '') {
      // NativeBridge.navigateToNativePage(
      //   '${AppEnv.h5BaseUrl}/h5/kj/edit?is_navi=0&clipScene=VideoCut',
      // );
      return;
    } else {
      // NativeBridge.openUserLogin();
    }
  }

  // 跳转视频去重工具
  void _onGoToAiVideoDuplicateTool() {
    // Navigator.pushNamed(context, RouteName.aiVideoDuplicateTool);
  }

  void _onGoToAiDecorate() {
    debugPrint('点击了AI包装');
    // Navigator.pushNamed(context, RouteName.aiDecorate);
  }
}
