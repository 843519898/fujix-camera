import 'package:flutter_store_kit/flutter_store_kit.dart';
import '../../services/vip.dart';
import 'package:fluttertoast/fluttertoast.dart';

Map IosPayOrder = {};
List<String> sku = ['com.chankuaijian.onemonthvip', 'com.chankuaijian.oneyearvip', 'com.chankuaijian.chanbean600', 'com.chankuaijian.chanbean1200'
, 'com.chankuaijian.chanbean2400', 'com.chankuaijian.chanbean4800'];

class ApplePay {
  static Future<void> init() async {
    await StoreKit.instance.initialize(sku);
    //
    // final products = await StoreKit.instance.subscriptionItems;
    // if (products.length == 0) {
    // }
  }

  static Future<void> pay(apple_product_id, goods_id, sku_id, onSuccess) async {
    try {
      print('apple_product_id在sku中的索引位置: ${sku.indexOf(apple_product_id)}');
      // StoreKit.instance.initialize([apple_product_id]);
      StoreKit.instance.addProStatusChangedListener((PurchasedItem item) => _onProStatusChanged(item, onSuccess));
      final res = await getTradeOrders({
        'goods_id': goods_id,
        'sku_id': sku_id,
        'quantity': 1,
      });
      IosPayOrder = res as Map;
      // 使用单独的方法处理购买请求
      await requestPurchase(sku.indexOf(apple_product_id));
    } catch (e) {
      print('购买过程发生错误: $e');
      Fluttertoast.showToast(
        msg: "购买过程出错：${e.toString()}",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
      );
    }
  }

  static Future<void> requestPurchase(index) async {
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
      final result = await StoreKit.instance.purchaseSubscription(products[index]);
    } catch (e) {
      print('购买请求错误: $e');
    }
  }

  static Future<void> _onProStatusChanged(PurchasedItem item, onSuccess) async {
    try {
      await setTradeReceipt({
        'receipt': item.transactionReceipt.toString(),
        'business_trade_no': IosPayOrder['order_no']
      });
      Fluttertoast.showToast(
        msg: "购买成功",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
      );
      onSuccess();
    } catch (e) {
      print(e);
    }
  }
}