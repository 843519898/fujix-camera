import '../utils/dio/request.dart' show Request;
import 'package:dio/dio.dart' show Options;

// 查询当前用户的会员信息
Future<Object> getUserVip() async {
  return Request.get(
    '/trade/vips/current',
  );
}

// 查询当前用户的蝉豆余额
Future<Object> getUserChanDou() async {
  return Request.get(
    '/trade/wallets/current',
  );
}

// 查询商品列表
Future<Object> getTradeGoods(params) async {
  return Request.get(
    '/trade/goods',
    queryParameters: params,
  );
}

// 支付方式列表
Future<Object> getPaymentGateways() async {
  return Request.get(
    '/trade/orders/payment-gateways',
  );
}

// 下单
Future<Object> getTradeOrders(data) async {
  return Request.post('/trade/orders', data: data);
}

// 获取支付号
Future<Object> getTradeOrdersPay(data) async {
  return Request.post('/trade/orders/pay', data: data);
}

// 订单列表
Future<Object> getOrdersList(params) async {
  return Request.get(
    '/trade/orders',
    queryParameters: params,
  );
}

// 蝉豆单购创建订单
Future<Object> getTradeOrdersBeans(data) async {
  return Request.post('/trade/orders/beans', data: data);
}

// 苹果支付凭证验证
Future<Object> setTradeReceipt(data) async {
  return Request.post('/trade/orders/verify-receipt', data: data);
}


// 蝉豆使用记录
Future<Object> getBeanLogs(params) async {
  return Request.get(
    '/trade/wallets/beans/logs',
    queryParameters: params,
  );
}

// 新用户初始化
Future<Object> getTradeVipInit() async {
  return Request.post('/trade/vips/init');
}

