import 'package:flutter/material.dart';
import 'package:flutter_module/utils/tool/resolve_cdn.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BenefitsContrast extends StatelessWidget {
  static const List<Map<String, dynamic>> benefits = [
    {'title': '权益', 'free': '免费版', 'vip': '蝉快剪 VIP'},

    {'title': '盯对标', 'free': '50个达人', 'vip': '50个达人'},
    {'title': '榜单数据', 'free': '前10条', 'vip': '无限制'},
    {'title': '素材下载', 'free': '10次', 'vip': '1000次/月'},

    {'title': '', 'free': '', 'vip': ''},

    {'title': '剪同款', 'free': '', 'vip': ''},
    {'title': '剪爆品', 'free': '', 'vip': ''},
    {'title': '剪热点', 'free': '1 次下载', 'vip': '100次下载/月'},
    {'title': '剪视频', 'free': '', 'vip': ''},
    {'title': '视频混剪', 'free': '', 'vip': ''},

    {'title': '', 'free': '', 'vip': ''},

    {'title': '剪数字人', 'free': '-', 'vip': '+'},
    {'title': '蝉豆数量', 'free': '5', 'vip': '200/月'},
    {'title': '高佣服务', 'free': '-', 'vip': '+'},
    {'title': '投流服务', 'free': '-', 'vip': '+'},
  ];

  const BenefitsContrast({super.key});

  Widget Item(String text) {
    if (text == '+') {
      return Image.network(
        resolveCDN('@cdn?21a9e5db1553'),
        width: 20.w,
        height: 20.h,
      );
    } else if (text == '-') {
      return Image.network(
        resolveCDN('@cdn?7ab3a43c2745'),
        width: 20.w,
        height: 20.h,
      );
    } else {
      return Text(
        text,
        style: TextStyle(
          fontSize: 12.sp,
          color: Color(0xFF050505),
          fontWeight: FontWeight.w500,
        ),
      );
    }
  }

  Widget benefitItem(Map<String, dynamic> benefit, {bool isHeader = false}) {
    if (benefit['title'] == '') {
      return divider();
    }
    return Container(
      width: double.infinity,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 42.h,
              color: Color(0xFFF2F3F5),
              padding: EdgeInsets.only(top: 10.h, bottom: 10.h),
              alignment: Alignment.center,
              child: Text(
                benefit['title'],
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Color(0xFF050505),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 42.h,
              color: Color(0xFFFFFFFF),
              padding: EdgeInsets.only(top: 10.h, bottom: 10.h),
              alignment: Alignment.center,
              child: Item(benefit['free']),
            ),
          ),
          Expanded(
            child: Container(
              height: 42.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors:
                      isHeader
                          ? [
                            Color.fromARGB(255, 223, 255, 208),
                            Color.fromARGB(255, 208, 255, 230),
                          ]
                          : [Color(0xFFF4FFF3), Color(0xFFF4FFF3)],
                ),
              ),
              padding: EdgeInsets.only(top: 10.h, bottom: 10.h),
              alignment: Alignment.center,
              child: Item(benefit['vip']),
            ),
          ),
        ],
      ),
    );
  }

  Widget divider() {
    return Divider(color: Color(0xffF2F3F5), height: 1, thickness: 1);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Color(0xFFF2F3F5)),
          borderRadius: BorderRadius.circular(12.r),
        ),
        width: double.infinity,
        child: Column(
          children: [
            benefitItem(benefits[0], isHeader: true),
            divider(),
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height - 600.h,
              ),
              child: SingleChildScrollView(
                child: Column(
                  children:
                      benefits
                          .sublist(1, benefits.length)
                          .map((e) => benefitItem(e, isHeader: false))
                          .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
