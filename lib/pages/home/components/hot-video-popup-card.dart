import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/tool/cx_tools.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math';
import '../../../../utils/url_launcher_util.dart';
// import '../../../../utils/native_bridge.dart';
import '../../../../utils/tool/resolve_cdn.dart';
import 'package:flutter/cupertino.dart';

class HomeVideoPopupCard extends StatefulWidget {
  final List<dynamic> videoList;
  final List<dynamic> selectVideoList;
  final Function(Map<String, dynamic>) onSelectVideo;

  const HomeVideoPopupCard({
    Key? key,
    required this.videoList,
    required this.selectVideoList,
    required this.onSelectVideo,
  }) : super(key: key);

  @override
  State<HomeVideoPopupCard> createState() => HomeVideoPopupCardState();
}

class HomeVideoPopupCardState extends State<HomeVideoPopupCard> {
  // 格式化视频时长
  String formatDuration(dynamic duration) {
    if (duration == null) return '00:00';
    int totalSeconds = (int.tryParse(duration.toString()) ?? 0) ~/ 1000;
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _onSelectVideo(video) {
    setState(() {
      widget.onSelectVideo(video);
    });
  }

  // 使用内置浏览器在应用内打开视频（新方法）
  void _openInAppBrowser(video) async {
    if (video.containsKey('aweme_id_ori')) {
      final String awemeIdOri = video['aweme_id_ori'].toString();
      await UrlLauncherUtil.openDouyinVideoInApp(awemeIdOri, context);
    }
  }

  bool _isVideoSelected(video) {
    return widget.selectVideoList.any((selectedVideo) => selectedVideo['aweme_id_ori'] == video['aweme_id_ori']);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.videoList.isEmpty) {
      return SizedBox.shrink();
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Wrap(
        spacing: 12, // 水平间距
        runSpacing: 12, // 垂直间距
        children: widget.videoList.map((video) {
          return SizedBox(
            width: MediaQuery.of(context).size.width / 3 - 18, // 计算宽度
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: CachedNetworkImage(
                            imageUrl: (video['aweme_cover'] != null && video['aweme_cover'].isNotEmpty) ? video['aweme_cover'] : 'https://cdn-static.chanmama.com/sub-module/static-file/6/c/a29103fab8',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 146.h,
                            placeholder: (context, url) => Container(
                              width: double.infinity,
                              height: 146.h,
                              color: Colors.grey[200],
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Colors.grey[400],
                                  strokeWidth: 2.0,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              width: double.infinity,
                              height: 146.h,
                              color: Colors.grey[200],
                              child: Image.network('https://cdn-static.chanmama.com/sub-module/static-file/6/c/a29103fab8', width: 48.w, height: 48.h),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              height: 14.h,
                              margin: EdgeInsets.only(right: 6.w, top: 6.h),
                              padding: EdgeInsets.only(left: 4.w, right: 4.h),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                color: Color.fromRGBO(0, 0, 0, 0.4),
                              ),
                              child: Center(
                                child: Text(formatDuration(video['duration']), style: TextStyle(color: Colors.white, fontSize: 10.sp)),
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                            left: 6.w,
                            top: 6.h,
                            child: GestureDetector(
                              onTap: () => _onSelectVideo(video),
                              child: Container(
                                  width: 18.w,
                                  height: 18.h,
                                  decoration: BoxDecoration(
                                    color: _isVideoSelected(video) ? Color(0xFFA5DF2A) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: Colors.white, width: 1),
                                  ),
                                  child: Center(
                                    child: _isVideoSelected(video) ? Icon(CupertinoIcons.checkmark_alt, size: 12.sp, color: Colors.white) : Container(),
                                  )
                              ),
                            )
                        ),
                        Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: GestureDetector(
                              onTap: () => _openInAppBrowser(video),
                              child: Center(
                                child: Image.network('https://cdn-static.chanmama.com/sub-module/static-file/8/1/c2c34214b8', width: 20.w, height: 20.h),
                              ),
                            )
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
                                Container(
                                  height: 27.h,
                                  padding: EdgeInsets.only(left: 8.w, right: 8.w),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.r),
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
                                      Image.network('https://cdn-static.chanmama.com/sub-module/static-file/8/4/c761b103c3', width: 12.w, height: 12.h),
                                      SizedBox(width: 2.w),
                                      Text(
                                        getNumberFloorShow(video['comment_count'], 0),
                                        style: TextStyle(color: Colors.white, fontSize: 9.sp, fontWeight: FontWeight.w600),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(width: 4.w),
                                      Text('销量', style: TextStyle(color: Colors.white, fontSize: 9.sp, fontWeight: FontWeight.w600)),
                                      SizedBox(width: 2.w),
                                      Text(
                                        getNumberFloorShow(video['product_volume'], 0),
                                        style: TextStyle(color: Colors.white, fontSize: 9.sp, fontWeight: FontWeight.w600),
                                        // overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ))
                      ],
                    ),
                  ]),
            ),
          );
        }).toList(),
      ),
    );
  }
}
