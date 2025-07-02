import 'package:flutter/material.dart';
import 'package:flutter_module/pages/vip/components/agreement_protocol.dart';
import 'package:flutter_module/pages/vip/components/agreement_sheet.dart';
import 'package:flutter_module/pages/vip/components/benefits.dart';
import 'package:flutter_module/routes/route_name.dart';
import 'package:flutter_module/utils/tool/resolve_cdn.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_module/pages/vip/vip_plan.dart';
import 'package:flutter_module/pages/vip/components/vip_item.dart';
import 'package:flutter_module/pages/vip/vip_logic_mixin.dart';
import 'package:flutter_module/components/cx-components-ui/cx-pay/select-pay-popup.dart';
// import 'package:flutter_module/providers/user_provider.dart'; // 添加UserProvider导入
import 'package:provider/provider.dart';
import 'package:flutter_module/services/vip.dart';
import 'package:intl/intl.dart';
// import 'package:flutter_module/utils/native_bridge.dart';
import 'package:flutter/services.dart';
import '../../utils/tool/cx_tools.dart';
import '../../services/common_service.dart'; // 接口
import 'dart:io';
import 'package:flutter_module/utils/apple_pay.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart'; // 如果你想要使用SpinKit加载器

class BuyVipSheet extends StatefulWidget {
  final String? fromNative; // 添加fromNative参数

  const BuyVipSheet({super.key, this.fromNative = '0'});

  static Future<void> show(
    BuildContext context, {
    required Function() onClose,
    required Function() onOk,
  }) async {
    print('执行到弹窗逻辑');
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      constraints: BoxConstraints(maxHeight: 487.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (BuildContext context) => BuyVipSheet(),
    );
  }

  @override
  State<BuyVipSheet> createState() => _BuyVipSheetState();
}

class _BuyVipSheetState extends State<BuyVipSheet> with VipLogicMixin {
  int _activeIndex = 0;
  bool _isAgree = false;
  // UserProvider? _userProvider; // 改为可空类型
  Map _vipGoods = {};
  Map _userVip = {};
  final _debouncer = CxDebouncer(milliseconds: 500); // 2秒防抖
  Map _userInfo = {
    'avatar': '',
    'nickname': '',
  };
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        // _userProvider = Provider.of<UserProvider>(context, listen: false);
      });
    });
    ApplePay.init();
    _getResetPage();
  }

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }

  void _getResetPage() {
    _getVipGoods();
    _getVipInfo();
    _getUserInfo();
  }

  _getVipGoods() async {
    try {
      final res = await getTradeGoods({'type': 'VIP_GOODS'});
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

  _getVipInfo() async {
    final res = await getUserVip();
    setState(() {
      _userVip = res as Map;
    });
  }

  void _getUserInfo() async {
    final res = await getUserInfo();
    setState(() {
      res as Map;
      _userInfo = res['data'];
    });
  }

  _onOpenVipTap() async {
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
          _getResetPage();
        });
      } catch (e) {
        setState(() {
          isLoading = false;
        });
      }
      return;
    }
    SelectPayPopup.show(
      context,
      _vipGoods['skus'][_activeIndex],
      _vipGoods,
      onClose: () {},
      onOk: () {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          // SystemNavigator.pop();
        }
      },
    );
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
      return '有效期至 ${DateFormat('yyyy-MM-dd').format(DateTime.fromMillisecondsSinceEpoch(int.parse(_userVip['vip_version_info']['expire_at'].toString())))}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(16.r),
        topRight: Radius.circular(16.r),
      ),
      child: contextWidget(),
    );
  }

  Widget userInfo() {
    // if (_userProvider == null) {
    //   return Container(
    //     margin: EdgeInsets.only(left: 12.w, right: 12.w),
    //     width: double.infinity,
    //     height: 40.h,
    //     color: Colors.transparent,
    //   );
    // }

    // final userInfo = _userProvider!.userInfo ?? {};

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
                      decoration: TextDecoration.none,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  if (_userVip.containsKey('free') && !_userVip['free'])
                    Image.network(
                      resolveCDN('@cdn?af14d8d135ad'),
                      width: 14.w,
                      height: 14.h,
                    ),
                ],
              ),
              Text(
                _getUserVipDesc(),
                style: TextStyle(
                  color: Color(0xFF999999),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
          Expanded(child: SizedBox()),
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
                  ? (_vipGoods['skus'] as List)
                      .map(
                        (e) => VipItem(
                          vipPlan: e,
                          isActive:
                              _activeIndex == _vipGoods['skus'].indexOf(e),
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
      onTap: () {
        _debouncer.run(() {
          _onOpenVipTap();
        });
      },
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
              '立即开通',
              style: TextStyle(
                color: Color(0xFF22262C),
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.none,
              ),
            ),
            SizedBox(width: 4.w),
            Text(
              '¥${_getButtonPrice()}',
              style: TextStyle(
                color: Color(0xFF22262C),
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget contextWidget() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFF7F8FA),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Image.network(
              resolveCDN('@cdn?50439ba44dbf'),
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover, // 确保图片覆盖整个区域
              height: 148.h,
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
                SizedBox(height: 24.h),
                userInfo(),
                SizedBox(height: 12.h),
                vipBox(),
                SizedBox(height: 12.h),
                Container(
                  margin: EdgeInsets.only(left: 12.w, right: 12.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '会员权益',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111111),
                              decoration: TextDecoration.none,
                            ),
                          ),
                          Expanded(child: SizedBox()),
                          TextButton(
                            onPressed: () {
                              if (Platform.isIOS && widget.fromNative == '1') {
                                // NativeBridge.closeModalBottomSheet('buyVipSheet', context, false);
                                Future.delayed(Duration(seconds: 1), () {
                                  // NativeBridge.navigateToFlutter(RouteName.vip);
                                });
                              } else {
                                // Navigator.of(context).pushNamed(RouteName.vip);
                              }
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
                                  '查看权益对比',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    height: 1,
                                    color: Color(0xFF86909C),
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w400,
                                    decoration: TextDecoration.none,
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
                        ],
                      ),
                      Benefits(),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
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
                          onClose: () {
                          },
                          fromNative: widget.fromNative,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 18.h,
            right: 18.w,
            child: GestureDetector(
              onTap: () {
                print('关闭弹窗');
                if (Platform.isIOS && widget.fromNative == '1') {
                  // Navigator.of(context).pop();
                  // NativeBridge.closeModalBottomSheet('buyVipSheet', context, true);
                } else {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                    // NativeBridge.closeModalBottomSheet('buyVipSheet', context, true);
                  } else {
                    // NativeBridge.closeModalBottomSheet('buyVipSheet', context, true);
                    // SystemNavigator.pop();
                  }
                }
              },
              child: Image.network(
                resolveCDN('@cdn?66bb0123493c'),
                width: 24.w,
                height: 24.h,
              ),
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
