import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_module/utils/tool/resolve_cdn.dart';
// import 'package:flutter_module/utils/native_bridge.dart';
import 'package:flutter_module/config/app_env.dart';
import '../../../routes/route_name.dart';
import '../../../config/app_env.dart';
import 'dart:io';

class AgreementProtocol extends StatefulWidget {
  final bool defaultChecked;
  final Function(bool) onCheckChange;
  final Function() onClose;
  final String? fromNative; // 添加fromNative参数

  const AgreementProtocol({
    super.key,
    this.defaultChecked = false,
    required this.onCheckChange,
    required this.onClose,
    required this.fromNative,
  });

  @override
  State<AgreementProtocol> createState() => _AgreementProtocolState();
}

class _AgreementProtocolState extends State<AgreementProtocol> {
  bool _isAgree = false;

  _onAgreeTap() {
    setState(() {
      _isAgree = !_isAgree;
    });
    widget.onCheckChange(_isAgree);
  }

  @override
  void initState() {
    super.initState();
    _isAgree = widget.defaultChecked;
  }

  @override
  void didUpdateWidget(covariant AgreementProtocol oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.defaultChecked != widget.defaultChecked) {
      setState(() {
        _isAgree = widget.defaultChecked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 24.w,
            height: 24.h,
            child: TextButton(
              onPressed: _onAgreeTap,
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              child: Image.network(
                _isAgree
                    ? resolveCDN('@cdn?30b8edf53e45')
                    : resolveCDN('@cdn?89617aaa1665'),
                width: 14.w,
                height: 14.h,
              ),
            ),
          ),
          Text(
            '支付即代表同意',
            style: TextStyle(fontSize: 12.sp, color: Color(0xFF86909C), decoration: TextDecoration.none,),
          ),
          TextButton(
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            onPressed: () {
              if (Platform.isIOS && widget.fromNative == '1') {
                widget.onClose();
                // NativeBridge.closeModalBottomSheet('buyVipSheet', context, false);
                // Future.delayed(Duration(seconds: 1), () {
                //   NativeBridge.navigateToNativePage('${AppEnv.h5BaseUrl}/h5/kj/user');
                // });
              } else {
                if (Navigator.of(context).canPop()) {
                  // Navigator.of(context).pushNamed(RouteName.h5RoutePage, arguments: {
                  //   'url': '${AppEnv.h5BaseUrl}/h5/kj/user',
                  // });
                } else {
                  widget.onClose();
                  // NativeBridge.closeModalBottomSheet('buyVipSheet', context, false);
                  // Future.delayed(Duration(seconds: 1), () {
                  //   NativeBridge.navigateToNativePage('${AppEnv.h5BaseUrl}/h5/kj/user');
                  // });
                }
              }
            },
            child: Text(
              '《蝉快剪会员付费协议》',
              style: TextStyle(fontSize: 12.sp, color: Color(0xFF111111)),
            ),
          ),
          SizedBox(
            height: 12.h,
            child: VerticalDivider(
              width: 2, // 分割线占用的总宽度（包括间距）
              thickness: 1, // 分割线的实际厚度
              color: Color(0xFFE5E6EB), // 分割线颜色
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            onPressed: () {
              // NativeBridge.navigateToNativePage('${AppEnv.h5BaseUrl}/feedback/index?from=chan_kuai_jian');
            },
            child: Text(
              '联系我们',
              style: TextStyle(fontSize: 12.sp, color: Color(0xFF86909C)),
            ),
          ),
        ],
      ),
    );
  }
}
