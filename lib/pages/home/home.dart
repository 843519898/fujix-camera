import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 需要重新添加这个导入
import 'dart:ui'; // 添加对dart:ui的导入以使用ImageFilter
import 'package:flutter_module/pages/home/components/home-card-hot.dart';
import 'package:flutter_module/pages/home/components/hot-video-popup.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart'; // 添加fluttertoast导入
import 'provider/counterStore.p.dart';
import './components/zone-action.dart';
import './components/tabs-search.dart';
import './components/home-card-goods.dart';
import '../../../services/common_service.dart'; // 接口
import '../../../services/vip.dart'; // 接口
import './components/home-card-video.dart';
import '../../../components/page_loding/page_loding.dart';
import 'package:flutter/rendering.dart';
import '../../../config/app_env.dart';
import '../../../utils/storage_util.dart'; // 添加StorageUtil导入
import 'package:flutter_module/components/cx-components-ui/cx-vip-more/cx-vip-more.dart';
import '../../utils/tool/cx_tools.dart';
import 'dart:io' show Platform;
import 'package:flutter_module/utils/track_event.dart';

// 创建一个用于悬浮标签的SliverPersistentHeaderDelegate
class StickyTabsDelegate extends SliverPersistentHeaderDelegate {
  final TabsSearch tabsSearch;
  final double height;

  StickyTabsDelegate({required this.tabsSearch, required this.height});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: tabsSearch,
    );
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

class Home extends StatefulWidget {
  const Home({Key? key, this.params}) : super(key: key);
  final dynamic params;

  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  @override
  bool get wantKeepAlive => true;
  // late UserProvider _userProvider; // 添加UserProvider
  FocusNode blankNode = FocusNode(); // 响应空白处的焦点的Node
  Map _userVip = {};

  // 添加分页相关状态
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoading = false;
  List<dynamic> _goodsList = [];
  List<dynamic> _videoList = [];
  List<dynamic> _hotList = [];
  ScrollController _scrollController = ScrollController();
  Map<String, dynamic> _searchParams = {};
  final ValueNotifier<int> currentTabs = ValueNotifier<int>(0);
  final GlobalKey<HotVideoPopupState> _childKey = GlobalKey();
  // 添加文本控制器
  TextEditingController _searchController = TextEditingController();
  bool isShowLogin = false;
  bool isShowNoVip = false;
  final _debouncer = CxDebouncer(milliseconds: 1000); // 2秒防抖

  @override
  void initState() {
    super.initState();
    if (Platform.isIOS) {
      // 注册生命周期观察者
      WidgetsBinding.instance.addObserver(this);
    }

    _scrollController.addListener(_scrollListener);

    _onGetclipboardData();
    isGoPage();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 初始化 UserProvider 并添加监听
    // _userProvider = Provider.of<UserProvider>(context, listen: false);
    // _userProvider.addListener(_onUserChanged);
    getResetVip();
  }

  void _onUserChanged() async {
    _debouncer.run(() {
      print('收到登录的变化开始打印------------');
      // if (_userProvider.isLoggedIn) {
      //   isShowLogin = false;
      // }
      _refresh(); // 用户信息变化时触发刷新
    });
  }

  void getResetVip() {
    // if (_userProvider.isLoggedIn) {
    //   _getVipInfo();
    // }
  }

  @override
  void dispose() {
    // 移除生命周期观察者
    WidgetsBinding.instance.removeObserver(this);
    _debouncer.dispose();
    _scrollController.dispose();
    _searchController.dispose(); // 释放控制器资源
    // _userProvider.removeListener(_onUserChanged); // 移除监听器
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // 从后台切回前台时触发
      final currentRoute = getCurrentTopRoute(context);
      print(currentRoute);
      isGoPage();
      if (currentRoute == '/h5_route_page') {
        return;
      }
      _onGetclipboardData(); // 重新检查剪贴板
    } else if (state == AppLifecycleState.paused) {
      // 应用进入后台时触发
    }
  }

  String? getCurrentTopRoute(BuildContext context) {
    NavigatorState? navigator = Navigator.of(context);
    Route? currentRoute = navigator.widget.onGenerateRoute!(RouteSettings(name: '/'));

    // 或者遍历路由栈（适用于 Flutter 2.0+）
    Route? topRoute;
    navigator.popUntil((route) {
      topRoute = route;
      return true; // 返回 true 停止遍历
    });

    return topRoute?.settings.name;
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent) {
      if (!_isLoading && _hasMore) {
        _loadMore();
      }
    }
  }

  void isGoPage() async {
    // if (Platform.isIOS) {
    //   final res = await NativeBridge.isNavigateToFlutter();
    //   if (res.isNotEmpty && res != '') {
    //     if (!_userProvider.isLoggedIn) {
    //       NativeBridge.openUserLogin();
    //       return;
    //     }
    //     Navigator.of(context).pushNamed('/h5_route_page', arguments: {
    //       'url': res,
    //     });
    //   }
    // }
  }

  Future<void> _onGetApiList() async {
    if (currentTabs.value == 0) {
      await _getDyRank();
    } else if (currentTabs.value == 1) {
      await getVideoApi();
    } else if (currentTabs.value == 2) {
      await getHotApi();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;
    await _onGetApiList();
  }

  Future<void> _refresh() async {
    // if (_userProvider.isLoggedIn) {
    //   _getVipInfo();
    // }
    setState(() {
      isShowLogin = false;
      isShowNoVip = false;
      _isLoading = false;
      _currentPage = 1;
      _hasMore = true;
      _goodsList = [];
      _videoList = [];
      _hotList = [];
    });
    await _onGetApiList();
  }

  Future<void> _getDyRank() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final res = await productRank({
        'need_recommend_reason': 1,
        'rank_type': 9,
        'need_material': 1,
        'page': _currentPage,
        'size': 10,
        ..._searchParams,
      });
      final Map resMap = res is Map ? res : {};
      final dynamic list = res is Map ? res['list'] : null;
      print('listlistlistlistlistlistlistlist');
      print(list);
      // if (!_userProvider.isLoggedIn && _currentPage == 2) {
      //   setState(() {
      //     isShowLogin = true;
      //     _isLoading = false;
      //     _hasMore = false;
      //   });
      //   return;
      // } else if (_userVip.containsKey('free') && _userVip['free'] && _currentPage != 1) {
      //   // 没有会员
      //   setState(() {
      //     isShowNoVip = true;
      //     _isLoading = false;
      //     _hasMore = false;
      //   });
      //   return;
      // }
      if (list != null) {
        setState(() {
          if (_currentPage == 1) {
            _goodsList = list;
          } else {
            _goodsList.addAll(list);
          }
          _hasMore = list.length >= 10;
          _currentPage++;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> getVideoApi() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final res = await getMaterialList({
        'search_str': '',
        'sort': 'product_volume',
        'order_by': 'desc',
        'time': '7d',
        'page': _currentPage,
        'size': 10,
        ..._searchParams,
      });
      final dynamic list = res is Map ? res['data']['list'] : null;
      print(list);
      // if (!_userProvider.isLoggedIn && _currentPage == 2) {
      //   setState(() {
      //     isShowNoVip = true;
      //     _isLoading = false;
      //     _hasMore = false;
      //   });
      //   return;
      // }
      // if (_userVip.containsKey('free') && _userVip['free'] && _currentPage != 1) {
      // // 没有会员
      //   setState(() {
      //     isShowNoVip = true;
      //     _isLoading = false;
      //     _hasMore = false;
      //   });
      //   return;
      // }
      if (list != null) {
        setState(() {
          if (_currentPage == 1) {
            _videoList = list;
          } else {
            _videoList.addAll(list);
          }
          _hasMore = list.length >= 10;
          _currentPage++;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> getHotApi() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final res = await getHotApiList({
        'category_id': '-1',
        'date_type': '1',
        'rank_type': '1',
        'type': '3',
        'page': _currentPage.toString(),
        'size': '10',
        ..._searchParams,
      });
      final dynamic list = res is Map ? res['data'] : null;
      // if (!_userProvider.isLoggedIn && _currentPage == 2) {
      //   setState(() {
      //     isShowNoVip = true;
      //     _isLoading = false;
      //     _hasMore = false;
      //   });
      //   return;
      // }
      if (_userVip.containsKey('free') && _userVip['free'] && _currentPage != 1) {
        // 没有会员
        setState(() {
          isShowNoVip = true;
          _isLoading = false;
          _hasMore = false;
        });
        return;
      }
      if (list != null) {
        setState(() {
          if (_currentPage == 1) {
            _hotList = list;
          } else {
            _hotList.addAll(list);
          }
          _hasMore = list.length >= 10;
          _currentPage++;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void getAppVersionNum() async {
    final res = await getAppVersion();
    print('resresresresres${res}');
  }

  void _handleGoodsTypeChange(Map<String, dynamic> params) {
    _searchParams = params;
    _refresh();
  }

  void _handleTabChange(int index) async{
    setState(() {
      currentTabs.value = index;
    });
    await _refresh();
    _scrollController.animateTo(
      550.h, // 滚动到距离顶部 500px 的位置
      duration: Duration(seconds: 1), // 动画时长
      curve: Curves.easeInOut,       // 动画曲线
    );
  }

  void _getVipInfo() async {
    final res = await getUserVip();
    setState(() {
      _userVip = res as Map;
      if (_userVip.containsKey('free') && !_userVip['free']) {
        setState(() {
          isShowNoVip = false;
        });
        return;
      }
    });
  }

  void _onOpenHotVideoPopup(goods) {
    // if (!_userProvider.isLoggedIn) {
    //   NativeBridge.openUserLogin();
    //   return;
    // }
    _childKey.currentState?.showBottomSheet({
      'search_str': goods['product_id_str'],
    });
  }

  void _onGetRandomUrl() async {
    TrackEvent.report('Home', 'Click', 'RandomSelect', '', '{}');
    // if (!_userProvider.isLoggedIn) {
    //   NativeBridge.openUserLogin();
    //   return;
    // }
    final dynamic res = await getUrlRandom();
    _onClipVideo(res['data']);
  }

  void _onSetClipboard() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData != null && clipboardData.text != null) {
      await Clipboard.setData(ClipboardData(text: ''));
      // setState(() {
      //   _searchController.text = clipboardData.text!;
      // });
    }
  }

  void nowButton() async {
    getAppVersionNum();
    TrackEvent.report('Home', 'Click', 'NowSelect', '', '{}');
    _handleTabChange(0);
  }

  void _onClipVideo(text) async {
    final res = await getParseUrlToId({
      'url': text,
    });
    final dynamic data = res is Map ? res : null;
    if (data['code'] != 0) {
      Fluttertoast.showToast(
        msg: data['errMsg'],
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black87,
        textColor: Colors.white,
        fontSize: 16.0
      );
      return;
    }
    print('data: $data');
    if (data['data']['product_id'] != '') {
      _childKey.currentState?.showBottomSheet({
        'search_str': data['data']['product_id'],
      });
    } else {
      // showAnimatedDialog(context, text ?? '', data);
      // NativeBridge.navigateToNativePage(
      //   '${AppEnv.h5BaseUrl}/h5/kj/loading?is_navi=0&aweme_id=${data['data']['aweme_id']}&aweme_type=${data['data']['aweme_type']}&clipScene=VideoCut',
      // );
    }
  }

  void _onGetclipboardData() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData != null && clipboardData.text != null) {
      final res = await getParseUrlToId({
        'url': clipboardData.text,
      });
      final dynamic data = res is Map ? res : null;
      if (data['code'] != 0) {
        return;
      }
      if (data['data']['product_id'] != '' || data['data']['aweme_id'] != '') {
        showAnimatedDialog(context, clipboardData.text ?? '', data['data']);
      }
      await Clipboard.setData(const ClipboardData(text: ''));
    } else {
      showActivityDialog(context);
    }
  }

  void showAnimatedDialog(BuildContext context, String url, Map<String, dynamic> data) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => Center(
        child: ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          ),
          child: Center(
            child: Container(
              width: 311.w,
              // height: 250.h,
              padding: EdgeInsets.only(left: 24.w, right: 24.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 24.h),
                  Text('一键快剪同款视频', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: Color(0xFF111111), decoration: TextDecoration.none)),
                  SizedBox(height: 8.h),
                  Text('检测到您的剪贴板中的抖音链接${url}是否生成同款爆单视频', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400, color: Color(0xFF999999), decoration: TextDecoration.none)),
                  SizedBox(height: 24),
                  GestureDetector(
                    onTap: () {
                      // if (_userProvider.isLoggedIn) {
                      //   if (data.containsKey('product_id') && data['product_id'] != '') {
                      //     _childKey.currentState?.showBottomSheet({
                      //       'search_str': data['product_id'],
                      //     });
                      //   } else {
                      //     // NativeBridge.navigateToNativePage(
                      //     //   '${AppEnv.h5BaseUrl}/h5/kj/loading?is_navi=0&aweme_id=${data['aweme_id']}&aweme_type=${data['aweme_type']}&clipScene=VideoCut',
                      //     // );
                      //   }
                      // } else {
                      //   // NativeBridge.openUserLogin();
                      // }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 46.h,
                      decoration: BoxDecoration(
                        color: Color(0xFF22262C),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text('一键快剪', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Color(0xFFA1F74A), decoration: TextDecoration.none))
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: double.infinity,
                      height: 46.h,
                      child: Center(
                        child: Text('取消', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.black, decoration: TextDecoration.none)),
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                ],
              ),
            ),
          )
        ),
      ),
    );
  }

  void showActivityDialog(BuildContext context) async {
    // 检查是否已经显示过
    bool hasShown = await StorageUtil.hasActivityDialogShown();
    if (hasShown) {
      return; // 如果已经显示过，直接返回
    }
    // 标记为已显示
    await StorageUtil.markActivityDialogAsShown();

    // 显示弹窗
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => Center(
        child: ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          ),
          child: Container(
            width: 313,
            height: 312,
            decoration: BoxDecoration(
              color: Colors.transparent,
            ),
            child: GestureDetector(
              onTap: () async {
                try {
                  // if (_userProvider.isLoggedIn) {
                  //   // await getTradeVipInit();
                  //   Navigator.pop(context);
                  // } else {
                  //   // NativeBridge.openUserLogin();
                  // }
                } catch(e) {
                  print(e);
                }
              },
              child: Image.asset('asset/images/home/activity.png', width: double.infinity, fit: BoxFit.fitWidth),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      // 这个属性对于让内容延伸到状态栏区域很重要
      extendBodyBehindAppBar: true,
      // 使用透明AppBar，高度为0
      // appBar: PreferredSize(
      //   preferredSize: Size.zero,
      //   child: AppBar(
      //     backgroundColor: Colors.transparent,
      //   ),
      // ),
      body: GestureDetector(
        onTap: () {
          // 点击空白页面关闭键盘
          FocusScope.of(context).requestFocus(blankNode);
        },
        child: Stack(
          children: [
            contextWidget(),
            // 将HotVideoPopup作为overlay添加到Stack中
            HotVideoPopup(key: _childKey, context: context),
          ],
        ),
      ),
    );
  }

  Widget contextWidget() {
    // 创建TabsSearch组件
    final tabsSearch = TabsSearch(
      onGoodsTypeChange: _handleGoodsTypeChange,
      currentTabs: currentTabs,
    );

    return Stack(
      children: [
        // 背景图片置于底层
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: Image.asset(
            'asset/images/home/背景.png',
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover, // 确保图片覆盖整个区域
            height: 120,
          ),
        ),
        RefreshIndicator(
          onRefresh: _refresh,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  // padding: EdgeInsets.only(top: 44), // 只添加状态栏高度的padding
                  padding: EdgeInsets.only(top: MediaQuery.of(context).viewPadding.top + 12), // 只添加状态栏高度的padding
                  width: double.infinity,
                  child: Stack(
                    // 将Column改为Stack以实现元素叠加
                    children: [
                      // 背景图片作为底层
                      Image.asset(
                        'asset/images/home/主卡-单行.png',
                        fit: BoxFit.fitWidth,
                        width: double.infinity,
                      ),
                      // 输入框和按钮叠加在背景图上
                      Column(
                        children: [
                          SizedBox(height: 66.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                width: 112.w,
                                height: 34.h,
                                padding: EdgeInsets.all(0),
                                child: ElevatedButton(
                                  onPressed: () => nowButton(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF000000),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.all(0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Center(
                                        child: Row(
                                          children: [
                                            Image.asset(
                                              'asset/images/home/sd.png',
                                              fit: BoxFit.fitWidth,
                                              width: 20,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              '立即选择',
                                              style: TextStyle(
                                                fontSize: 16.sp,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 28.w),
                            ],
                          ),
                        ],
                      ),
                      Positioned(
                        bottom: 12.h,
                        left: 28.w,
                        child: Container(
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: _onGetRandomUrl,
                                child: Row(
                                  children: [
                                    Image.asset(
                                      'asset/images/home/Shuffle.png',
                                      fit: BoxFit.fitWidth,
                                      width: 16,
                                    ),
                                    SizedBox(width: 4),
                                    Text('随机爆款尝试', style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 12.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.only(left: 12, right: 12, top: 8),
                  child: ZoneAction(handleTabChange: _handleTabChange, onReset: getResetVip),
                ),
              ),
              SliverPersistentHeader(
                delegate: StickyTabsSearchDelegate(
                  child: tabsSearch,
                ),
                pinned: true, // 设置为true使其固定在顶部
              ),
              SliverToBoxAdapter(
                child: ValueListenableBuilder<int>(
                  valueListenable: currentTabs,
                  builder: (context, currentTab, child) {
                    return Column(
                      children: [
                        if (currentTab == 0)
                          HomeCardGoods(goodsList: _goodsList, onOpenHotVideo: _onOpenHotVideoPopup, searchParams: _searchParams),
                        if (currentTab == 1)
                          HomeCardVideo(videoList: _videoList),
                        if (currentTab == 2)
                          HomeCardHot(hotList: _hotList, searchParams: _searchParams),
                        if (_isLoading)
                          PageLoading(text: '加载中...'),
                        if (!_hasMore)
                          Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text('没有更多数据了', style: TextStyle(fontWeight: FontWeight.w400, color: Color(0xFF666666))),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        if (isShowNoVip)
          CxVipMore(),
        if (isShowLogin)
        Positioned(
            bottom: 30.h,
            left: 24.w,
            right: 24.w,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                    child: Container(
                      width: double.infinity,
                      height: 48.h,
                      padding: EdgeInsets.only(left: 16.w, right: 16.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Color(0xFFECFADA), width: 1),
                        gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [
                            Color.fromRGBO(241, 255, 223, 0.5),
                            Color.fromRGBO(229, 250, 208, 0.5),
                          ],
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          // NativeBridge.openUserLogin();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Image.network('https://cdn-static.chanmama.com/sub-module/static-file/4/3/f31ba37f19', width: 24.w, height: 24.h),
                                SizedBox(width: 6.w),
                                Text('请先登录快剪，解锁更多能力', style: TextStyle(color: Colors.black, fontSize: 11.sp, fontWeight: FontWeight.w600)),
                              ],
                            ),
                            Container(
                              height: 24.h,
                              padding: EdgeInsets.only(left: 12.w, right: 12.w),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40),
                                color: Color(0xFFA1F74A),
                              ),
                              child: Center(
                                child: Text('点击登录', style: TextStyle(color: Colors.black, fontSize: 12.sp, fontWeight: FontWeight.w600)),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // 将图片放在ClipRRect外部，作为Stack的直接子组件
                Positioned(
                  top: -4.h,
                  right: -4.w,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isShowLogin = false;
                      });
                    },
                    child: Image.network('https://cdn-static.chanmama.com/sub-module/static-file/3/f/23e036aa29', width: 16.w, height: 16.h),
                  ),
                )
              ],
            )
        ),
      ],
    );
  }
}
