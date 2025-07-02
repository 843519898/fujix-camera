import 'package:flutter/material.dart';
import 'package:flutter_module/utils/tool/resolve_cdn.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CodeDialog extends StatelessWidget {
  final String title;
  final String submitText;
  final String qrCode;

  static void show(
    BuildContext context, {
    String title = '',
    String submitText = '',
    String qrCode = '',
  }) {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: CodeDialog(
            title: title,
            submitText: submitText,
            qrCode: qrCode,
          ),
        );
      },
    );
  }

  const CodeDialog({
    super.key,
    required this.title,
    required this.submitText,
    required this.qrCode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 316.w,
      height: 356.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 12.w,
            top: 12.w,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Image.network(
                resolveCDN('@cdn?3abae5f071ee'),
                width: 24.w,
                height: 24.w,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: 48.h),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF111111),
                  ),
                ),
                Text(
                  submitText,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF111111),
                  ),
                ),
                SizedBox(height: 18.h),
                Image.network(qrCode, width: 168.w, height: 168.w),
                SizedBox(height: 12.h),
                Text(
                  '保存二维码 微信扫一扫',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF86909C),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
