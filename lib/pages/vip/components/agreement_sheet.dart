import 'package:flutter/material.dart';
import 'package:flutter_module/utils/tool/resolve_cdn.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AgreementSheet extends StatelessWidget {
  final Function() onClose;
  final Function() onOk;
  const AgreementSheet({super.key, required this.onClose, required this.onOk});

  static Future<void> show(
    BuildContext context, {
    required Function() onClose,
    required Function() onOk,
  }) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.95,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder:
          (BuildContext context) =>
              AgreementSheet(onClose: onClose, onOk: onOk),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          right: 0,
          child: TextButton(
            onPressed: onClose,
            child: Image.network(
              resolveCDN('@cdn?66bb0123493c'),
              width: 24.w,
              height: 24.h,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: EdgeInsets.only(left: 12.w, right: 12.w),
          height: 265.h,
          child: Column(
            children: [
              SizedBox(height: 24.h),
              Text(
                '付费服务协议',
                style: TextStyle(
                  fontSize: 18.sp,
                  color: Color(0xFF111111),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '为保障您的合法权益，请同意',
                    style: TextStyle(fontSize: 12.sp, color: Color(0xFF999999)),
                  ),
                  Text(
                    '《蝉快剪会员协议》',
                    style: TextStyle(fontSize: 12.sp, color: Color(0xFF000000)),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              GestureDetector(
                onTap: onOk,
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
                    '同意并购买',
                    style: TextStyle(
                      color: Color(0xFF22262C),
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              TextButton(
                onPressed: onClose,
                child: Text(
                  '取消',
                  style: TextStyle(
                    color: Color(0xFF4E5969),
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
