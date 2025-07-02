import 'package:flutter/material.dart';
import 'package:flutter_module/utils/storage_util.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/tool/cx_tools.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math';
import '../../../../utils/url_launcher_util.dart';
// import '../../../../utils/native_bridge.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io' show Platform;
import '../../../config/app_env.dart';
import '../../../routes/route_name.dart';

class HomeCardVideo extends StatelessWidget {
  final List<dynamic> videoList;
  const HomeCardVideo({Key? key, required this.videoList}) : super(key: key);

  // 使用内置浏览器在应用内打开视频（新方法）
  void _openInAppBrowser(video, context) async {
    if (video.containsKey('aweme_info')) {
      final String awemeIdOri = video['aweme_info']['aweme_id_ori'].toString();
      await UrlLauncherUtil.openDouyinVideoInApp(awemeIdOri, context);
    }
  }

  void _onGoDetail(goods, context) async {
    final Map userInfo = await StorageUtil.getUserInfo();
    final token = userInfo['token'] ?? '';
    bool isLoggedIn = token != '';
    if (isLoggedIn) {
      String product_id = goods['promotion_id'];
      // Navigator.pushNamed(
      //   context,
      //   RouteName.h5RoutePage,
      //   arguments: {'url': AppEnv.buildGoodsDetailUrl(product_id)},
      // );
    } else {
      // NativeBridge.openUserLogin();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (videoList.isEmpty) {
      return SizedBox.shrink();
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Wrap(
        spacing: 12, // 水平间距
        runSpacing: 12, // 垂直间距
        children:
            videoList.map((video) {
              return SizedBox(
                width: MediaQuery.of(context).size.width / 2 - 24,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(8.r),
                            ),
                            child: CachedNetworkImage(
                              imageUrl:
                                  (video['aweme_info']['aweme_cover'] != null &&
                                          video['aweme_info']['aweme_cover']
                                              .isNotEmpty)
                                      ? video['aweme_info']['aweme_cover']
                                      : 'https://cdn-static.chanmama.com/sub-module/static-file/6/c/a29103fab8',
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 215.h,
                              placeholder:
                                  (context, url) => Container(
                                    width: double.infinity,
                                    height: 215.h,
                                    color: Colors.grey[200],
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.grey[400],
                                        strokeWidth: 2.0,
                                      ),
                                    ),
                                  ),
                              errorWidget:
                                  (context, url, error) => Container(
                                    width: double.infinity,
                                    height: 215.h,
                                    color: Colors.grey[200],
                                    child: Image.network(
                                      'https://cdn-static.chanmama.com/sub-module/static-file/6/c/a29103fab8',
                                      width: 48.w,
                                      height: 48.h,
                                    ),
                                  ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: GestureDetector(
                              onTap: () => _openInAppBrowser(video, context),
                              child: Center(
                                child: Image.network(
                                  'https://cdn-static.chanmama.com/sub-module/static-file/c/0/3691807194',
                                  width: 34.w,
                                  height: 34.h,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  onTap:
                                      () => _onGoDetail(
                                        video.containsKey('product_info')
                                            ? video['product_info']
                                            : {'promotion_id': ''},
                                        context,
                                      ),
                                  child: Container(
                                    margin: EdgeInsets.only(left: 8.w),
                                    padding: EdgeInsets.only(
                                      left: 8.w,
                                      right: 8.w,
                                    ),
                                    width: 120.w,
                                    height: 22.h,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4.r),
                                      color: Colors.black54,
                                    ),
                                    child: Row(
                                      children: [
                                        Image.network(
                                          'https://cdn-static.chanmama.com/sub-module/static-file/7/d/d9714815ce',
                                          width: 12.w,
                                          height: 12.h,
                                        ),
                                        SizedBox(width: 4.w),
                                        Expanded(
                                          child: Text(
                                            video['product_info']['title'] ??
                                                '视频标题',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10.sp,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.left,
                                            softWrap: false,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 27.h,
                                  padding: EdgeInsets.only(
                                    left: 8.w,
                                    right: 8.w,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.black.withOpacity(0),
                                        Colors.black.withOpacity(0.6),
                                      ],
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        '销量',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 9.sp,
                                        ),
                                      ),
                                      SizedBox(width: 2.w), // 添加间距()
                                      Text(
                                        getNumberFloorShow(
                                          video['aweme_info']['product_volume'],
                                        ),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 9.sp,
                                        ),
                                      ),
                                      SizedBox(width: 4.w), // 添加间距()
                                      Image.network(
                                        'https://cdn-static.chanmama.com/sub-module/static-file/8/4/c761b103c3',
                                        width: 12.w,
                                        height: 12.h,
                                      ),
                                      SizedBox(width: 2.w), // 添加间距()
                                      Text(
                                        getNumberFloorShow(
                                          video['aweme_info']['comment_count'],
                                        ),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 9.sp,
                                        ),
                                      ),
                                      SizedBox(width: 4.w), // 添加间距()
                                      Image.network(
                                        'https://cdn-static.chanmama.com/sub-module/static-file/3/1/2eddbf71a3',
                                        width: 12.w,
                                        height: 12.h,
                                      ),
                                      SizedBox(width: 2.w), // 添加间距()
                                      Text(
                                        getNumberFloorShow(
                                          video['aweme_info']['digg_count'],
                                        ),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 9.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.w),
                        child: Material(
                          child: Ink(
                            child: InkWell(
                              onTap: () async {
                                final Map userInfo = await StorageUtil.getUserInfo();
                                if (userInfo.containsKey('token') && userInfo['token'] != '') {
                                  // NativeBridge.navigateToNativePage(
                                  //   '${AppEnv.h5BaseUrl}/h5/kj/loading?is_navi=0&aweme_id=${video['aweme_info']['aweme_id']}&aweme_type=1&clipScene=SameStyleCut',
                                  // ).then((success) {
                                  //   if (!success) {
                                  //     Fluttertoast.showToast(
                                  //       msg: "跳转原生失败",
                                  //       toastLength: Toast.LENGTH_SHORT,
                                  //       gravity: ToastGravity.CENTER,
                                  //       timeInSecForIosWeb: 1,
                                  //       backgroundColor: Colors.black54,
                                  //       textColor: Colors.white,
                                  //       fontSize: 16.0,
                                  //     );
                                  //     // 如果原生跳转失败，尝试使用内置浏览器
                                  //     // UrlLauncherUtil.launchInAppBrowser('http://baidu.com');
                                  //   }
                                  // });
                                  return;
                                } else {
                                  // NativeBridge.openUserLogin();
                                }
                              },
                              child: Container(
                                height: 32.h,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4.r),
                                  color: Color(0xFFF7F8FA),
                                ),
                                child: Center(
                                  child: Text(
                                    '一键快剪',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
      ),
      // child: GridView.builder(
      //   shrinkWrap: true,
      //   physics: NeverScrollableScrollPhysics(),
      //   padding: EdgeInsets.only(top: 0.h),
      //   gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
      //     maxCrossAxisExtent:
      //         (MediaQuery.of(context).size.width - 24.w - 10.w) /
      //             2, // 屏幕宽度减去padding和间距
      //     childAspectRatio: 0.64, // 宽高比1:1
      //     mainAxisSpacing: 10.h,
      //     crossAxisSpacing: 10.w,
      //     // mainAxisExtent: 263.h, // 根据内容预估的高度
      //   ),
      //   itemCount: videoList.length,
      //   itemBuilder: (context, index) {
      //     final video = videoList[index];
      //     // 计算卡片单元格的宽度，用于图片URL resize
      //     final double cellWidth =
      //         (MediaQuery.of(context).size.width - 24.w - 10.w) / 2;
      //     // 安全地获取原始封面URL
      //     final String? originalCoverUrl =
      //         video['aweme_info']?['aweme_cover'] as String?;
      //     // 使用 solveCdnImgUrlResize 处理URL
      //     final String? processedCoverUrl =
      //         solveCdnImgUrlResize(cellWidth.round(), originalCoverUrl);
      //
      //     return
      //   },
      // ),
    );
  }
}
