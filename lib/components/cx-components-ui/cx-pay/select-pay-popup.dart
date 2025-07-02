import 'package:flutter/material.dart';
import 'package:flutter_module/pages/vip/components/agreement_protocol.dart';
import 'package:flutter_module/pages/vip/components/agreement_sheet.dart';
import 'package:flutter_module/utils/tool/resolve_cdn.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_module/services/vip.dart';
import 'package:flutter_module/pages/vip/vip_logic_mixin.dart';
import 'dart:async'; // 添加Timer支持
import 'package:fluttertoast/fluttertoast.dart'; // 添加fluttertoast导入

class SelectPayPopup extends StatefulWidget {
  static Map paySkus = {};
  static Map payGoods = {};
  static Map order = {};
  static String chanDouNum = '0';
  static Function? onOk;  // 添加静态onOk回调

  const SelectPayPopup({super.key});

  static Future<void> getOrderApi() async {
    final res = await getTradeOrders({
      'goods_id': payGoods['id'],
      'sku_id': paySkus['id'],
      'quantity': 1,
    });
    SelectPayPopup.order = res as Map;
  }

  // static Future<void> getOrderBean() async {
  //   final res = await getTradeOrdersBeans({
  //     'quantity': SelectPayPopup.chanDouNum,
  //   });
  //   SelectPayPopup.order = res as Map;
  // }

  static Future<void> show(
      BuildContext context, Map paySkus, Map payGoods, {
        required Function() onClose,
        required Function() onOk,
      }) async {
    SelectPayPopup.onOk = onOk;  // 保存onOk回调
    SelectPayPopup.paySkus = paySkus;
    SelectPayPopup.payGoods = payGoods;
    await getOrderApi(); // 创建订单
    await showModalBottomSheet(
      context: context,
      isDismissible: false, // 设置为false可防止点击阴影区域关闭
      backgroundColor: Color(0xFFF7F8FA),
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.55,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (BuildContext context) => SelectPayPopup(),
    );
  }

  @override
  State<SelectPayPopup> createState() => _BuyChandouSheetState();
}

class _BuyChandouSheetState extends State<SelectPayPopup> with VipLogicMixin {
  bool _isAgree = false;
  Map _payType = {};
  List<dynamic> _payList = [];
  int _remainingTimeMs = 0; // 添加剩余时间状态
  late Timer _timer; // 添加定时器

  @override
  void initState() {
    super.initState();
    _getPayApiList();
    _startCountdownTimer(); // 启动倒计时
  }

  @override
  void dispose() {
    _timer.cancel(); // 取消定时器，避免内存泄漏
    super.dispose();
  }

  // 启动倒计时计时器
  void _startCountdownTimer() {
    // 获取初始毫秒值
    _remainingTimeMs = int.tryParse(SelectPayPopup.order['pay_left_time']?.toString() ?? '0') ?? 0;

    // 创建定时器，每秒更新一次
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        // 每次减少1000毫秒（1秒）
        _remainingTimeMs = _remainingTimeMs - 1000;

        // 如果倒计时结束，取消定时器
        if (_remainingTimeMs <= 0) {
          _remainingTimeMs = 0;
          _timer.cancel();
        }
      });
    });
  }

  // 将毫秒转换为mm:ss格式
  String _formatTime(int milliseconds) {
    if (milliseconds <= 0) {
      Navigator.pop(context);
      return "00:00";
    }
    int seconds = (milliseconds / 1000).floor();
    int minutes = (seconds / 60).floor();
    seconds = seconds % 60;

    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  void _getPayApiList() async {
    final res = await getPaymentGateways();
    print(res);
    setState(() {
      _payList = res as List;
      if (_payList.isNotEmpty) {
        _payType = _payList[0];
      }
    });
  }

  // void _getOrderApi() async {
  //   await getTradeOrders({
  //     'goods_id': SelectPayPopup.payGoods['id'],
  //     'sku_id': SelectPayPopup.paySkus['id'],
  //     'quantity': 1,
  //   });
  // }

  void _onClose() {
    showAnimatedDialog(context);
    // Navigator.of(context).pop();
  }

  bool _isCheckFunc(item) {
    return _payType['gateway_id'] == item['gateway_id'];
  }

  void _onSelectPay(item) {
    setState(() {
      _payType = item;
    });
  }

  _onOpenVipTap() async {
    final res = await getTradeOrdersPay({
      'gateway_id': _payType['gateway_id'], // SelectPayPopup.order['payment_gateway_id'],
      'tool_id': _payType['tool_id'],
      'order_no': SelectPayPopup.order['order_no']
    });
    final obj = res as Map;
    final result = await pay(context, obj['order_string']);
    if (result['resultStatus'] == '9000') {
      Fluttertoast.showToast(
          msg: '支付成功',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          fontSize: 16.0
      );
      SelectPayPopup.onOk?.call();  // 调用onOk回调
    } else {
      Fluttertoast.showToast(
          msg: '请重新支付',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          fontSize: 16.0
      );
    }
    return;
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
        },
      );
    }
  }

  void showAnimatedDialog(BuildContext context) {
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
            width: 311.w,
            height: 250.h,
            padding: EdgeInsets.only(left: 24.w, right: 24.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 24.h),
                Text('确认放弃付款？', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: Color(0xFF111111), decoration: TextDecoration.none)),
                SizedBox(height: 8.h),
                Text('您的订单还未完成支付，请在订单取消前尽快完成支付', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400, color: Color(0xFF999999), decoration: TextDecoration.none)),
                SizedBox(height: 24),
                GestureDetector(
                  onTap: () => _onOpenVipTap(),
                  child: Container(
                    width: double.infinity,
                    height: 46.h,
                    decoration: BoxDecoration(
                      color: Color(0xFF22262C),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: GestureDetector(
                        onTap: () => _onOpenVipTap(),
                        child: Text('继续支付', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Color(0xFFA1F74A), decoration: TextDecoration.none)),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 46.h,
                    child: Center(
                      child: Text('确认退出', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Color(0xFF86909C), decoration: TextDecoration.none)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(16.r),
        topRight: Radius.circular(16.r),
      ),
      child: Container(
        padding: EdgeInsets.only(left: 12.w, right: 12.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 50.h,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 0,
                    right: 0,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.only(
                          left: 4.w,
                          right: 0,
                          top: 4.w,
                          bottom: 2.w,
                        ),
                        minimumSize: Size(0, 0),
                      ),
                      onPressed: () {
                        _onClose();
                      },
                      child: Image.network(
                        resolveCDN('@cdn?66bb0123493c'),
                        width: 24.w,
                        height: 24.h,
                      ),
                    ),
                  ),
                  Center(
                    child: Text('支付金额', style: TextStyle(
                      color: Colors.black,
                      fontSize: 12.sp,
                    ),
                    ),
                  )
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '¥',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  SelectPayPopup.paySkus['price'] ?? '0',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Center(
              child: Text('剩余支付时间 ${_formatTime(_remainingTimeMs)}', style: TextStyle(
                color: Color(0xFF999999),
                fontSize: 12.sp,
              )),
            ),
            SizedBox(height: 32.h),
            Text(
              '支付方式',
              style: TextStyle(
                color: Color(0xFF86909C),
                fontSize: 12.sp,
              ),
            ),
            SizedBox(height: 8.h),
            _buildPayList(),
            SizedBox(height: 12.h),
            SafeArea(
              top: false,
              bottom: true, // 仅设置底部安全距离
              child: Container(
                child: Column(
                  children: [
                    openVipButton(),
                    SizedBox(height: 12.h),
                  ],
                ),
              ),
            ),
          ],
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
        child: Text(
          '立即支付',
          style: TextStyle(
            color: Color(0xFF22262C),
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildPayList() {
    return Expanded(child: Container(
      padding: EdgeInsets.only(left: 12.w, right: 12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView(
        shrinkWrap: true,
        children: _payList.map((item) => _buildPayItem(item)).toList(),
      ),
    ));
  }

  Widget _buildPayItem(Map item) {
    return GestureDetector(
     onTap: () => _onSelectPay(item),
     child: Container(
       width: double.infinity,
       color: Colors.transparent,
       height: 64.h,
       child: Row(
         mainAxisAlignment: MainAxisAlignment.spaceBetween,
         children: [
           Row(
             children: [
               Image.network(
                 item['icon'],
                 width: 18.w,
                 height: 18.h,
               ),
               SizedBox(width: 8.w),
               Text(
                 item['name'],
                 style: TextStyle(
                   color: Colors.black,
                   fontSize: 12.sp,
                 ),
               ),
             ],
           ),
           Container(
             width: 18.w,
             height: 18.h,
             margin: EdgeInsets.only(left: 12.w, right: 4.w),
             decoration: BoxDecoration(
                 border: Border.all(width: 1,color: _isCheckFunc(item) ? Colors.transparent : Color(0xFF999999)),
                 color: _isCheckFunc(item) ? Color(0xFFa5df2a) : Colors.transparent,
                 borderRadius: BorderRadius.circular(40)
             ),
             child: Center(
               child: _isCheckFunc(item) ? Icon(Icons.check, color: Colors.white, size: 14) : Container(),
             ),
           ),
         ],
       ),
     ),
    );
  }
}
