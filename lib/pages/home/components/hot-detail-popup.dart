import 'package:flutter/material.dart';
import 'package:flutter_module/pages/home/components/hot-detail-card-popup.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/tool/resolve_cdn.dart';
import 'dart:convert';
import '../../../../services/common_service.dart'; // 接口
import '../../../components/page_loding/page_loding.dart';


class HotDetailPopup extends StatefulWidget {
  final BuildContext context;
  final Map searchParams;

  HotDetailPopup({
    Key? key,
    required this.context,
    required this.searchParams,
  }) : super(key: key);

  @override
  State<HotDetailPopup> createState() => HotDetailPopupState();
}

class HotDetailPopupState extends State<HotDetailPopup> {
  List<Map<String, dynamic>> categoryList = [];
  List<dynamic> _videoList = [];
  StateSetter? _modalSetState;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoading = false;
  Map hot = {};
  final ScrollController _scrollController = ScrollController();

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
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100 &&
        !_isLoading &&
        _hasMore) {
      getHotDetailApi();
    }
  }

  Future<void> showBottomSheet(item) async {
    setState(() {
      hot = item;
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
              if (_videoList.isEmpty && !_isLoading) {
                _currentPage = 1; // 重置页码
                getHotDetailApi();
              }
              return buildListItems();
            }
        );
      },
    );
  }

  Future<void> getHotDetailApi() async {
    if (_isLoading) return;
    _modalSetState?.call(() {
      _isLoading = true;
    });
    Map params = {};
    if (widget.searchParams['type'] == '3' || widget.searchParams.containsKey('type') == false) {
      params = {
        'category_id': int.parse(widget.searchParams['category_id'] ?? '-1'),
        'create_time_filter': -1,
        'date_type': int.parse(widget.searchParams['date_type'] ?? '1'),
        'promote_type': 1,
        'search_type': 12,
        'sort': 'digg_count',
        'title': hot['title'],
        'page': _currentPage,
        'size': 10,
      };
    }
    if (widget.searchParams['type'] == '4') {
      params = {
        'category_id': int.parse(widget.searchParams['category_id'] ?? '-1'),
        'create_time_filter': -1,
        'date_type': int.parse(widget.searchParams['date_type'] ?? '1'),
        'promote_type': 1,
        'search_type': 3,
        'sort': 'digg_count',
        'title': hot['title'],
        'page': _currentPage,
        'size': 10,
        'index': hot['rank'],
      };
    }
    if (widget.searchParams['type'] == '2') {
      params = {
        'create_time_filter': -1,
        'date_type': int.parse(widget.searchParams['date_type'] ?? '0'),
        'hot_inner_type': int.parse(widget.searchParams['hot_inner_type'] ?? '1'),
        'hot_type': 1,
        'search_type': 1,
        'sort': 'digg_count',
        'title': hot['title'],
        'page': _currentPage,
        'size': 10,
        'index': hot['rank'],
      };
    }
    if (widget.searchParams['type'] == '1') {
      params = {
        'create_time_filter': -1,
        'hot_inner_type': int.parse(widget.searchParams['hot_inner_type'] ?? '1'),
        'hot_type': 2,
        'search_type': 1,
        'sort': 'digg_count',
        'title': hot['title'],
        'page': _currentPage,
        'size': 10,
        'index': hot['rank'],
      };
    }

    try {
      final res = await getHotApiDetail(params);
      final dynamic list = res is Map ? res['data']['data']['list'] : null;
      if (list != null && list.length > 0) {
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
          _hasMore = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading data: $e');
      _modalSetState?.call(() {
        _isLoading = false;
      });
    }
  }

  // 下拉刷新方法
  Future<void> _onRefresh() async {
    _currentPage = 1;
    await getHotDetailApi();
  }

  Widget buildListItems() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 50.h,
            child: Center(
              child: Text('相关视频', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 16.sp)),
            ),
          ),
          Container(
            width: double.infinity,
            height: 33.h,
            margin: EdgeInsets.only(left: 12.w, right: 12.w),
            decoration: BoxDecoration(
              color: Color(0xFFF5F7F9),
              borderRadius: BorderRadius.circular(8)
            ),
            child: Row(
              children: [
                SizedBox(width: 12.w),
                Text('选题热点', style: TextStyle(color: Color(0xFF666666), fontSize: 12.sp)),
                SizedBox(width: 8.w),
                Text(hot['title'], style: TextStyle(color: Colors.black, fontSize: 12.sp, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('点赞数排序', style: TextStyle(color: Color(0xFF666666), fontSize: 12.sp)),
              Image.network('https://cdn-static.chanmama.com/sub-module/static-file/9/c/94f2bec2a2', width: 8.w, height: 8.h),
              SizedBox(width: 12.w),
            ],
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: _isLoading && _videoList.isEmpty
                ? Center(child: PageLoading(text: '加载中...'))
                : _videoList.isEmpty
                  ? Center(child: Text('暂无数据', style: TextStyle(color: Color(0xFF999999), fontSize: 14.sp)))
                  : NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification scrollInfo) {
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
                            return HotDetailCardPopup(videoList: _videoList);
                          } else {
                            return SizedBox(); // 这里不会被执行到，因为HotDetailCardPopup已经处理了所有视频
                          }
                        },
                      ),
                    ),
            ),
          ),
        ]
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
