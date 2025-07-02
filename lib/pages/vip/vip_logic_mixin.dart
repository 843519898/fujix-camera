import 'package:flutter/material.dart';
import 'package:tobias/tobias.dart';

mixin VipLogicMixin {
  pay(BuildContext context, String payStr) async {
    return await alipay(context, payStr);
  }

  alipay(BuildContext context, payStr) async {
    Tobias tobias = Tobias();
    var result = await tobias.isAliPayInstalled;
    if (!context.mounted) return;
    if (!result) {
      print('暂未安装支付宝');
      // showDialog(
      //   context: context,
      //   builder:
      //       (context) => AlertDialog(
      //         title: Text('请先安装支付宝'),
      //         actions: [
      //           TextButton(
      //             onPressed: () {
      //               Navigator.of(context).pop();
      //             },
      //             child: Text('确定'),
      //           ),
      //         ],
      //       ),
      // );
    }
    var payResult = await tobias.pay(payStr);
    print('payResult: $payResult');
    return payResult;
  }
}
