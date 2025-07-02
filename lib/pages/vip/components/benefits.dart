import 'package:flutter/material.dart';
import 'package:flutter_module/utils/tool/resolve_cdn.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Benefits extends StatelessWidget {
  const Benefits({super.key});

  Widget benefitItem(Map benefit) {
    return SizedBox(
      width: 53.w,
      child: Column(
        children: [
          Image.network(benefit['logo'], width: 36.w, height: 36.w),
          SizedBox(height: 4.h),
          Text(
            benefit['name'],
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: Color(0xFF86909C),
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List newBenefits = [
      {
        'logo': 'https://cdn-static.chanmama.com/sub-module/static-file/c/5/c934bd6012',
        'name': '剪同款'
      },
      {
        'logo': 'https://cdn-static.chanmama.com/sub-module/static-file/2/7/c9a994ef07',
        'name': '剪爆品'
      },
      {
        'logo': 'https://cdn-static.chanmama.com/sub-module/static-file/b/7/0b0e2303b6',
        'name': '剪数字人'
      },
      // {
      //   'logo': '1',
      //   'name': '视频混剪'
      // },
      {
        'logo': 'https://cdn-static.chanmama.com/sub-module/static-file/b/3/3e5246953b',
        'name': '剪视频'
      }
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...newBenefits
              .where((benefit) => benefit['name'] != '剪热点')
              .map((e) => Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: benefitItem(e),
                  )),
        ],
      ),
    );
  }
}
