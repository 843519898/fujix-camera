import 'package:flutter/material.dart';
import 'package:flutter_module/utils/tool/resolve_cdn.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_module/pages/vip/components/benefits.dart';
import 'package:flutter_module/pages/vip/components/benefits_contrast.dart';
import 'package:flutter_module/pages/vip/components/agreement_protocol.dart';
import 'package:flutter_module/pages/vip/components/agreement_sheet.dart';
import 'package:flutter_module/pages/vip/vip_plan.dart';
import 'package:flutter_module/routes/route_name.dart';
import 'package:flutter_module/pages/vip/components/vip_item.dart';
import 'package:flutter_module/pages/vip/vip_logic_mixin.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter_module/components/cx-components-ui/cx-pay/select-pay-popup.dart';
import 'package:provider/provider.dart';
import '../../services/vip.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';
import '../../utils/tool/cx_tools.dart';
import '../../services/common_service.dart';
// import 'package:flutter_module/utils/native_bridge.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter_store_kit/flutter_store_kit.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_module/utils/apple_pay.dart';
import 'package:flutter_module/routes/routes_change.dart';

class VipPage extends StatefulWidget {
  final VoidCallback? onClose;  // 添加回调函数
  final String? fromNative; // 添加fromNative参数
  const VipPage({
    super.key,
    this.onClose,
    this.fromNative = '0',
  });

  @override
  State<VipPage> createState() => VipPageState();
}

class VipPageState extends State<VipPage> with VipLogicMixin, RouteChangeMixin {
  int _activeIndex = 0;
  bool _isAgree = false;
  // UserProvider? _userProvider; // 改为可空类型
  bool _isInitialized = false; // 添加初始化标志
  final _debouncer = CxDebouncer(milliseconds: 500); // 2秒防抖
  Map chandouInfo = {
    'total': 0
  };
  Map _userVip = {};
  Map _vipGoods = {};
  Map _userInfo = {
    'avatar': '',
    'nickname': '',
  };
  final InAppPurchase _iap = InAppPurchase.instance;
  // late StreamSubscription<List<PurchaseDetails>> _subscription;
  bool isLoading = false;
  // Map IosPayOrder = {};

  @override
  void initState() {
    super.initState();
    // 在下一帧渲染完成后初始化UserProvider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        // _userProvider = Provider.of<UserProvider>(context, listen: false);
        _isInitialized = true;
      });
    });
    ApplePay.init();
    _getResetPage();
    // _subscription = _iap.purchaseStream.listen(_handlePurchaseUpdate);
    // _getResetPage();
    // _initSquarePayment();
    // StoreKit.instance.addErrorListener(_onError);
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  // }

  @override
  void dispose() {
    // _subscription?.cancel();
    _debouncer.dispose();
    super.dispose();
  }

  @override
  void onRoutePopNext() {
    // 当从其他页面返回到当前页面时刷新数据
    _getChanDou();
  }

  void _getResetPage() {
    _getUserInfo();
    _getVipGoods();
    _getChanDou();
    _getVipInfo();
  }
  void _onProStatusChanged(PurchasedItem item) async {
    await setTradeReceipt({
      'receipt': item.transactionReceipt.toString(),
      'business_trade_no': IosPayOrder['order_no']
    });

  }

  void _onError(PurchaseResult? error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error?.message ?? "error"),
      ),
    );
  }

  void _getChanDou() async{
    final res = await getUserChanDou();
    setState(() {
      chandouInfo = res as Map;
    });
  }

  _getVipInfo() async {
    print('getUserVip接口被调用了');
    final res = await getUserVip();
    setState(() {
      _userVip = res as Map;
    });
  }

  _getVipGoods() async {
    try {
      final res = await getTradeGoods({
        'type': 'VIP_GOODS'
      });
      setState(() {
        final list = res as List;
        if (list.isNotEmpty) {
          _vipGoods = list[0];
        }
      });
    } catch (e) {
      print('获取VIP商品信息失败: $e');
    }
  }

  void _getUserInfo() async {
    final res = await getUserInfo();
    setState(() {
      res as Map;
      _userInfo = res['data'];
    });
  }

  String _getButtonPrice() {
    if (!_vipGoods.containsKey('skus') || _vipGoods['skus'].isEmpty) {
      return '';
    }
    return _vipGoods['skus'][_activeIndex]?['price'].toString() ?? '';
  }

  String _getUserVipDesc() {
    if (!_userVip.containsKey('vip_version_info')) {
      return '';
    }
    if (_userVip['free']) {
      return '暂未开通会员';
    } else {
      return '有效期至 ${DateFormat('yyyy-MM-dd').format(
        DateTime.fromMillisecondsSinceEpoch(
          int.parse(_userVip['vip_version_info']['expire_at'].toString()),
        ),
      )}';
    }
  }

  void _handleVipTap() async {
    if (!_isAgree) {
      AgreementSheet.show(
        context,
        onClose: () {
          Navigator.of(context).pop();
        },
        onOk: () {
          setState(() {
            _isAgree = true;
          });
          Navigator.of(context).pop();
          _onPay();
        },
      );
    } else {
      _onPay();
    }
  }

  _onOpenVipTap() {
    _debouncer.run(() {
      _handleVipTap();
    });
  }

  void _handlePurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (var purchase in purchases) {
      try {
        Fluttertoast.showToast(
          msg: purchase.purchaseID.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
        );

        // await _iap.restorePurchases();
        //
        // // 使用 StoreKit 2 获取交易信息
        // List<SK2Transaction> transactions = await SK2Transaction.transactions();
        // if (transactions.isNotEmpty) {
        //   final transaction = transactions[0];
        //   final receiptData = transaction.jsonRepresentation;
        //   // final receiptData = transaction.jwsRepresentation;
        //
        //   Fluttertoast.showToast(
        //     msg: '8秒后的请求$receiptData',
        //     toastLength: Toast.LENGTH_LONG,
        //     gravity: ToastGravity.CENTER,
        //   );
        //   await setTradeReceipt({
        //     'receipt': receiptData,
        //     'business_trade_no': '1'
        //   });
        // }
        
      } catch (e) {
        Fluttertoast.showToast(
          msg: '收据刷新失败',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
        );
        print('收据刷新失败: $e');
      }
      
      switch (purchase.status) {
        case PurchaseStatus.purchased:
          if (purchase.pendingCompletePurchase) {
            try {
              await _iap.completePurchase(purchase);
              print('Successfully completed purchase');
            } catch (e) {
              print('Error completing purchase: $e');
            }
          }
          break;
        case PurchaseStatus.error:
          Fluttertoast.showToast(
            msg: purchase.error.toString(),
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
          );
          // _handleError(purchase.error!);
          break;
        case PurchaseStatus.canceled:
        // 处理用户取消
          break;
        default:
          break;
      }
    }
  }

  Future<void> _requestPurchase() async {
    try {
      // 获取商品信息
      final products = await StoreKit.instance.subscriptionItems;
      if (products.isEmpty) {
        Fluttertoast.showToast(
          msg: "未找到商品信息，请检查商品ID配置",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
        );
        return;
      }

      // 发起订阅购买
      final result = await StoreKit.instance.purchaseSubscription(products[0]);
      setState(() {
        isLoading = false;
      });
      return;
      return;
      List<ProductDetails> _products = [];
      const Set<String> _productIds = {'com.chankuaijian.onemonthvip'}; // 替换为你的产品ID
      ProductDetailsResponse response = await _iap.queryProductDetails(_productIds);
      _products = response.productDetails;
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: _products[0],
        applicationUserName: null, // 可选用户标识
      );
      _iap.buyConsumable(purchaseParam: purchaseParam);

    } catch (e) {
      print('购买请求错误: $e');
      Fluttertoast.showToast(
        msg: "购买请求失败：$e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
      );
    }
  }

  void _onPay() async {
    if (Platform.isIOS) {
      try {
        setState(() {
          isLoading = true;
        });
        Future.delayed(Duration(seconds: 3), () {
          setState(() {
            isLoading = false;
          });
        });
        await ApplePay.pay(_vipGoods['skus'][_activeIndex]['extend_product_id'], _vipGoods['id'], _vipGoods['skus'][_activeIndex]['id'], () {
          print('刷新');
          _getResetPage();
        });
        // StoreKit.instance.initialize([]);
        // StoreKit.instance.addProStatusChangedListener(_onProStatusChanged);
        // final res = await getTradeOrders({
        //   'goods_id': _vipGoods['id'],
        //   'sku_id': _vipGoods['skus'][_activeIndex]['id'],
        //   'quantity': 1,
        // });
        // setState(() {
        //   IosPayOrder = res as Map;
        // });
        // 使用单独的方法处理购买请求
        // await _requestPurchase();
      } catch (e) {
        print('购买过程发生错误: $e');
        Fluttertoast.showToast(
          msg: "购买过程出错：${e.toString()}",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
        );
        setState(() {
          isLoading = false;
        });
      }
      return;
    }

    SelectPayPopup.show(context, _vipGoods['skus'][_activeIndex], _vipGoods, onClose: () {}, onOk: () {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      _getResetPage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 这个属性对于让内容延伸到状态栏区域很重要
      extendBodyBehindAppBar: true,
      // 使用透明AppBar，高度为0
      appBar: PreferredSize(
        preferredSize: Size.zero,
        child: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      ),
      body: contextWidget(),
    );
  }

  _onBack() {
    if (Platform.isIOS && widget.fromNative == '1') {
      // NativeBridge.closeModalBottomSheet('buyVipSheet', context, true);
    } else {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        SystemNavigator.pop();
      }
    }
  }

  Widget topBar() {
    return Container(
      margin: EdgeInsets.only(left: 0, right: 12.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded),
            iconSize: 24.w,
            onPressed: _onBack,
          ),
          TextButton(
            onPressed: () {
              // Navigator.of(context).pushNamed(RouteName.orderRecord);
            },
            style: TextButton.styleFrom(padding: EdgeInsets.all(0)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '订单记录',
                  style: TextStyle(
                    color: Color(0xFF111111),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 4.w),
                Image.network(
                  resolveCDN('@cdn?f3e5798a1f85'),
                  width: 24.w,
                  height: 24.w,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget chandou() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 2.w,
      children: [
        Image.network(
          resolveCDN('@cdn?21ab12320dfa'),
          width: 14.w,
          height: 14.h,
        ),
        Text(
          chandouInfo['total'].toString() ?? '0',
          textAlign: TextAlign.center,
          style: TextStyle(
            height: 1.2,
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
          ),
        ),
        if (_userVip.containsKey('free') && !_userVip['free'])
        TextButton(
          onPressed: () {
            // Navigator.of(context).pushNamed(RouteName.chandouCenter);
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.only(
              left: 4.w,
              right: 2.w,
              top: 4.w,
              bottom: 2.w,
            ),
            minimumSize: Size(0, 0),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '充值',
                textAlign: TextAlign.center,
                style: TextStyle(
                  height: 1,
                  color: Color(0xFF86909C),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Image.network(
                resolveCDN('@cdn?65c49604822e'),
                width: 14.w,
                height: 14.w,
              ),
            ],
          ),
        ),
        SizedBox(width: 2.w),
      ],
    );
  }

  Widget userInfo() {
    // 使用初始化标志检查
    // if (!_isInitialized || _userProvider == null) {
    //   return Container(
    //     margin: EdgeInsets.only(left: 12.w, right: 12.w),
    //     width: double.infinity,
    //     height: 40.h,
    //     color: Colors.transparent,
    //   );
    // }

    // final userInfo = _userProvider!.userInfo;

    return Container(
      margin: EdgeInsets.only(left: 12.w, right: 12.w),
      width: double.infinity,
      color: Colors.transparent,
      child: Row(
        children: [
          if (_userInfo['avatar'] != '')
          Hero(
            tag: 'avatar',
            child: ClipRRect(
              //剪裁为圆角矩形
              borderRadius: BorderRadius.circular(40),
              child: Image.network(
                _userInfo['avatar'] ?? '',
                width: 40.w,
                height: 40.h,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4.h,
            children: [
              Row(
                children: [
                  Text(
                    _userInfo['nickname'] ?? '',
                    style: TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  if (_userVip.containsKey('free') && !_userVip['free'])
                    Image.network(resolveCDN('@cdn?af14d8d135ad'), width: 14.w, height: 14.h),
                ],
              ),
              Text(
                _getUserVipDesc() ?? '',
                style: TextStyle(
                  color: Color(0xFF999999),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          Expanded(child: SizedBox()),
          chandou(),
        ],
      ),
    );
  }

  Widget vipBox() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        margin: EdgeInsets.only(left: 12.w, right: 12.w),
        child: Row(
          spacing: 12.w,
          children:
          _vipGoods.containsKey('skus') && _vipGoods['skus'] != null
              ? (_vipGoods['skus'] as List).map((e) => VipItem(
                      vipPlan: e,
                      isActive: _activeIndex == _vipGoods['skus'].indexOf(e),
                      onTap: () {
                        setState(() {
                          _activeIndex = _vipGoods['skus'].indexOf(e);
                        });
                      },
              activeIndex: _vipGoods['skus'].indexOf(e)
                    ),
                  )
                  .toList()
              : [],
        ),
      ),
    );
  }

  Widget openVipButton() {
    return GestureDetector(
      onTap: _onOpenVipTap,
      child: Container(
        alignment: Alignment.center,
        width: double.infinity,
        height: 48.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 194, 246, 14),
              Color.fromARGB(255, 122, 255, 223),
            ],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _userVip['vip_version_info'] != null ? '立即续费' : '立即开通',
              style: TextStyle(
                color: Color(0xFF22262C),
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 4.w,),
            Text(
              '¥${_getButtonPrice()}',
              style: TextStyle(
                color: Color(0xFF22262C),
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        )
      ),
    );
  }

  Widget contextWidget() {
    return Container(
      color: Color(0xFFFFFFFF),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Image.network(
              resolveCDN('@cdn?f378fba4eb6d'),
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover, // 确保图片覆盖整个区域
              height: 171.h,
            ),
          ),
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(
              top: MediaQuery.of(context).viewPadding.top,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                topBar(),
                SizedBox(height: 12.h),
                userInfo(),
                SizedBox(height: 24.h),
                vipBox(),
                SizedBox(height: 24.h),
                Container(
                  margin: EdgeInsets.only(left: 12.w, right: 12.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '会员权益',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111111),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Benefits(),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
                Container(
                  margin: EdgeInsets.only(left: 12.w, bottom: 12.w),
                  child: Text(
                    '权益对比',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF111111),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(left: 12.w, right: 12.w),
                      child: BenefitsContrast(),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                SafeArea(
                  top: false,
                  bottom: true, // 仅设置底部安全距离
                  child: Container(
                    padding: EdgeInsets.only(left: 12.w, right: 12.w),
                    child: Column(
                      children: [
                        openVipButton(),
                        AgreementProtocol(
                          defaultChecked: _isAgree,
                          onCheckChange: (value) {
                            setState(() {
                              _isAgree = value;
                            });
                          },
                          onClose: () {},
                          fromNative: widget.fromNative,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isLoading)
          ModalBarrier(dismissible: false, color: Colors.black.withOpacity(0.5)), // 创建全屏遮罩
          if (isLoading)
          Center( // 将加载指示器置于中心
            child: SpinKitFadingCircle( // 使用SpinKit加载器，或者任何其他你喜欢的加载指示器
              color: Colors.white,
              size: 50.0,
            ),
          ),
        ],
      ),
    );
  }
}
