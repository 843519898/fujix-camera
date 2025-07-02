import 'package:flutter/material.dart';
import 'package:flutter_module/utils/tool/resolve_cdn.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_module/pages/vip/buy_vip_sheet.dart';
import 'package:flutter_module/config/app_env.dart';
import 'package:flutter_module/utils/storage_util.dart';
// import '../../../utils/native_bridge.dart';

class CxVipMore extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    void _onClickMore() async {
      final Map userInfo = await StorageUtil.getUserInfo();
      if (userInfo.containsKey('token') && userInfo['token'] != '') {
        BuyVipSheet.show(context, onClose: () {}, onOk: () {
          print('成功');
        });
        return;
      } else {
        // NativeBridge.openUserLogin();
      }
    }

    return Positioned(
        bottom: 0.h,
        left: 0.w,
        right: 0.w,
        child: Container(
            width: double.infinity,
            height: 122.h,
            padding: EdgeInsets.only(left: 16.w, right: 16.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.0),
                  Colors.white,
                ],
                stops: [0.0, 0.3105], // 31.05% 转换为小数
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 40.h),
                Text('非会员仅展示前10条数据，开通会员解锁更多权益', style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF999999),
                  decoration: TextDecoration.none,
                )),
                SizedBox(height: 8.h),
                GestureDetector(
                  onTap: () => _onClickMore(),
                  child: Container(
                    width: double.infinity,
                    height: 48.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Color(0xFFC2F60E),Color(0xFF7AFFDF),],
                        stops: [0, 0.95],
                      ),
                    ),
                    child: Center(
                      child: Text('查看更多', style: TextStyle(fontSize: 16.sp, color: Colors.black, fontWeight: FontWeight.w500)),
                    ),
                  ),
                )
              ],
            )
        )
    );
  }
}