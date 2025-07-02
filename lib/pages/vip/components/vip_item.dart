import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_module/pages/vip/vip_plan.dart';
import 'dart:io' show Platform;

class VipItem extends StatelessWidget {
  final Map vipPlan;
  final bool isActive;
  final Function() onTap;
  final int activeIndex;

  const VipItem({
    super.key,
    required this.vipPlan,
    required this.isActive,
    required this.onTap,
    required this.activeIndex,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none, // 允许子组件超出边界
        children: [
          Container(
            width: 120.w,
            height: 147.h,
            decoration: BoxDecoration(
              color: isActive ? Color(0x33A1F74A) : Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border:
              isActive
                  ? Border.all(color: Color(0xFFA1F74A), width: 1.5.w)
                  : Border.all(color: Color(0xFFF2F3F5), width: 1.5.w),
            ),
            padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vipPlan['name'],
                  style: TextStyle(
                    color: Color(0xFF111111),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    decoration: TextDecoration.none,
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '¥',
                      style: TextStyle(
                        color: Color(0xFF000000),
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    Text(
                      vipPlan['price'].toString(),
                      style: TextStyle(
                        color: Color(0xFF000000),
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
                if (activeIndex == 1)
                Row(
                  children: [
                    Text('原价', style: TextStyle(color: isActive ? Color(0xFF27D300) : Color(0xFF86909C), fontSize: 12, decoration: TextDecoration.none,)),
                    SizedBox(width: 4.h),
                    Text('¥${Platform.isIOS ? '984' : '828'}', style: TextStyle(color: isActive ? Color(0xFF27D300) : Color(0xFF86909C), fontSize: 12, decoration: TextDecoration.lineThrough))
                  ],
                ),
                if (activeIndex == 0)
                  SizedBox(height: 14.h),
                Row(
                  children: [
                    Text(
                      activeIndex == 0 ? '获100次下载' : '获100次下载/月',
                      style: TextStyle(
                        color: Color(0xFF111111),
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w400,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Text(
                      '赠',
                      style: TextStyle(
                        color: Color(0xFF111111),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      vipPlan['sku_benefit_relations'][1]['quantity'].toString(),
                      style: TextStyle(
                        color: Color(0xFF111111),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      '蝉豆',
                      style: TextStyle(
                        color: Color(0xFF111111),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (activeIndex == 1)
          Positioned(
              right: -17.w,
              top: -14.h,
              child: Container(
                width: 64.w,
                height: 28.h,
                decoration: BoxDecoration(
                    color: Color(0xFFE8FFEA),
                    borderRadius: BorderRadius.circular(40)
                ),
                child: Center(
                  child: Text('限时特惠', style: TextStyle(color: Color(0xFF009A29), fontWeight: FontWeight.w500, fontSize: 12.sp),),
                ),
              )
          ),
        ],
      )
    );
  }
}
