import 'package:flutter/material.dart';
import 'package:flutter_module/pages/home/components/hot-video-popup-card.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/tool/resolve_cdn.dart';
import 'dart:convert';
import '../../../../services/common_service.dart'; // 接口
import '../../../components/page_loding/page_loding.dart';
import 'package:flutter/cupertino.dart';
// import '../../../utils/native_bridge.dart';
import '../../../config/app_env.dart';
import 'package:fluttertoast/fluttertoast.dart'; // 添加fluttertoast导入
import 'package:flutter_module/utils/storage_util.dart';
import '../../../routes/route_name.dart' show RouteName;

class HotVideoPopup extends StatefulWidget {
  final BuildContext context;

  HotVideoPopup({
    Key? key,
    required this.context,
  }) : super(key: key);

  @override
  State<HotVideoPopup> createState() => HotVideoPopupState();
}

class HotVideoPopupState extends State<HotVideoPopup> {
  List<Map<String, dynamic>> categoryList = [];
  List<dynamic> _videoList = [];
  StateSetter? _modalSetState;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoading = false;
  String search_str = '';
  List<dynamic> selectVideoList = [];
  final ScrollController _scrollController = ScrollController();
  final List<dynamic> tab = [
    {
      'name': '销量',
      'sort': 'product_volume',
    },
    {
      'name': '点赞',
      'sort': 'digg_count',
    },
    {
      'name': '评论',
      'sort': 'comment_count',
    },
  ];
  String sort = 'product_volume';
  String order_by = 'desc';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100 && !_isLoading && _hasMore) {
      print('_hasMore: $_hasMore');
      getHotDetailApi();
    }
  }

  void _onReset() {
    _currentPage = 1; // 重置页码
    _videoList = [];
    _isLoading = false;
    _hasMore = true;
    selectVideoList = [];
  }

  Future<void> showBottomSheet(goods) async {
    _onReset(); // 初始化
    setState(() {
      search_str = goods['search_str'];
      _isLoading = false;
    });
    showModalBottomSheet(
      context: widget.context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(widget.context).size.height * 0.7,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16.r),
        ),
      ),
      builder: (BuildContext bottomSheetContext) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              _modalSetState = setModalState;
              // 首次加载数据
              if (_videoList.isEmpty && !_isLoading && _hasMore) {
                getHotDetailApi();
              }
              return buildListItems();
            }
        );
      },
    );
  }

  void _onSelectVideo(video) {
    _modalSetState?.call(() {
      // 这个是多选
      // if (selectVideoList.contains(video)) {
      //   selectVideoList.remove(video);
      // } else {
      //   selectVideoList.add(video);
      // }
      // 这个是单选
      if (selectVideoList.isNotEmpty && selectVideoList[0]['aweme_id_ori'] == video['aweme_id_ori']) {
        selectVideoList = [];
      } else {
        selectVideoList = [video];
      }
      print(selectVideoList);
    });
  }

  Future<void> getHotDetailApi() async {
    if (_isLoading) return;
    _modalSetState?.call(() {
      _isLoading = true;
    });
    try {
      // 获取当前日期和一个月前的日期
      final DateTime now = DateTime.now();
      final DateTime oneMonthAgo = DateTime(now.year, now.month - 1, now.day);

      // 格式化日期为 yyyy-MM-dd
      String formatDate(DateTime date) {
        return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      }

      final res = await getQueryList({
        'search_str': search_str,
        'sort': sort,
        'order_by': order_by,
        'start_date': formatDate(oneMonthAgo),
        'end_date': formatDate(now),
        'page': _currentPage,
        'size': 10,
      });
      final dynamic list = res is Map ? res['data']['list'] : null;
      print('list: $list');
      if (list != null && list.isNotEmpty) {
        _modalSetState?.call(() {
          if (_currentPage == 1) {
            _videoList = list;
          } else {
            _videoList.addAll(list);
          }
          _hasMore = list.length >= 10;
          _currentPage++;
          _isLoading = false;
        });
      } else {
        _modalSetState?.call(() {
          _videoList = [];
          _hasMore = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading data: $e');
      _modalSetState?.call(() {
        _isLoading = false;
        _hasMore = false;
      });
    }
  }

  void _onClickEdit() async {
    final Map userInfo = await StorageUtil.getUserInfo();
    if (userInfo.containsKey('token') && userInfo['token'] != '') {
      // NativeBridge.navigateToNativePage(
      //   '${AppEnv.h5BaseUrl}/h5/kj/edit?is_navi=0&product_id=${search_str}&clipScene=HotProductCut',
      // );
      return;
    } else {
      // NativeBridge.openUserLogin();
    }
  }

  _onClipVideo() async {
    if (selectVideoList.isEmpty) {
      Fluttertoast.showToast(
          msg: '请先选择一个视频',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black87,
          textColor: Colors.white,
          fontSize: 16.0
      );
      return;
    }

    Navigator.pushNamed(context, RouteName.loading);


    final Map userInfo = await StorageUtil.getUserInfo();
    if (userInfo.containsKey('token') && userInfo['token'] != '') {
      // NativeBridge.navigateToNativePage(
      //   '${AppEnv.h5BaseUrl}/h5/kj/loading?is_navi=0&aweme_id=${selectVideoList[0]['aweme_id_ori'] ?? ''}&aweme_type=1&clipScene=HotProductCut&product_id=${search_str}',
      // );
      return;
    } else {
      // NativeBridge.openUserLogin();
    }
  }

  // 下拉刷新方法
  Future<void> _onRefresh() async {
    _currentPage = 1;
    await getHotDetailApi();
  }

  bool _isSelectedText(index) {
    return tab[index]['sort'] == sort;
  }

  bool _isSelectedIcon(index) {
    return order_by == 'desc';
  }

  Widget _buildSort(index) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _modalSetState?.call(() {
            sort = tab[index]['sort'];
            order_by = order_by == 'desc' ? 'asc' : 'desc';
            _onReset();
            _onRefresh();
          });
        },
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(tab[index]['name'], style: TextStyle(color: _isSelectedText(index) ? Color(0xFFA5DF2A) : Color(0xFF666666), fontSize: 12.sp)),
              SizedBox(width: 8.w),
              Column(
                children: [
                  Icon(CupertinoIcons.arrowtriangle_up_fill, size: 6.sp, color: _isSelectedText(index) ? _isSelectedIcon(index) ? Color(0xFFC9CDD4) : Color(0xFFA5DF2A) : Color(0xFFC9CDD4)),
                  Icon(CupertinoIcons.arrowtriangle_down_fill, size: 6.sp, color: _isSelectedText(index) ? _isSelectedIcon(index) ? Color(0xFFA5DF2A) : Color(0xFFC9CDD4) : Color(0xFFC9CDD4)),
                ],
              )
            ],
          ),
        ),
      )
    );
  }

  Widget buildListItems() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 50.h,
                child: Center(
                  child: Text('选择参照的爆款视频', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 16.sp)),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(widget.context);
                },
                child: Container(
                  padding: EdgeInsets.only(left: 12.w, top: 14.h),
                  child: Text('取消', style: TextStyle(color: Color(0xFF666666), fontSize: 14.sp)),
                ),
              )
            ],
          ),
          Row(
            children: [
              ...List.generate(
                tab.length,
                    (index) => _buildSort(index),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: _isLoading && _videoList.isEmpty
                  ? Center(child: PageLoading(text: '加载中...'))
                  : _videoList.isEmpty
                  ? Center(child: Expanded(
                  child: Container(
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                            borderRadius: BorderRadius.circular(100), // 50% 圆角（数值足够大即可）
                            child: Image.network(resolveCDN('@cdn?396cc44f889b'), width: 120.w, height: 120.h)
                        ),
                        SizedBox(height: 12),
                        Text('暂无爆款视频数据', style: TextStyle(color: Color(0xFF86909C), fontSize: 12),),
                        SizedBox(height: 6),
                        Text('尝试提供素材手动创作视频', style: TextStyle(color: Color(0xFF86909C), fontSize: 12),)
                      ],
                    ),
                  )
              ),)
                  : NotificationListener<ScrollNotification>(onNotification: (ScrollNotification scrollInfo) {
                  if (scrollInfo is ScrollEndNotification) {
                    if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 100 &&
                        !_isLoading &&
                        _hasMore) {
                      print('触发加载更多: $_currentPage');
                      getHotDetailApi();
                    }
                  }
                  return true;
                },
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _videoList.length + 1, // +1 是为了底部加载提示
                  itemBuilder: (context, index) {
                    if (index == _videoList.length) {
                      // 底部加载提示
                      return Container(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        alignment: Alignment.center,
                        child: _isLoading
                            ? PageLoading(text: '加载中...')
                            : (!_hasMore ? Text('没有更多数据了', style: TextStyle(color: Color(0xFF999999), fontSize: 14.sp)) : SizedBox()),
                      );
                    } else if (index == 0) {
                      // 使用HotDetailCardPopup渲染视频列表
                      return HomeVideoPopupCard(videoList: _videoList, selectVideoList: selectVideoList, onSelectVideo: _onSelectVideo);
                    } else {
                      return SizedBox(); // 这里不会被执行到，因为HotDetailCardPopup已经处理了所有视频
                    }
                  },
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          if (_videoList.isEmpty && !_hasMore)
            Row(
              children: [
                SizedBox(width: 12.w),
                Expanded(
                    child: GestureDetector(
                      onTap: () => _onClickEdit(),
                      child: Container(
                        height: 48.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Color(0xFF22262C),
                        ),
                        child: Center(
                          child: Text('手动创作', style: TextStyle(color: Color(0xFFA1F74A), fontSize: 16.sp, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    )
                ),
                SizedBox(width: 12.w),
              ],
            ),
          if (!(_videoList.isEmpty && !_hasMore))
            Row(
            children: [
              SizedBox(width: 12.w),
              GestureDetector(
                onTap: () => _onClickEdit(),
                child: Container(
                  width: 96.w,
                  height: 48.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Color(0xFFF2F3F5),
                  ),
                  child: Center(
                    child: Text('手动创作', style: TextStyle(color: Color(0xFF4E5969), fontSize: 16.sp)),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                  child: GestureDetector(
                    onTap: () => _onClipVideo(),
                    child: Container(
                      height: 48.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Color(0xFF22262C),
                      ),
                      child: Center(
                        child: Text('开始一键快剪', style: TextStyle(color: Color(0xFFA1F74A), fontSize: 16.sp, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  )
              ),
              SizedBox(width: 12.w),
            ],
          ),
          SizedBox(height: 20.h)
        ]
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
