import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_module/utils/native_bridge.dart';
import 'package:flutter_module/utils/storage_util.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import './filter-goods.dart';
import './filter-video.dart';
import './filter-hot.dart';
import '../../../config/app_env.dart';
import 'package:flutter_module/routes/route_name.dart';
import 'package:flutter_module/utils/track_event.dart';

class TabsSearch extends StatefulWidget {
  final Function(Map<String, dynamic>) onGoodsTypeChange;
  final ValueNotifier<int> currentTabs;

  const TabsSearch({
    Key? key,
    required this.onGoodsTypeChange,
    required this.currentTabs,
  }) : super(key: key);

  @override
  State<TabsSearch> createState() => _TabsSearchState();
}

class _TabsSearchState extends State<TabsSearch> {
  final List<Map<String, dynamic>> _TabsList = [
    {'title': '爆单商品', 'value': 0},
    {'title': '爆款视频', 'value': 1},
    {'title': '营销热点', 'value': 2},
  ];

  Map<String, dynamic> _getParams() {
    return {
      // 'Tabs': _TabsList[widget.currentTabs.value]['value']
    };
  }

  void _changeTabsFunc(Map<String, dynamic> params) {
    widget.onGoodsTypeChange({...params, ..._getParams()});
  }

  Widget _buildInput(index) {
    return ValueListenableBuilder<int>(
      valueListenable: widget.currentTabs,
      builder: (context, currentTab, child) {
        return GestureDetector(
          onTap: () {
            if(widget.currentTabs.value == index) {
              return;
            }
            widget.currentTabs.value = index;
            widget.onGoodsTypeChange(_getParams());
            TrackEvent.report('Home', 'Click', index == 0 ? 'ExplosiveGoodsList' : index == 1 ? 'ExplosiveVideoList' : 'HotList', '', '{}');
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                if (currentTab == index)
                  Positioned(
                    bottom: -4,
                    child: Image.network(
                      'https://cdn-static.chanmama.com/sub-module/static-file/8/0/0841135bee',
                      width: 60.w,
                    ),
                  ),
                Text(
                  _TabsList[index]['title'],
                  style: TextStyle(
                    color:
                        currentTab == index
                            ? Color(0xFF333333)
                            : Color(0xFF999999),
                    fontSize: currentTab == index ? 15.sp : 14.sp,
                    fontWeight:
                        currentTab == index
                            ? FontWeight.bold
                            : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: widget.currentTabs,
      builder: (context, currentTab, child) {
        return Material(
          // elevation: 2.0,
          // color: Colors.white,
          child: Column(
            children: [
              // 搜索框部分将移到StickyTabsSearchDelegate中控制显示
              Row(
                children: [
                  ...List.generate(
                    _TabsList.length,
                    (index) => _buildInput(index),
                  ),
                ],
              ),
              if (currentTab == 0)
                FilterGoods(onTypeChange: _changeTabsFunc)
              else if (currentTab == 1)
                FilterVideo(onTypeChange: _changeTabsFunc)
              else if (currentTab == 2)
                FilterHot(onTypeChange: _changeTabsFunc),
            ],
          ),
        );
      },
    );
  }
}

// 创建可悬浮头部Widget
class StickyTabsSearchDelegate extends SliverPersistentHeaderDelegate {
  final TabsSearch child;
  double contentHeight = 90.h;

  StickyTabsSearchDelegate({required this.child});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    // 打印调试信息
    // print('构建StickyTabsSearchDelegate：shrinkOffset=$shrinkOffset, overlapsContent=$overlapsContent, maxExtent=$maxExtent');
    if (shrinkOffset > 0) {
      contentHeight = 176.h;
    } else if (shrinkOffset == 0) {
      contentHeight = 80.h;
    }
    // 创建一个简单的搜索框显示逻辑：当组件固定在顶部时(overlapsContent为true)显示搜索框
    return Container(
      color: Color(0xFFFEF7FF),
      child: Column(
        children: [
          // 顶部区域 - 只在固定时显示
          if (shrinkOffset > 0)
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 4.h,
                bottom: 4.h,
              ),
              child: GestureDetector(
                onTap: () async {
                  final Map userInfo = await StorageUtil.getUserInfo();
                  final token = userInfo['token'] ?? '';
                  bool isLoggedIn = token != '';
                  if (isLoggedIn) {
                    // Navigator.pushNamed(
                    //   context,
                    //   RouteName.h5RoutePage,
                    //   arguments: {
                    //     'url': AppEnv.openKJH5Url('/h5/kj/search?is_navi=0'),
                    //   },
                    // );
                  } else {
                    // NativeBridge.openUserLogin();
                  }
                },
                child: Container(
                  width: double.infinity,
                  height: 36.h,
                  margin: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    color: Colors.white,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(width: 12.w),
                      Image.network(
                        'https://cdn-static.chanmama.com/sub-module/static-file/5/3/11ed6da7b3',
                        width: 16.w,
                        height: 16.h,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '请输入关键字',
                        style: TextStyle(
                          color: Color(0xFFCCCCCC),
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 主要内容 - 始终显示
          Expanded(child: child),
        ],
      ),
    );
  }

  @override
  double get maxExtent => contentHeight;

  @override
  double get minExtent => contentHeight;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
